import 'dart:math';

import 'package:cashswift/components/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

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
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
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

                  // Calculate spendings by category
                  Map<String, double> categorySpendings = {};
                  for (var transaction in transactions) {
                    final Map<String, dynamic> data = transaction.data() as Map<String, dynamic>;
                    final String type = data['type'];
                    final String? category = type == 'load' ? null : data['category'];
                    final double amount = data['amount'];
                    if (category != null) {
                      categorySpendings[category] = (categorySpendings[category] ?? 0) + amount;
                    }
                  }

                  // Prepare data for pie chart
                  List<PieChartSectionData> pieChartSections = categorySpendings.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      showTitle: false,
                      title: entry.key,
                      color: getRandomColor(), // Define a function to generate random colors
                      radius: 60,
                      badgeWidget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(getIconForCategory(entry.key), size: 24),
                        ],
                      ),
                    );
                  }).toList();

                  return Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sections: pieChartSections,
                            borderData: FlBorderData(show: false),
                            centerSpaceRadius: 40,
                            sectionsSpace: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        flex: 7,
                        child: SingleChildScrollView(
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
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Color getRandomColor() {
    // Define a function to generate random colors
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  IconData getIconForCategory(String category) {
    // Define a function to map category names to corresponding icons
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Clothing':
        return Icons.shopping_bag_outlined;
      case 'Transportation':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie_filter;
      case 'Others':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}
