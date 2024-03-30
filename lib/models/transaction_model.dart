import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
  });
}


