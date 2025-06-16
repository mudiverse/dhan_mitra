import 'package:cloud_firestore/cloud_firestore.dart';
//Single User transactions
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; //expense or income // or others later
  final Timestamp time;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.title,
    required this.type,
    required this.time,
  }) {
    // Validate input parameters

    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    Timestamp? time,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'time': time,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    try {
      // Validate required fields
      // if (!map.containsKey('id') || map['id'] == null) {
      //   throw ArgumentError('Transaction ID is required');
      // }
      if (!map.containsKey('title') || map['title'] == null) {
        throw ArgumentError('Title is required');
      }
      if (!map.containsKey('amount') || map['amount'] == null) {
        throw ArgumentError('Amount is required');
      }
      if (!map.containsKey('type') || map['type'] == null) {
        throw ArgumentError('Type is required');
      }
      // if (!map.containsKey('time') || map['time'] == null) {
      //   throw ArgumentError('Time is required');
      // }

      return TransactionModel(
        id: map['id'].toString(),
        amount: (map['amount'] as num).toDouble(),
        title: map['title'].toString(),
        type: map['type'].toString(),
        time: map['time'] as Timestamp,
      );
    } catch (e) {
      throw ArgumentError(
          'Failed to create TransactionModel from map: ${e.toString()}');
    }
  }
}
