import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/multi_transaction_model.dart';

class SplitTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'transactions';

  Future<String> createSplitTransaction({
    required String title,
    required double amount,
    required String paidBy,
    required List<String> participants,
    required Map<String, double> splitDetails,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      
      final transaction = MultiTransactionModel(
        id: docRef.id,
        title: title,
        amount: amount,
        category: 'split',
        date: DateTime.now(),
        paidBy: paidBy,
        participants: participants,
        splitDetails: splitDetails,
        settledUsers: [], // Initialize with empty list
        groupId: '', // Empty for non-group splits
        createdAt: DateTime.now(),
      );

      await docRef.set(transaction.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create split transaction: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while creating split transaction: $e');
    }
  }

  Stream<List<MultiTransactionModel>> getPendingSplits(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    
    try {
      return _firestore
          .collection(_collection)
          .where('category', isEqualTo: 'split')
          .where('participants', arrayContains: userId)
          .where('paidBy', isNotEqualTo: userId)
          .orderBy('paidBy')
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) => MultiTransactionModel.fromMap(doc.data()))
                  .toList();
            } catch (e) {
              print('Error parsing pending splits: $e');
              return [];
            }
          });
    } catch (e) {
      print('Error in getPendingSplits: $e');
      return Stream.value([]);
    }
  }

  Stream<List<MultiTransactionModel>> getOwedSplits(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: 'split')
        .where('paidBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => MultiTransactionModel.fromMap(doc.data()))
                .toList();
          } catch (e) {
            print('Error parsing owed splits: $e');
            return [];
          }
        });
  }

  Future<void> settleSplit(String transactionId) async {
    if (transactionId.isEmpty) return;
    
    try {
      await _firestore
          .collection(_collection)
          .doc(transactionId)
          .update({'status': 'settled'});
    } catch (e) {
      throw Exception('Failed to settle split: $e');
    }
  }

  Future<void> toggleUserSettlement(String transactionId, String userId) async {
    if (transactionId.isEmpty || userId.isEmpty) return;
    
    try {
      final docRef = _firestore.collection(_collection).doc(transactionId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Transaction not found');
      }

      final data = doc.data()!;
      final settledUsers = List<String>.from(data['settledUsers'] ?? []);
      
      if (settledUsers.contains(userId)) {
        settledUsers.remove(userId);
      } else {
        settledUsers.add(userId);
      }

      await docRef.update({'settledUsers': settledUsers});
    } catch (e) {
      throw Exception('Failed to toggle settlement: $e');
    }
  }

  Future<void> settleAllUsers(String transactionId) async {
    if (transactionId.isEmpty) return;
    
    try {
      final docRef = _firestore.collection(_collection).doc(transactionId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Transaction not found');
      }

      final data = doc.data()!;
      final participants = List<String>.from(data['participants'] ?? []);
      
      await docRef.update({'settledUsers': participants});
    } catch (e) {
      throw Exception('Failed to settle all users: $e');
    }
  }
}