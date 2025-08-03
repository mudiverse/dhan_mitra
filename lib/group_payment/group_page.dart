import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_payment_models/group_models.dart';
import '../../models/group_payment_models/split_payment_model.dart';
import '../../models/multi_transaction_model.dart';
import '../../providers/app_state.dart';
import '../../group_payment/add_split_dialog.dart';
import '../../group_payment/group_based_widgets/split_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared_split_dialog.dart';
import '../../services/split_transaction_service.dart';

class GroupPage extends StatefulWidget {
  final GroupModel group;
  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<SplitPaymentModel> splits = [];
  final SplitTransactionService _splitService = SplitTransactionService();

  // Helper method to get short user ID
  String getShortUserId(String uid) {
    return uid.length >= 6 ? uid.substring(0, 6) : uid;
  }

  @override
  void initState() {
    super.initState();
    _loadSplits();
  }

  Future<void> _loadSplits() async {
    // Get transactions for this group (already filtered by user access)
    final transactions = context.read<AppState>().getTransactionsByGroup(widget.group.id);
    
    // Convert MultiTransactionModel to SplitPaymentModel
    setState(() {
      splits = transactions.map((txn) => SplitPaymentModel(
        title: txn.title,
        totalAmount: txn.amount,
        userSplits: txn.splitDetails,
        paidBy: txn.paidBy,
      )).toList();
    });
  }

  void _addUserDialog() {
    String userId = '';
    final currentUserId = getShortUserId(FirebaseAuth.instance.currentUser?.uid ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'User ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          onChanged: (val) => userId = val.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (userId.isNotEmpty && !widget.group.members.contains(userId)) {
                final updatedGroup = GroupModel(
                  id: widget.group.id,
                  name: widget.group.name,
                  members: [...widget.group.members, userId],
                  transactionIds: widget.group.transactionIds,
                );
                await context.read<AppState>().addNewGroup(updatedGroup, creatorUserId: currentUserId);
                // Reload user groups to reflect the changes
                await context.read<AppState>().loadUserGroups(currentUserId);
                setState(() {
                  widget.group.members.add(userId);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSplit(SplitPaymentModel split) async {
    // Create a MultiTransactionModel from the split
    final txn = MultiTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: split.title,
      amount: split.totalAmount,
      category: 'split',
      date: DateTime.now(),
      paidBy: split.paidBy,
      participants: split.userSplits.keys.toList(),
      splitDetails: split.userSplits,
      settledUsers: [], // Initialize with empty list
      groupId: widget.group.id,
      createdAt: DateTime.now(),
    );

    // Save to Firebase
    await context.read<AppState>().addTransactionAndUpdateGroup(txn);
    
    // Reload splits after adding new one
    await _loadSplits();
  }

  Future<void> _handleSettlementToggle(String transactionId, String userId) async {
    try {
      await _splitService.toggleUserSettlement(transactionId, userId);
      // Reload splits to reflect the changes
      await _loadSplits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating settlement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = getShortUserId(FirebaseAuth.instance.currentUser?.uid ?? '');
    final group = context.watch<AppState>().getGroupById(widget.group.id);
    final theme = Theme.of(context);
    
    // Check if user is a member of this group
    if (group == null || !group.members.contains(currentUserId)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'You are not a member of this group.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    
    final transactions = context.watch<AppState>().getTransactionsByGroup(widget.group.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          group.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadSplits();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addUserDialog,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Members',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: group.members.map((member) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            member,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSplits,
              child: transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No splits yet",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (_, index) {
                        final txn = transactions[index];
                        final split = SplitPaymentModel(
                          title: txn.title,
                          totalAmount: txn.amount,
                          userSplits: txn.splitDetails,
                          paidBy: txn.paidBy,
                        );
                        return SplitCard(
                          split: split,
                          transactionId: txn.id,
                          settledUsers: txn.settledUsers,
                          onSettlementToggle: _handleSettlementToggle,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final currentUserId = getShortUserId(FirebaseAuth.instance.currentUser?.uid ?? '');
          final participants = <String>{if (currentUserId.isNotEmpty) currentUserId, ...group.members}.toList();
          final split = await showDialog(
            context: context,
            builder: (_) => SharedSplitDialog(
              participants: participants,
              initialPayer: currentUserId,
              showAddParticipantSection: false,
            ),
          );
          if (split != null) {
            await _addSplit(split);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
      ),
    );
  }
}
