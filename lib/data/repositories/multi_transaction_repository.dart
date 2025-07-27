import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/multi_transaction_model.dart';

class TransactionRepository {
  final _txnCollection = FirebaseFirestore.instance.collection('transactions');

  Future<void> addTransaction(MultiTransactionModel txn) async {
    try {
      await _txnCollection.doc(txn.id).set(txn.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to add transaction: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while adding transaction: $e');
    }
  }

  Future<List<MultiTransactionModel>> fetchGroupTransactions(
      String groupId) async {
    try {
      final snapshot =
          await _txnCollection.where('groupId', isEqualTo: groupId).get();
      return snapshot.docs
          .map((doc) => MultiTransactionModel.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch group transactions: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching group transactions: $e');
    }
  }
}
