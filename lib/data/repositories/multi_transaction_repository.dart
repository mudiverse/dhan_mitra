import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/multi_transaction_model.dart';

class TransactionRepository {
  final _txnCollection = FirebaseFirestore.instance.collection('transactions');

  Future<void> addTransaction(MultiTransactionModel txn) async {
    await _txnCollection.doc(txn.id).set(txn.toMap());
  }

  Future<List<MultiTransactionModel>> fetchGroupTransactions(
      String groupId) async {
    final snapshot =
        await _txnCollection.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs
        .map((doc) => MultiTransactionModel.fromMap(doc.data()))
        .toList();
  }
}
