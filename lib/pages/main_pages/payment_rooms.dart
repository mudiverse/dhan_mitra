import 'package:dhan_mitra_final/group_payment/add_group_dialog.dart';
import 'package:dhan_mitra_final/group_payment/group_based_widgets/group_card.dart';
import 'package:dhan_mitra_final/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentRoomsPage extends StatelessWidget {
  const PaymentRoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Groups",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: appState.groups.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No groups yet",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create a group to start splitting expenses",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: appState.groups.length,
              itemBuilder: (_, index) => GroupCard(group: appState.groups[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddGroupDialog());
        },
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
    );
  }
}