import 'package:cloud_firestore/cloud_firestore.dart';
//Multi user Transactions for normal and group Split payments
class MultiTransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String paidBy;
  final List<String> participants;
  final Map<String, double> splitDetails;
  final List<String> settledUsers;
  final String groupId;
  final DateTime createdAt;

  MultiTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paidBy,
    required this.participants,
    required this.splitDetails,
    required this.settledUsers,
    required this.groupId,
    required this.createdAt,
  });

  factory MultiTransactionModel.fromMap(Map<String, dynamic> map) =>
      MultiTransactionModel(
        id: map['transactionId'],
        title: map['title'],
        amount: map['amount'].toDouble(),
        category: map['category'],
        date: (map['date'] as Timestamp).toDate(),
        paidBy: map['paidBy'],
        participants: List<String>.from(map['participants']),
        splitDetails: Map<String, double>.from(map['splitDetails']),
        settledUsers: List<String>.from(map['settledUsers'] ?? []),
        groupId: map['groupId'],
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'transactionId': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': Timestamp.fromDate(date),
        'paidBy': paidBy,
        'participants': participants,
        'splitDetails': splitDetails,
        'settledUsers':settledUsers,
        'groupId': groupId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

}
