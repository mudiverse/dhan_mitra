import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/transaction_model.dart';
import 'package:dhan_mitra_final/transactions/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TransactionService _txnService = TransactionService();
  bool _isLoading = false;
  String? _errorMessage;
  


  void _addExpense() {
    String newTitle = "";
    String newAmount = "";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: "Enter expense title",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => newTitle = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Enter amount spent",
                  border: OutlineInputBorder(),
                  prefixText: "₹",
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => newAmount = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (newTitle.trim().isEmpty) {
                    throw ArgumentError('Title cannot be empty');
                  }

                  final amount = double.tryParse(newAmount);
                  if (amount == null || amount <= 0) {
                    throw ArgumentError('Please enter a valid amount');
                  }

                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  final newTxn = TransactionModel(
                    id: '',
                    amount: amount,
                    title: newTitle.trim(),
                    type: 'expense',
                    time: Timestamp.now(),
                  );

                  await _txnService.addTransaction(newTxn);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExpense(String txnId) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _txnService.deleteTransaction(txnId);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          StreamBuilder<List<TransactionModel>>(
            stream: _txnService.getTransactions('expense'),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final expenses = snapshot.data!;

              if (expenses.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No expenses yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final txn = expenses[index];
                  return Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.receipt,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        txn.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '- ₹${txn.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy, hh:mm a')
                                .format(txn.time.toDate()),
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () => _deleteExpense(txn.id),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addExpense,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
