import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/transaction_model.dart';
import 'package:dhan_mitra_final/transactions/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TransactionService _txnService = TransactionService();
  bool _isLoading = false;
  String? _errorMessage;

  void _addIncome() {
    String newTitle = "";
    String newAmount = "";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Income"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: "Enter income source",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => newTitle = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Enter amount received",
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
                    throw ArgumentError('Income source cannot be empty');
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
                    type: 'income',
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

  Future<void> _deleteIncome(String txnId) async {
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
        title: const Text("Income"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          StreamBuilder<List<TransactionModel>>(
            stream: _txnService.getTransactions('income'),
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

              final incomes = snapshot.data!;

              if (incomes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No income recorded yet',
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
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final txn = incomes[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
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
                            '+ ₹${txn.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy, hh:mm a')
                                .format(txn.time.toDate()),
                            style: const TextStyle(
                              color: Colors.purpleAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _deleteIncome(txn.id),
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
        onPressed: _isLoading ? null : _addIncome,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
