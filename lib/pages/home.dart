import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cashswift/components/app_bar.dart';
import 'package:cashswift/pages/loadmoney.dart';
import 'package:cashswift/pages/sendmoney.dart';
import 'package:cashswift/pages/transactions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(),
      body: Center(
        child: Container(
          width: double.maxFinite,
          height: 250,
          child: Card(
            color: Theme.of(context).colorScheme.tertiary,
            margin: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.maxFinite,
              height: 200,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final balance = userData['balance'] ?? 0;

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₹$balance',
                            style: const TextStyle(fontSize: 45),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    title: const Text('Scan QR Code'),
                                    content: Center(
                                      child: SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: QrImageView(
                                          data: userData['upiId'],
                                          version: QrVersions.auto,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Reveal QR Code',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
