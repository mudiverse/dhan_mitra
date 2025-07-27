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
  bool _isLoading = false;

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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (groupName.trim().isNotEmpty) {
              setState(() => _isLoading = true);
              
              try {
                final group = GroupModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: groupName.trim(),
                  members: [],
                );
                
                await context.read<AppState>().addNewGroup(group, creatorUserId: currentUserId);
                
                if (!mounted) return;
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error creating group: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            }
          },
          child: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Create'),
        ),
      ],
    );
  }
}
