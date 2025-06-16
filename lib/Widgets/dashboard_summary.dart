import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_state.dart'; // path where you keep DashboardState

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardState>(context);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Total Balance', dashboard.total, isMain: true),
            const Divider(),
            _buildRow('Income', dashboard.income, color: Colors.green),
            _buildRow('Expenses', dashboard.expenses, color: Colors.red),
            _buildRow('Split To Pay (You Owe)', dashboard.splitToPay,
                color: Colors.orange),
            _buildRow('Split Owed (You Are Owed)', dashboard.splitOwed,
                color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount,
      {Color? color, bool isMain = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isMain ? 18 : 14,
                  fontWeight: isMain ? FontWeight.bold : FontWeight.normal)),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isMain ? 18 : 14,
              fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
