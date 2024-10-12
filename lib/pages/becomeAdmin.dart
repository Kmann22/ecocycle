// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
// import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

// class BecomeAdminPage extends StatefulWidget {
//   @override
//   _BecomeAdminPageState createState() => _BecomeAdminPageState();
// }

// class _BecomeAdminPageState extends State<BecomeAdminPage> {
//   final TextEditingController _publicKeyController = TextEditingController();
//   final YourXlmLibrary xlmLibrary = YourXlmLibrary();
//   String transactionStatus = '';
//   final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize Firebase Auth

//   @override
//   void initState() {
//     super.initState();
//     xlmLibrary.initialize(); // Initialize the XLM library
//   }

//   Future<void> _becomeAdmin() async {
//     String publicKey = _publicKeyController.text.trim(); // Trim whitespace

//     if (publicKey.isEmpty) {
//       setState(() {
//         transactionStatus = "Please enter your public key.";
//       });
//       return;
//     }

//     // Amount to send for admin registration
//     const double amountToSend = 10.0; // Amount to send

//     // Get the current authenticated user's secret key
//     User? user = _auth.currentUser; // Get the current authenticated user
//     if (user == null) {
//       setState(() {
//         transactionStatus =
//             "User not logged in. Please log in to become an admin.";
//       });
//       return;
//     }

//     // Initiate the XLM transfer
//     bool transferSuccess = await xlmLibrary.transfer(
//         publicKey, amountToSend, user.uid); // Pass user UID or secret key

//     if (transferSuccess) {
//       // Update the user document in Firestore to set the admin status
//       await cloud.FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.email)
//           .update({'isAdmin': true}); // Update isAdmin field to true
//       setState(() {
//         transactionStatus = "You are now an admin!";
//       });
//     } else {
//       setState(() {
//         transactionStatus = "Transfer failed. Please try again.";
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _publicKeyController.dispose(); // Dispose of the controller
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Become an Admin')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _publicKeyController,
//               decoration: InputDecoration(labelText: 'Your Public Key'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _becomeAdmin,
//               child: Text('Become Admin'),
//             ),
//             SizedBox(height: 20),
//             Text(transactionStatus, style: TextStyle(color: Colors.red)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class YourXlmLibrary {
//   final String stellarNetwork;

//   YourXlmLibrary({this.stellarNetwork = "testnet"});

//   Future<void> initialize() async {
//     // Setup SDK if needed
//     // If you're doing any SDK-specific initialization, do it here.
//   }

//   Future<bool> transfer(
//       String recipientPublicKey, double amount, String senderSecretKey) async {
//     try {
//       // Create a Stellar SDK client
//       final StellarSDK sdk = StellarSDK.TESTNET; // Use testnet for development

//       // Create a keypair for the sender
//       final KeyPair senderKeyPair = KeyPair.fromSecretSeed(
//           senderSecretKey); // Use the sender's secret key

//       // Fetch sender's account to build the transaction
//      const String senderAccount =
//           "GCVZ6OIDJMYQVMVIT4KTNK7KCLX5I5XUYVORSXB5YNEBQH6IOHOYX7OL";

//       // Create the transaction builder
//       final TransactionBuilder transactionBuilder =
//           TransactionBuilder(senderAccount)
//               .addOperation(createAccBuilder.build())
//               .build() as TransactionBuilder;

//       // Build and sign the transaction
//       final Transaction transaction = transactionBuilder.build();
//       transaction.sign(senderKeyPair, Network.TESTNET);

//       // Send the transaction
//       final SubmitTransactionResponse response =
//           await sdk.submitTransaction(transaction);

//       if (response.success) {
//         return true; // Transfer was successful
//       } else {
//         print('Transfer failed: ${response}');
//         return false; // Transfer failed
//       }
//     } catch (e) {
//       print('Error in transfer: $e');
//       return false; // Handle errors
//     }
//   }
// }
