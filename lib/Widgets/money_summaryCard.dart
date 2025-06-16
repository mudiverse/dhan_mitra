import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoneySummaryCard extends StatelessWidget {
  final String userId;
  final String label;

  const MoneySummaryCard(
      {super.key, required this.userId, required this.label});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: _fetchCombinedTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text("Error loading transactions");
        }

        final transactions = snapshot.data!;
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...transactions.map((tx) => _buildTransactionRow(tx)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionRow(Transaction tx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            tx.isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
            color: tx.isIncoming ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(tx.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(tx.description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Text(
            '${tx.isIncoming ? '+' : '-'}₹${tx.amount}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: tx.isIncoming ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Transaction {
  final DateTime date;
  final String description;
  final double amount;
  final bool isIncoming;

  Transaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.isIncoming,
  });
}

/// Fetches both single-user and split transactions and merges them
Future<List<Transaction>> _fetchCombinedTransactions(String userId) async {
  List<Transaction> finalList = [];

  try {
    /// Fetch single-user transactions (personal)
    final userTxSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

    final personalTransactions = userTxSnapshot.docs.map((doc) {
      final data = doc.data();
      return Transaction(
        date: (data['time'] as Timestamp).toDate(),
        description: data['title'] ?? 'Transaction',
        amount: data['amount']?.toDouble() ?? 0.0,
        isIncoming: (data['type'] ?? '').toLowerCase() == 'income',
      );
    });

    finalList.addAll(personalTransactions);
  } catch (e) {
    print("Error fetching user transactions: $e");
  }

  try {
    /// Fetch multi-user transactions (split) without orderBy
    final splitSnap = await FirebaseFirestore.instance
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .get();

    final splitTransactions = splitSnap.docs.map((doc) {
      final data = doc.data();
      final paidBy = data['paidBy'];
      final splitDetails =
          Map<String, dynamic>.from(data['splitDetails'] ?? {});
      final double myShare = (splitDetails[userId] ?? 0).toDouble();
      final double total = data['amount']?.toDouble() ?? 0.0;
      final isPayer = paidBy == userId;
      final DateTime date = (data['date'] as Timestamp).toDate();

      return Transaction(
        date: date,
        description: "[Split] ${data['title'] ?? 'Transaction'}",
        amount: isPayer ? (total - myShare) : myShare,
        isIncoming: isPayer,
      );
    });

    finalList.addAll(splitTransactions);
  } catch (e) {
    print("Error fetching split transactions: $e");
  }

  /// Sort by date descending (newest first)
  finalList.sort((a, b) => b.date.compareTo(a.date));
  finalList.take(10).toList();

  return finalList;
}
