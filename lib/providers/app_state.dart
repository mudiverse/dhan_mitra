import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dhan_mitra_final/models/group_payment_models/group_models.dart';
import 'package:dhan_mitra_final/models/multi_transaction_model.dart';

import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<GroupModel> groups = [];
  List<MultiTransactionModel> transactions = [];
  String? currentUserId;

  // DEPRECATED: Use loadUserGroups() instead for proper access control
  Future<void> loadGroups() async {
    throw UnsupportedError('Use loadUserGroups() instead for proper access control');
  }

  // DEPRECATED: Use loadUserTransactions() instead for proper access control
  Future<void> loadTransactions() async {
    throw UnsupportedError('Use loadUserTransactions() instead for proper access control');
  }

  // Load only transactions where the user is a participant
  Future<void> loadUserTransactions(String userId) async {
    try {
      final snapshot = await _firestore.collection('transactions')
          .where('participants', arrayContains: userId)
          .get();
      transactions = snapshot.docs.map((doc) => MultiTransactionModel.fromMap(doc.data())).toList();
      currentUserId = userId;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user transactions: $e');
      rethrow;
    }
  }

  Future<void> addTransactionAndUpdateGroup(MultiTransactionModel txn) async {
    await _firestore.collection('transactions').doc(txn.id).set(txn.toMap());

    final groupRef = _firestore.collection('groups').doc(txn.groupId);
    await groupRef.update({
      'transactionIds': FieldValue.arrayUnion([txn.id])
    });

    transactions.add(txn);
    notifyListeners();
  }

  Future<void> addNewGroup(GroupModel group, {required String creatorUserId}) async {
    try {
      // Ensure creator is in the members list (no duplicates)
      final members = Set<String>.from(group.members)..add(creatorUserId);
      final updatedGroup = GroupModel(
        id: group.id,
        name: group.name,
        members: members.toList(),
        transactionIds: group.transactionIds,
      );
      await _firestore.collection('groups').doc(group.id).set(updatedGroup.toMap());
      groups.add(updatedGroup);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding new group: $e');
      rethrow;
    }
  }

  List<MultiTransactionModel> getTransactionsByGroup(String groupId) {
    // Only return transactions if user is a member of the group
    final group = getGroupById(groupId);
    if (group == null || currentUserId == null || !group.members.contains(currentUserId)) {
      return [];
    }
    return transactions.where((txn) => txn.groupId == groupId).toList();
  }

  GroupModel? getGroupById(String groupId) {
    return groups.firstWhere((g) => g.id == groupId, orElse: () => GroupModel(id: '', name: '', members: []));
  }

  // Fetch only groups where the user is a member
  Future<void> loadUserGroups(String userId) async {
    try {
      final snapshot = await _firestore.collection('groups')
        .where('members', arrayContains: userId)
        .get();
      groups = snapshot.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
      currentUserId = userId;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user groups: $e');
      rethrow;
    }
  }
}

