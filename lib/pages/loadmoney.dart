import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashswift/components/app_bar.dart';

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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
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

                              // Fetch current user document
                              DocumentSnapshot userSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .get();

                              // Check if user document exists
                              if (userSnapshot.exists) {
                                // Get user data
                                Map<String, dynamic> userData =
                                    userSnapshot.data()
                                        as Map<String, dynamic>;

                                // Check if userData contains the 'balance' key
                                if (userData.containsKey('balance')) {
                                  double currentBalance =
                                      userData['balance'].toDouble();
                                  double updatedBalance =
                                      currentBalance + newAmount;

                                  // Update user's balance
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({'balance': updatedBalance});
                                } else {
                                  // If 'balance' key doesn't exist, create it
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .set({'balance': newAmount},
                                          SetOptions(merge: true));
                                }

                                // Store transaction and show success message
                                storeTransaction(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    'load',
                                    newAmount);
                                _showSuccessSnackBar();

                                // Clear the text field
                                _amountController.clear();
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
