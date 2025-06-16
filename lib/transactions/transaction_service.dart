// will handle add and delete data to the DataBase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/transaction_model.dart';

import 'package:firebase_auth/firebase_auth.dart';

// Custom exception for transaction errors
class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);
  @override
  String toString() => 'TransactionException: $message';
}

class TransactionService {
  // Getting the current user
  String get uid {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw TransactionException('User not authenticated');
      }
      return user.uid;
    } catch (e) {
      throw TransactionException('Failed to get user ID: ${e.toString()}');
    }
  }

  final _collection = FirebaseFirestore.instance.collection('users');

  // Add transaction function with error handling
  Future<void> addTransaction(TransactionModel txn) async {
    try {
      // Input validation
      if (txn.amount <= 0) {
        throw TransactionException('Amount must be greater than 0');
      }
      if (txn.title.isEmpty) {
        throw TransactionException('Title cannot be empty');
      }
      if (txn.type.isEmpty) {
        throw TransactionException('Type cannot be empty');
      }

      final doc = _collection.doc(uid).collection('transactions').doc();
      await doc.set(txn.copyWith(id: doc.id).toMap());
    } on FirebaseException catch (e) {
      throw TransactionException('Failed to add transaction: ${e.message}');
    } catch (e) {
      throw TransactionException('Unexpected error: ${e.toString()}');
    }
  }

  // Delete transaction with error handling
  Future<void> deleteTransaction(String txnId) async {
    try {
      if (txnId.isEmpty) {
        throw TransactionException('Transaction ID cannot be empty');
      }

      final docRef = _collection.doc(uid).collection('transactions').doc(txnId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw TransactionException('Transaction not found');
      }

      await docRef.delete();
    } on FirebaseException catch (e) {
      throw TransactionException('Failed to delete transaction: ${e.message}');
    } catch (e) {
      throw TransactionException('Unexpected error: ${e.toString()}');
    }
  }

  // Get transactions with error handling
  Stream<List<TransactionModel>> getTransactions(String type) {
    try {
      if (type.isEmpty) {
        throw TransactionException('Type cannot be empty');
      }

      return _collection
          .doc(uid)
          .collection('transactions')
          .where('type', isEqualTo: type)
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) => TransactionModel.fromMap(doc.data()))
                  .toList();
            } catch (e) {
              throw TransactionException('Failed to parse transaction data: ${e.toString()}');
            }
          });
    } catch (e) {
      throw TransactionException('Failed to get transactions: ${e.toString()}');
    }
  }
}
