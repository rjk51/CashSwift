import 'package:cashswift/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoadMoney extends StatefulWidget {
  const LoadMoney({Key? key}) : super(key: key);

  @override
  _LoadMoneyState createState() => _LoadMoneyState();
}

class _LoadMoneyState extends State<LoadMoney> {
  final TextEditingController _amountController = TextEditingController();

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction successful'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear the text field after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _amountController.clear();
    });
  }

  void storeTransaction(String userId, String type, double amount) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': userId,
        'type': type,
        'amount': amount,
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
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 150, 20, 150),
          child: SingleChildScrollView(
            child: Card(
              color: Theme.of(context).colorScheme.tertiary,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Money to Wallet :',
                      style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height:40),
                    const Text(
                      'Enter amount:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Amount in ₹',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            final String amount =
                                _amountController.text.trim();
                            if (amount.isNotEmpty) {
                              // Convert entered amount to double
                              double newAmount =
                                  double.tryParse(amount) ?? 0;
            
                              // Fetch current balance from Firestore
                              DocumentSnapshot userSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .get();
            
                              // Check if user document exists
                              if (userSnapshot.exists) {
                                // Get the current balance
                                Map<String, dynamic>? userData =
                                    userSnapshot.data()
                                        as Map<String, dynamic>?;
            
                                // Check if userData is not null and contains the 'balance' key
                                if (userData != null &&
                                    userData.containsKey('balance')) {
                                  double currentBalance =
                                      userData['balance'].toDouble();
                                  // Add the entered amount to the current balance
                                  double updatedBalance =
                                      currentBalance + newAmount;
            
                                  // Update user's balance in Firestore
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({'balance': updatedBalance});
            
                                  storeTransaction(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      'load',
                                      newAmount);
            
                                  // Show success message
                                  _showSuccessSnackBar();
            
                                  // Clear the text field
                                  _amountController.clear();
                                } else {
                                  // Show error message if balance data is not found
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text('Balance data not found.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                // Show error message if user document does not exist
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('User document not found.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the text editing controller
    _amountController.dispose();
    super.dispose();
  }
}
