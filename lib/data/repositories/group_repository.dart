import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhan_mitra_final/models/group_payment_models/group_models.dart';

class GroupRepository {
  final _groupCollection = FirebaseFirestore.instance.collection('groups');

  Future<List<GroupModel>> fetchGroups() async {  //fetch the group Data
    final snapshot = await _groupCollection.get();
    return snapshot.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
  }

  Future<void> addGroup(GroupModel group) async {   //adds a new group to collection with new Group id
    await _groupCollection.doc(group.id).set(group.toMap());
  }

  Future<void> updateGroupTransactions(String groupId, String txnId) async {
    final doc = _groupCollection.doc(groupId);
    await doc.update({                              // adds Updates grops tranasctions updates the arr of txn'S
      'transactionIds': FieldValue.arrayUnion([txnId]),
    });
  }
}
