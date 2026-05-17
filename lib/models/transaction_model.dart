import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String customerId;
  final String staffId;
  final double amount;
  final double liters;
  final DateTime timestamp;
  final String status;
  final String type; // 'refill' or 'topup'

  TransactionModel({
    required this.id,
    required this.customerId,
    required this.staffId,
    required this.amount,
    required this.liters,
    required this.timestamp,
    this.status = 'success',
    this.type = 'refill',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'staffId': staffId,
      'amount': amount,
      'liters': liters,
      'timestamp': timestamp,
      'status': status,
      'type': type,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    if (map['timestamp'] is Timestamp) {
      parsedDate = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      parsedDate = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      staffId: map['staffId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      liters: (map['liters'] ?? 0.0).toDouble(),
      timestamp: parsedDate,
      status: map['status'] ?? 'success',
      type: map['type'] ?? 'refill',
    );
  }
}
