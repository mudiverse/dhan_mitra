import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_payment_models/group_models.dart';
import '../../providers/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
//adds the gruop name 
class AddGroupDialog extends StatefulWidget {
  const AddGroupDialog({super.key});

  @override
  _AddGroupDialogState createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  String groupName = '';

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return AlertDialog(
      title: const Text('Create New Group'),
      content: TextField(
        decoration: const InputDecoration(labelText: 'Group Name'),
        onChanged: (value) => groupName = value,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (groupName.trim().isNotEmpty) {
              final group = GroupModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: groupName.trim(),
                members: [],
              );
              try {
                await context.read<AppState>().addNewGroup(group, creatorUserId: currentUserId);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating group: $e')),
                );
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
