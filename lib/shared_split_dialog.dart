import 'package:flutter/material.dart';
import 'models/group_payment_models/split_payment_model.dart';

class SharedSplitDialog extends StatefulWidget {
  final List<String> participants;
  final String? initialPayer;
  final String? initialTitle;
  final double? initialAmount;
  final bool showAddParticipantSection;

  const SharedSplitDialog({
    super.key,
    required this.participants,
    this.initialPayer,
    this.initialTitle,
    this.initialAmount,
    this.showAddParticipantSection = false,
  });

  @override
  State<SharedSplitDialog> createState() => _SharedSplitDialogState();
}

class _SharedSplitDialogState extends State<SharedSplitDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _newUserIdController = TextEditingController();
  final _newUserAmountController = TextEditingController();

  bool isCustom = false;
  late Map<String, double> _dialogSplitDetails;
  late Map<String, double> customSplits;
  String selectedPayer = '';

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _amountController.text = widget.initialAmount?.toString() ?? '';

    _dialogSplitDetails = {};
    customSplits = {};

    for (var user in widget.participants) {
      _dialogSplitDetails[user] = 0.0;
      customSplits[user] = 0.0;
    }

    if (widget.initialPayer != null && widget.participants.contains(widget.initialPayer)) {
      selectedPayer = widget.initialPayer!;
    } else if (widget.participants.isNotEmpty) {
      selectedPayer = widget.participants.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _newUserIdController.dispose();
    _newUserAmountController.dispose();
    super.dispose();
  }

  void _addNewParticipant() {
    final userId = _newUserIdController.text.trim();
    final amount = double.tryParse(_newUserAmountController.text.trim());

    if (userId.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid user ID and amount')),
      );
      return;
    }

    const maxParticipants = 4;
    if (_dialogSplitDetails.length >= maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $maxParticipants users allowed')),
      );
      return;
    }

    if (_dialogSplitDetails.containsKey(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User already added')),
      );
      return;
    }

    setState(() {
      _dialogSplitDetails[userId] = amount;
      if (isCustom) {
        customSplits[userId] = amount;
      }
      _newUserIdController.clear();
      _newUserAmountController.clear();

      if (selectedPayer.isEmpty && _dialogSplitDetails.isNotEmpty) {
        selectedPayer = _dialogSplitDetails.keys.first;
      }
    });
  }

  void _submit() {
    final total = double.tryParse(_amountController.text) ?? 0.0;
    final title = _titleController.text.trim();

    if (title.isEmpty || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid title and amount")),
      );
      return;
    }

    if (selectedPayer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select who paid")),
      );
      return;
    }

    Map<String, double> splits = {};
    if (isCustom) {
      final sum = customSplits.values.fold(0.0, (a, b) => a + b);
      if ((sum - total).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Split amount doesn't match total")),
        );
        return;
      }
      splits = Map.from(customSplits);
    } else {
      if (_dialogSplitDetails.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Add at least one participant for equal split")),
        );
        return;
      }
      final splitAmt = total / _dialogSplitDetails.length;
      for (var user in _dialogSplitDetails.keys) {
        splits[user] = splitAmt;
      }
    }

    final split = SplitPaymentModel(
      title: title,
      totalAmount: total,
      userSplits: splits,
      paidBy: selectedPayer,
    );

    Navigator.pop(context, split);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Split'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              readOnly: widget.initialTitle != null,
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number,
              readOnly: widget.initialAmount != null,
            ),
            DropdownButtonFormField<String>(
              value: selectedPayer,
              decoration: const InputDecoration(labelText: 'Paid By'),
              items: _dialogSplitDetails.keys.map((user) {
                return DropdownMenuItem(
                  value: user,
                  child: Text(user),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPayer = value;
                  });
                }
              },
            ),
            SwitchListTile(
              title: const Text('Custom Split'),
              value: isCustom,
              onChanged: (val) {
                setState(() {
                  isCustom = val;
                  if (isCustom) {
                    for (var user in _dialogSplitDetails.keys) {
                      customSplits.putIfAbsent(user, () => 0.0);
                    }
                  }
                });
              },
            ),

            if (widget.showAddParticipantSection) ...[
              const SizedBox(height: 16),
              const Text(
                "Add Participants",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newUserIdController,
                      decoration: const InputDecoration(
                        labelText: "User ID",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _newUserAmountController,
                      decoration: const InputDecoration(
                        labelText: "Amount (for custom split)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addNewParticipant,
                icon: const Icon(Icons.person_add),
                label: const Text("Add Participant"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            if (_dialogSplitDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text("Current Participants:"),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _dialogSplitDetails.entries.map((entry) {
                  return Chip(
                    label: Text("${entry.key}: ₹${entry.value.toStringAsFixed(2)}"),
                    backgroundColor: Colors.deepPurple.shade100,
                    onDeleted: () {
                      setState(() {
                        _dialogSplitDetails.remove(entry.key);
                        customSplits.remove(entry.key);
                        if (selectedPayer == entry.key) {
                          selectedPayer = _dialogSplitDetails.keys.isNotEmpty ? _dialogSplitDetails.keys.first : '';
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            if (isCustom)
              Column(
                children: _dialogSplitDetails.keys.map((user) {
                  return TextField(
                    decoration: InputDecoration(labelText: 'Amount for $user'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => customSplits[user] = double.tryParse(val) ?? 0.0,
                    controller: TextEditingController(text: customSplits[user]?.toStringAsFixed(2)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
} 