import 'package:flutter/material.dart';

class SplitsPage extends StatefulWidget {
  const SplitsPage({super.key});

  @override
  State<SplitsPage> createState() => _SplitsPageState();
}

class _SplitsPageState extends State<SplitsPage> {
  // Now using a list of maps to store expense and amount separately
  List<Map<String, String>> expenses = [
    {'title': 'Groceries', 'amount': '₹250'},
    {'title': 'Electricity', 'amount': '₹120'},
    {'title': 'Internet', 'amount': '₹99'},
  ];

  void _addExpense() {
    String newTitle = "";
    String newAmount = "";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Splits"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Avoid overflow
            children: [
              TextField(
                decoration:
                    const InputDecoration(hintText: "Enter Splits "),
                onChanged: (value) => newTitle = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration:
                    const InputDecoration(hintText: "Enter amount "),
                keyboardType: TextInputType.number,
                onChanged: (value) => newAmount = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty && newAmount.trim().isNotEmpty) {
                  setState(() {
                    expenses.add({
                      'title': newTitle.trim(),
                      'amount': '₹${newAmount.trim()}',
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _removeExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Splits")),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            title: Text(
              expense['title'] ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text(
              "Amount: ${expense['amount']}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeExpense(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
