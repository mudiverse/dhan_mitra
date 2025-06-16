import 'package:dhan_mitra_final/models/group_payment_models/split_payment_model.dart';
import 'package:flutter/material.dart';
// import 'package:dhan_mitra/models/group_payment_models/split_payment_model.dart';

class SplitCard extends StatelessWidget {
  final SplitPaymentModel split;
  final String transactionId;
  final List<String> settledUsers;
  final Function(String, String) onSettlementToggle;

  const SplitCard({
    super.key, 
    required this.split,
    required this.transactionId,
    required this.settledUsers,
    required this.onSettlementToggle,
  });

  /// Format userId to display — will be replaced with real names in future
  String getDisplayName(String userId) {
    return '($userId)';
  }

  @override
  Widget build(BuildContext context) {
    final isAllSettled = split.userSplits.keys.every(
      (userId) => settledUsers.contains(userId)
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.receipt_long_rounded,
          color: isAllSettled ? Colors.green : Colors.teal,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                split.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isAllSettled)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
        subtitle: Text(
          'Paid by ${getDisplayName(split.paidBy)} • ₹${split.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        children: [
          const Divider(thickness: 1, indent: 16, endIndent: 16),
          ...split.userSplits.entries.map((entry) {
            final userId = entry.key;
            final amount = entry.value;
            final isPayer = userId == split.paidBy;
            final isSettled = settledUsers.contains(userId);

            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline),
                  if (isSettled)
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ),
              title: Text(
                getDisplayName(userId),
                style: TextStyle(
                  fontSize: 14,
                  color: isSettled ? Colors.green : null,
                ),
              ),
              trailing: Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isPayer ? Colors.green : (isSettled ? Colors.green : Colors.black87),
                  fontWeight: isPayer ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
