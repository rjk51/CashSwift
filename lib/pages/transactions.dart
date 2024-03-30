import 'package:cashswift/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Text(
            'Previous Transactions: ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('transactions')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .orderBy('timestamp', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final List<DocumentSnapshot> transactions = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index].data() as Map<String, dynamic>;
                        final String type = transaction['type'];
                        final double amount = transaction['amount'];
                        final String? category = type == 'load' ? null : transaction['category']; // Exclude category for 'load' transactions
                        final timestamp = (transaction['timestamp'] as Timestamp).toDate();
                        final formattedDate = DateFormat.yMMMMd().add_jms().format(timestamp);

                        // Determine the symbol and color based on transaction type
                        String symbol = '';
                        Color amountColor = Colors.black; // Default color for amount text
                        if (type == 'send') {
                          symbol = '-';
                          amountColor = Colors.red; // Change color to red for 'send' transactions
                        } else if (type == 'load') {
                          symbol = '+';
                          amountColor = Colors.green; // Change color to green for 'load' transactions
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            tileColor: Theme.of(context).colorScheme.tertiary,
                            title: Text(
                              '$symbol ₹$amount',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: amountColor, // Set the text color based on transaction type
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (category != null) Text('Category: $category'), // Conditional rendering of category
                                Text(formattedDate), // Display date
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}