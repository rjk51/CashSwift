import 'package:cashswift/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashswift/pages/scanner.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({Key? key}) : super(key: key);

  @override
  _SendMoneyScreenState createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _upiIdController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  bool _showAmountField = false;
  String _selectedCategory = 'Food'; // Default category

  List<String> categories = [
    'Food',
    'Clothing',
    'Entertainment',
    'Transportation',
    'Others',
  ];

  void storeTransaction(
    String userId,
    String type,
    double amount,
    String category, // Add category parameter
  ) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': userId,
        'type': type,
        'amount': amount,
        'category': category, // Store category in transaction
        'timestamp': Timestamp.now(),
      });
      print('Transaction stored successfully.');
    } catch (error) {
      print('Error storing transaction: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Card(
            color: Theme.of(context).colorScheme.tertiary,
            elevation: 4,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Send Money :',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _upiIdController,
                      decoration: InputDecoration(labelText: 'Recipient\'s UPI ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid UPI ID';
                        }
                        if (!checkUserExists(value)) {
                          return 'User not found';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    if (_showAmountField)
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          // Check if the amount is not empty and is a valid number
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          // Check if the amount is valid based on sender's balance
                          if (checkSufficientBalance(double.parse(value)) == false) {
                            return 'Insufficient balance';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: 20.0),
                    Theme(
                      data: Theme.of(context).copyWith(canvasColor: Theme.of(context).colorScheme.tertiary),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        if (_showAmountField) {
                          // Submit form with amount field
                          if (_formKey.currentState!.validate()) {
                            // Send money and update balances
                            sendMoney(double.parse(_amountController.text));
                          }
                        } else {
                          // Submit form with UPI ID field
                          if (_formKey.currentState!.validate()) {
                            // Validate UPI ID and show amount field if valid
                            setState(() {
                              _showAmountField = true;
                            });
                          }
                        }
                      },
                      child: Text(_showAmountField ? 'Send Money' : 'Next'),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () async {
                        final scannedData = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QRCodeScanner()),
                        );
                        if (scannedData != null) {
                          _upiIdController.text = scannedData;
                        }
                      },
                      child: const Text('Scan QR Code'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Simulate database query to check if the user exists
  bool checkUserExists(String upiId) {
    FirebaseFirestore.instance
        .collection('users')
        .where('upiId', isEqualTo: upiId)
        .get()
        .then((querySnapshot) {
      return querySnapshot.docs.isNotEmpty;
    });
    return upiId.isNotEmpty;
  }

  // Simulate checking sender's balance
  Future<bool> checkSufficientBalance(double amount) async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in.');
      }

      // Retrieve the sender's balance from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Check if the user document exists
      if (!userSnapshot.exists) {
        throw Exception('User data not found.');
      }

      // Get the user's data
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      // Extract the balance from user data
      dynamic balance = userData['balance'] ?? 0; // Use dynamic type

      // Compare the balance with the entered amount
      return balance >= amount.toDouble(); // Convert amount to double
    } catch (error) {
      print('Error checking balance: $error');
      return false; // Return false in case of any error
    }
  }

  void sendMoney(double amount) async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in.');
      }

      // Retrieve the sender's data from Firestore
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Retrieve the recipient's data from Firestore
      QuerySnapshot recipientQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('upiId', isEqualTo: _upiIdController.text)
          .get();

      // Check if the recipient exists
      if (recipientQuerySnapshot.docs.isEmpty) {
        throw Exception('Recipient not found.');
      }

      // Get the first document in the query snapshot
      DocumentSnapshot recipientSnapshot = recipientQuerySnapshot.docs.first;

      // Get the sender's and recipient's balances
      Map<String, dynamic> senderData =
          senderSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> recipientData =
          recipientSnapshot.data() as Map<String, dynamic>;

      // Extract balances as dynamic types
      dynamic senderBalance = senderData['balance'] ?? 0;
      dynamic recipientBalance = recipientData['balance'] ?? 0;

      // Convert balances to double
      double newSenderBalance = (senderBalance as num).toDouble();
      double newRecipientBalance = (recipientBalance as num).toDouble();

      // Check if the sender has sufficient balance
      if (newSenderBalance < amount) {
        throw Exception('Insufficient balance.');
      }

      // Deduct the amount from the sender's balance
      newSenderBalance -= amount;

      // Add the amount to the recipient's balance
      newRecipientBalance += amount;

      // Update the balances in Firestore
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid),
        {'balance': newSenderBalance},
      );
      batch.update(
        recipientSnapshot.reference,
        {'balance': newRecipientBalance},
      );
      await batch.commit();

      storeTransaction(
        currentUser.uid,
        'send',
        amount,
        _selectedCategory, // Pass selected category
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Money sent successfully: $amount'),
        ),
      );
    } catch (error) {
      print('Error sending money: $error');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send money: $error'),
        ),
      );
    }
  }
}
