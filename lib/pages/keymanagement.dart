import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'homepage.dart'; // Import your homepage

class KeyManagementPage extends StatefulWidget {
  @override
  _KeyManagementPageState createState() => _KeyManagementPageState();
}

class _KeyManagementPageState extends State<KeyManagementPage> {
  String _publicKey = '';
  String _privateKey = '';
  String _importedPublicKey = '';
  TextEditingController _importKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkForExistingKey(); // Check if the user already has a public key
  }

  Future<void> _checkForExistingKey() async {
    // Check Firebase for an existing public key
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get(); // Use user email as document ID
      if (userDoc.exists) {
        String storedPublicKey = userDoc['publicKey'] ?? '';
        if (storedPublicKey.isNotEmpty) {
          // Redirect to homepage if public key exists
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage()), // Navigate to homepage
          );
        }
      }
    }
  }

  // Generate Keys and Fund Account
  Future<void> _generateKeys() async {
    // Generate keys using the Stellar Flutter SDK
    KeyPair keyPair = KeyPair.random(); // Create a new random key pair
    setState(() {
      _publicKey = keyPair.accountId; // Set the public key
      _privateKey = keyPair.secretSeed; // Set the private key
      _importedPublicKey = ''; // Reset imported key on generation
    });

    // Save the public key to Firebase
    await _savePublicKeyToFirebase(_publicKey);

    // Fund the test account using FriendBot
    bool funded = await FriendBot.fundTestAccount(keyPair.accountId);

    if (funded) {
      // Show a success message if funding was successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully funded with 100 test XLM!')),
      );
    } else {
      // Show a failure message if funding was unsuccessful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fund account. Please try again.')),
      );
    }
  }

  Future<void> _savePublicKeyToFirebase(String publicKey) async {
    // Save public key to Firebase
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.email).set({
        'publicKey': publicKey,
      }, SetOptions(merge: true)); // Use merge to update the existing document
    }
  }

  void _importKey() {
    // Import key logic (for simplicity, just storing the imported key)
    final importedKey = _importKeyController.text;
    setState(() {
      _importedPublicKey = importedKey; // Store the imported public key
      _publicKey = ''; // Reset generated keys when importing
      // Inform user to remember their private key
    });
  }

  Future<void> _copyPrivateKey() async {
    await Clipboard.setData(ClipboardData(text: _privateKey));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Private key copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate/Import Keys'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanation
            Text(
              'This page allows you to generate a Stellar public/private key pair (passkeys) or import existing ones. These keys are essential for interacting with the blockchain for transparency and security.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Important: Keep your private key safe and never share it with anyone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            // Generate Keys Button
            ElevatedButton(
              onPressed: _generateKeys,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                backgroundColor: Colors.green,
              ),
              child: Text('Generate Keys'),
            ),
            SizedBox(height: 16),

            // Display Generated Keys
            if (_publicKey.isNotEmpty && _privateKey.isNotEmpty) ...[
              Text('Generated Public Key:'),
              Text(_publicKey, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Generated Private Key:'),
              Text(_privateKey, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              // Copy Private Key Button
              ElevatedButton(
                onPressed: _copyPrivateKey,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  backgroundColor: Colors.yellow,
                ),
                child: Text('Copy Private Key'),
              ),
              SizedBox(height: 16),
            ],

            // Import Existing Key
            TextField(
              controller: _importKeyController,
              decoration: InputDecoration(
                labelText: 'Import Existing Public Key',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Import Button
            ElevatedButton(
              onPressed: _importKey,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                backgroundColor: Colors.blue,
              ),
              child: Text('Import Key'),
            ),
            SizedBox(height: 16),

            // Display Imported Key
            if (_importedPublicKey.isNotEmpty) ...[
              Text('Imported Public Key:'),
              Text(_importedPublicKey,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'Note: Ensure the corresponding private key is stored securely.',
                style: TextStyle(color: Colors.orange),
              ),
              SizedBox(height: 16),
            ],

            // Button to go to homepage
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage()), // Navigate to homepage
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                backgroundColor: Colors.blueAccent,
              ),
              child: Text('Go to Homepage'),
            ),
          ],
        ),
      ),
    );
  }
}
