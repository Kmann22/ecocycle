// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

// class YourXlmLibrary {
//   final String stellarNetwork; // "testnet" or "public"

//   YourXlmLibrary({this.stellarNetwork = "testnet"});

//   // Initialize the Stellar SDK
//   Future<void> initialize() async {
//     // Setup SDK if needed
//   }

//   // Create a transfer function to send XLM
//   Future<bool> transfer(String recipientPublicKey, double amount) async {
//     try {
//       // Create a Stellar client
//       final StellarSdk sdk = StellarSdk.instance;

//       // Get the network
//       final Network network =
//           stellarNetwork == "testnet" ? Network.testnet() : Network.public();

//       // Create a keypair for the sender
//       // Note: This should be the secret key of the account initiating the transfer
//       final KeyPair senderKeyPair = KeyPair.fromSecretKey(
//           'YOUR_SECRET_KEY'); // Replace with your secret key

//       // Create the transaction
//       final Transaction transaction = TransactionBuilder(senderKeyPair, network)
//           .addOperation(PaymentOperationBuilder(
//             recipientPublicKey,
//             Asset.create("native"), // For XLM
//             amount,
//           ).build())
//           .build();

//       // Sign the transaction
//       transaction.sign(senderKeyPair);

//       // Send the transaction
//       final response = await sdk.submitTransaction(transaction);

//       // Check the response for success or failure
//       if (response.success) {
//         return true; // Transfer was successful
//       } else {
//         print('Transfer failed: ${response.error}');
//         return false; // Transfer failed
//       }
//     } catch (e) {
//       print('Error in transfer: $e');
//       return false; // Handle errors
//     }
//   }
// }

// class AdminRewardsPage extends StatefulWidget {
//   @override
//   _AdminRewardsPageState createState() => _AdminRewardsPageState();
// }

// class _AdminRewardsPageState extends State<AdminRewardsPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   String? scannedData;
//   String transactionStatus = '';
//   final TextEditingController _amountController = TextEditingController();
//   final YourXlmLibrary xlmLibrary =
//       YourXlmLibrary(); // Create an instance of YourXlmLibrary

//   @override
//   void initState() {
//     super.initState();
//     xlmLibrary.initialize(); // Initialize the XLM library
//   }

//   @override
//   void reassemble() {
//     super.reassemble();
//     if (Platform.isAndroid) {
//       controller!.pauseCamera();
//     } else if (Platform.isIOS) {
//       controller!.resumeCamera();
//     }
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         scannedData = scanData.code; // Store the scanned QR code data
//       });
//     });
//   }

//   Future<void> _verifyAndTransferXLM() async {
//     if (scannedData == null) {
//       setState(() {
//         transactionStatus = "No QR code scanned.";
//       });
//       return;
//     }

//     // Parse the QR data
//     final parts = scannedData!.split(',');
//     final publicKey = parts[0].split(': ')[1];
//     final bottleCount = int.parse(parts[1].split(': ')[1]);

//     // Fetch the stored bottle count from Firestore for verification
//     DocumentSnapshot doc = await FirebaseFirestore.instance
//         .collection('recycling')
//         .doc(publicKey) // Assuming the document ID is the public key
//         .get();

//     if (doc.exists && doc.data() != null) {
//       final storedBottleCount = doc.data()!['bottleCount'] as int;

//       if (storedBottleCount == bottleCount) {
//         // Initiate the XLM transfer
//         final transferAmount = double.parse(_amountController.text);
//         bool transferSuccess =
//             await xlmLibrary.transfer(publicKey, transferAmount);

//         if (transferSuccess) {
//           setState(() {
//             transactionStatus = "Transfer successful!";
//           });
//           // Optionally: Update the progress or status in Firestore
//         } else {
//           setState(() {
//             transactionStatus = "Transfer failed. Please try again.";
//           });
//         }
//       } else {
//         setState(() {
//           transactionStatus = "Bottle count does not match.";
//         });
//       }
//     } else {
//       setState(() {
//         transactionStatus = "No record found for this user.";
//       });
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Admin Rewards Page')),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 3,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _amountController,
//                   decoration:
//                       InputDecoration(labelText: 'Amount of XLM to Transfer'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _verifyAndTransferXLM,
//                   child: Text('Verify and Transfer'),
//                 ),
//                 SizedBox(height: 20),
//                 Text(transactionStatus, style: TextStyle(color: Colors.red)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
