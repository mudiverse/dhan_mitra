import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_state.dart';
import '../services/split_transaction_service.dart';
import '../providers/app_state.dart';

class SplitSummaryCard extends StatefulWidget {
  final String title;
  final double amount;
  final Map<String, double> userIds;
  final String paidBy;
  final String currentUserId;
  final DashboardState dashboardState;
  final String transactionId;
  final List<String> settledUsers;
  final String groupId;

  const SplitSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.userIds,
    required this.paidBy,
    required this.currentUserId,
    required this.dashboardState,
    required this.transactionId,
    required this.settledUsers,
    this.groupId = '',
  });

  @override
  State<SplitSummaryCard> createState() => _SplitSummaryCardState();
}

class _SplitSummaryCardState extends State<SplitSummaryCard> {
  late bool isPending; // true if user needs to pay, false if user is owed
  late bool isSettled; // true if the split is marked as settled
  final SplitTransactionService _splitService = SplitTransactionService();

  @override
  void initState() {
    super.initState();
    isPending = widget.paidBy != widget.currentUserId;
    isSettled = widget.settledUsers.contains(widget.currentUserId);
  }

  void _toggleSwitch(bool value) async {
    try {
      await _splitService.toggleUserSettlement(
          widget.transactionId, widget.currentUserId);
      setState(() {
        isSettled = value;
      });

      // Update DashboardState accordingly
      final myShare = widget.userIds[widget.currentUserId] ?? 0.0;
      if (isPending) {
        widget.dashboardState.updatePendingSplit(myShare, isSettled);
      } else {
        final othersShare = widget.amount - myShare;
        widget.dashboardState.updateOwedSplit(othersShare, isSettled);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settlement: $e')),
      );
    }
  }

  Future<void> _toggleOtherUserSettlement(String userId, bool value) async {
    try {
      await _splitService.toggleUserSettlement(widget.transactionId, userId);
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
    Color switchColor;
    Color labelColor;
    String labelText;
    if (isPending) {
      labelText = isSettled ? 'Settled' : 'Pending (You need to pay)';
      labelColor = isSettled ? Colors.green : Colors.red;
      switchColor = isSettled ? Colors.green : Colors.red;
    } else {
      labelText = isSettled ? 'Settled' : 'Pending payment by others';
      labelColor = isSettled ? Colors.green : Colors.purple;
      switchColor = isSettled ? Colors.green : Colors.purple;
    }

    final isAllSettled = widget.userIds.keys
        .every((userId) => widget.settledUsers.contains(userId));

    final group = widget.groupId.isNotEmpty
        ? context.watch<AppState>().getGroupById(widget.groupId)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [switchColor.withOpacity(0.15), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isAllSettled)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                          ],
                        ),
                        if (group != null)
                          Text(
                            'Group: ${group.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        labelText,
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: isSettled,
                        onChanged: _toggleSwitch,
                        activeColor: switchColor,
                        inactiveTrackColor: switchColor.withOpacity(0.3),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "₹${widget.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Paid by: ${widget.paidBy}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 12),
              const Text(
                "Split Details:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...widget.userIds.entries.map((entry) {
                final isUserSettled = widget.settledUsers.contains(entry.key);
                final isCurrentUser = entry.key == widget.currentUserId;
                final canToggle =
                    !isCurrentUser && (widget.currentUserId == widget.paidBy);
                final isPending = widget.paidBy != widget.currentUserId;

                // For pending splits, only show current user's details
                if (isPending && !isCurrentUser) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            isCurrentUser ? 'You' : entry.key,
                            style: TextStyle(
                              fontSize: 12,
                              color: isUserSettled ? Colors.green : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (isUserSettled)
                            const Icon(Icons.check_circle,
                                size: 14, color: Colors.green),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${entry.value.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isUserSettled ? Colors.green : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (canToggle)
                            Switch(
                              value: isUserSettled,
                              onChanged: (value) =>
                                  _toggleOtherUserSettlement(entry.key, value),
                              activeColor: Colors.green,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
