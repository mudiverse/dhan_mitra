import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/group_payment_models/group_models.dart';

class GroupRepository {
  final _groupCollection = FirebaseFirestore.instance.collection('groups');

  Future<List<GroupModel>> fetchGroups() async {  //fetch the group Data
    try {
      final snapshot = await _groupCollection.get();
      return snapshot.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch groups: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching groups: $e');
    }
  }

  Future<void> addGroup(GroupModel group) async {   //adds a new group to collection with new Group id
    try {
      await _groupCollection.doc(group.id).set(group.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to add group: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while adding group: $e');
    }
  }

  Future<void> updateGroupTransactions(String groupId, String txnId) async {
    try {
      final doc = _groupCollection.doc(groupId);
      await doc.update({                              // adds Updates grops tranasctions updates the arr of txn'S
        'transactionIds': FieldValue.arrayUnion([txnId]),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update group transactions: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while updating group transactions: $e');
    }
  }
}
