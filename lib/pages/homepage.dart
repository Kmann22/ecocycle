import 'package:ecocylce/pages/challenges.dart';
import 'package:ecocylce/pages/login.dart';
import 'package:ecocylce/pages/userrecycle.dart';
import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String publicKey = ""; // Public key from Firebase
  String xlmBalance = "Fetching balance..."; // Default message
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase authentication instance

  @override
  void initState() {
    super.initState();
    _fetchPublicKey(); // Fetch the public key when the page is initialized
  }

  Future<void> _fetchPublicKey() async {
    User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      // Retrieve public key from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();
      if (doc.exists && doc.data() != null) {
        // Cast the data to a Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        publicKey = data['publicKey'] ?? ""; // Get the public key

        if (publicKey.isNotEmpty) {
          _fetchAccountData(); // Fetch the account data after obtaining the public key
        } else {
          setState(() {
            xlmBalance = "Public key not found. Please ensure it is saved.";
          });
        }
      } else {
        // Handle the case where the document does not exist or has no data
        setState(() {
          xlmBalance = "Public key not found. Please ensure it is saved.";
        });
      }
    } else {
      // Handle the case where there is no user logged in
      setState(() {
        xlmBalance = "User not logged in";
      });
    }
  }

  Future<void> _fetchAccountData() async {
    try {
      // Create a Stellar SDK instance
      var server = StellarSDK.TESTNET; // Use test network

      // Request the account data
      AccountResponse account = await server.accounts.account(publicKey);

      // Check balances
      String balanceString = "";
      for (Balance balance in account.balances) {
        switch (balance.assetType) {
          case Asset.TYPE_NATIVE:
            balanceString += "Balance: ${balance.balance} XLM\n";
            break;
          default:
            balanceString +=
                "Balance: ${balance.balance} ${balance.assetCode} Issuer: ${balance.assetIssuer}\n";
        }
      }

      // Update the balance and sequence number in the state
      setState(() {
        xlmBalance =
            balanceString + "Sequence number: ${account.sequenceNumber}";
      });

      // Optional: You can also print signers and data
      for (Signer signer in account.signers) {
        print("Signer public key: ${signer.accountId}");
      }

      for (String key in account.data.keys) {
        print("Data key: $key value: ${account.data[key]}");
      }
    } catch (e) {
      // Handle error (for example, account not found)
      setState(() {
        xlmBalance = "Error fetching account data";
      });
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

  Future<void> _logout() async {
    await _auth.signOut(); // Sign out from Firebase
    // Navigate back to login page or initial page (implement this part as per your app structure)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Replace with your LoginPage widget
      (Route<dynamic> route) => false, // Clear the navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call the logout method
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display XLM Balance
            Text(
              'Account Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              xlmBalance,
              style: TextStyle(fontSize: 24, color: Colors.green),
            ),
            SizedBox(height: 20),

            // Navigation to Recycling Centers
            ElevatedButton(
              onPressed: () {},
              child: Text('Find Nearby Recycling Centers'),
            ),

            SizedBox(height: 20),

            // Admin-User Rewards Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Rewards Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RewardsPage()), // Ensure RewardsPage is imported
                );
              },
              child: Text('Admin - Manage User Rewards'),
            ),
            SizedBox(height: 20),

            // Community Page Link
            ElevatedButton(
              onPressed: () {
                // Navigate to Community Page (implement this page)
              },
              child: Text('Community Page'),
            ),
            SizedBox(height: 20),

            // Challenges Page Link
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChallengesPage()), // Ensure ChallengesPage is imported
                );
              },
              child: Text('Participate in Recycling Challenges'),
            ),
            SizedBox(height: 30),

            // Recycling Stats Section
            // Add any additional stats here if needed
          ],
        ),
      ),
    );
  }
}
