import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final TextEditingController _bottleCountController = TextEditingController();
  String? qrData;
  String publicKey = "";
  String xlmBalance = "";
  String transferMessage = ""; // To store the transfer message
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchPublicKey();
  }

  Future<void> _fetchPublicKey() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        publicKey = data['publicKey'] ?? "";
        if (publicKey.isEmpty) {
          _showError("Public key not found. Please ensure it is saved.");
        }
      } else {
        _showError("Public key not found. Please ensure it is saved.");
      }
    } else {
      _showError("User not logged in");
    }
  }

  void _showError(String message) {
    setState(() {
      xlmBalance = message;
    });
  }

  void _generateQRCode() {
    final bottleCount = _bottleCountController.text;
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (publicKey.isNotEmpty && bottleCount.isNotEmpty) {
      qrData =
          'UserPublicKey: $publicKey, Bottles: $bottleCount, Timestamp: $timestamp';
      setState(() {
        _storeRecyclingData(publicKey, int.parse(bottleCount));
        transferMessage =
            "Data transferred from QR: $qrData"; // Show exact data
      });
    } else {
      _showError(
          'Please enter a valid number of bottles and ensure your public key is available.');
    }
  }

  Future<void> _storeRecyclingData(String userId, int bottleCount) async {
    try {
      await FirebaseFirestore.instance.collection('recycling').add({
        'userId': userId,
        'bottleCount': bottleCount,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Data transferred: $qrData'); // Print exact data transferred
    } catch (e) {
      print('Error storing recycling data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rewards Page')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _bottleCountController,
              decoration:
                  InputDecoration(labelText: 'Number of Bottles Recycled'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateQRCode,
              child: Text('Generate QR Code'),
            ),
            SizedBox(height: 20),
            if (qrData != null)
              QrImageView(
                data: qrData ?? '',
                version: QrVersions.auto,
                size: 200.0,
              ),
            SizedBox(height: 20),
            if (xlmBalance.isNotEmpty)
              Text(xlmBalance, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            if (transferMessage.isNotEmpty)
              Text(transferMessage, style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
