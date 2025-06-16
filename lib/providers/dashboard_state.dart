import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/multi_transaction_model.dart';
import 'package:dhan_mitra_final/models/transaction_model.dart';
import 'package:flutter/foundation.dart';

class DashboardState extends ChangeNotifier {
  double total = 0.0;
  double expenses = 0.0;
  double income = 0.0;
  double splitToPay = 0.0;
  double splitOwed = 0.0;

  bool isLoading = false;
  String errorMessage = '';

  List<TransactionModel> userTransactions = [];
  List<MultiTransactionModel> allSplits = [];

  /// Main load function
  Future<void> loadDashboardData(String userId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Fetch personal income/expenses
      final userTxSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      userTransactions = userTxSnapshot.docs
          .map((doc) {
            try {
              return TransactionModel.fromMap(doc.data());
            } catch (e) {
              print("Error parsing TransactionModel: $e");
              return null;
            }
          })
          .whereType<TransactionModel>()
          .toList();

      income = userTransactions
          .where((tx) => tx.type == 'income')
          .fold(0.0, (sum, tx) => sum + tx.amount);

      expenses = userTransactions
          .where((tx) => tx.type == 'expense')
          .fold(0.0, (sum, tx) => sum + tx.amount);

      // Fetch split transactions
      final splitTxSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('participants', arrayContains: userId)
          .get();

      allSplits = splitTxSnapshot.docs
          .map((doc) {
            try {
              return MultiTransactionModel.fromMap(doc.data());
            } catch (e) {
              print("Error parsing MultiTransactionModel: $e");
              return null;
            }
          })
          .whereType<MultiTransactionModel>()
          .toList();

      splitToPay = 0.0;
      splitOwed = 0.0;
      double owedDelta = 0.0;
      double toPayDelta = 0.0;

      for (var tx in allSplits) {
        if (!tx.participants.contains(userId)) continue;

        final myShare = tx.splitDetails[userId] ?? 0.0;
        final isSettled = tx.settledUsers.contains(userId);

        if (tx.paidBy == userId) {
          // Owed to me
          final delta = tx.amount - myShare;
          if (isSettled) {
            splitOwed += delta;
            owedDelta += delta;
          } else {
            splitOwed -= delta;
            owedDelta -= tx.amount;
          }
        } else {
          // I owe someone
          if (isSettled) {
            splitToPay += myShare;
            toPayDelta -= myShare;
          } else {
            splitToPay -= myShare;
          }
        }
      }

      total = income - expenses + owedDelta + toPayDelta;
    } catch (e) {
      print("🔥 Error loading dashboard data: $e");
      errorMessage = 'Failed to load data. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Called when a pending split (you owe) is toggled settled/unsettled
  void updatePendingSplit(double myShare, bool isSettled) {
    if (isSettled) {
      // I just paid my share
      splitToPay += myShare;

      total -= myShare;
    } else {
      // I haven't paid yet; expected to pay
      splitToPay -= myShare;
      // total unchanged
    }
    notifyListeners();
  }

  /// Called when an owed split (others owe you) is toggled
  void updateOwedSplit(double amount, bool isSettled) {
    if (isSettled) {
      splitOwed += amount;
      total += amount;
    } else {
      //others share
      splitOwed -= amount;
      total -= amount;
    }
    notifyListeners();
  }
}
