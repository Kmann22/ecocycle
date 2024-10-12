import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengesPage extends StatefulWidget {
  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final StellarSDK sdk = StellarSDK.TESTNET;
  String publicKey = ""; // Public key from Firebase
  String xlmBalance = "Fetching balance..."; // Default message

  // Challenges data structure with updated challenges
  List<Challenge> challenges = [
    Challenge(name: 'Collect 500 bottles', targetBottles: 500, reward: 2),
    Challenge(name: 'Collect 1000 bottles', targetBottles: 1000, reward: 3),
    Challenge(name: 'Collect 10,000 bottles', targetBottles: 10000, reward: 5),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPublicKey(); // Fetch the public key when the page is initialized
  }

  Future<void> _fetchPublicKey() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      // Retrieve public key from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        publicKey = data['publicKey'] ?? ""; // Get the public key

        if (publicKey.isNotEmpty) {
          _fetchBalance(); // Fetch balance after obtaining the public key
        } else {
          setState(() {
            xlmBalance = "Public key not found. Please ensure it is saved.";
          });
        }
      } else {
        setState(() {
          xlmBalance = "Public key not found. Please ensure it is saved.";
        });
      }
    } else {
      setState(() {
        xlmBalance = "User not logged in";
      });
    }
  }

  Future<void> _fetchBalance() async {
    try {
      AccountResponse account = await sdk.accounts.account(publicKey);
      setState(() {
        xlmBalance =
            "Current Stellar Balance: ${account.balances[0].balance} XLM"; // Get the first balance (assuming it's XLM)
      });
    } catch (e) {
      print("Error fetching balance: $e");
      setState(() {
        xlmBalance = "Error fetching account data";
      });
    }
  }

  int _calculateNumberOfBottles() {
    // Extract the balance string from xlmBalance and ensure it's properly formatted
    final balanceString = xlmBalance
        .split(': ')
        .last
        .split(' ')[0]; // Extract only the balance part
    double balance = double.tryParse(balanceString) ?? 0.0; // Parse to double
    if (balance > 10000) {
      return ((balance - 10000) * 10).toInt();
    }
    return 0; // Return 0 if the balance is less than or equal to 10,000 XLM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Challenges')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              xlmBalance,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Number of Bottles: ${_calculateNumberOfBottles()}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
                  int numberOfBottles = _calculateNumberOfBottles();
                  double progress = numberOfBottles >= challenge.targetBottles
                      ? 1.0
                      : numberOfBottles / challenge.targetBottles;
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 20,
                            backgroundColor: Colors.grey[300],
                            color: progress >= 1.0 ? Colors.green : Colors.blue,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Progress: ${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Reward: ${challenge.reward} XLM',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _fetchBalance, // Refresh the balance
              child: Text('Refresh Balance'),
            ),
          ],
        ),
      ),
    );
  }
}

class Challenge {
  final String name;
  final int targetBottles;
  final double reward;
  final Duration? timeLimit;

  Challenge({
    required this.name,
    required this.targetBottles,
    required this.reward,
    this.timeLimit,
  });
}
