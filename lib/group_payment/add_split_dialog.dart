import 'package:dhan_mitra_final/models/group_payment_models/group_models.dart';
import 'package:dhan_mitra_final/models/group_payment_models/split_payment_model.dart';
import 'package:flutter/material.dart';

class AddSplitDialog extends StatefulWidget {
  final GroupModel group;

  const AddSplitDialog({super.key, required this.group});

  @override
  State<AddSplitDialog> createState() => _AddSplitDialogState();
}

class _AddSplitDialogState extends State<AddSplitDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool isCustom = false;
  Map<String, double> customSplits = {};
  String selectedPayer = '';

  @override
  void initState() {
    super.initState();
    for (var user in widget.group.members) {
      customSplits[user] = 0.0;
    }
    if (widget.group.members.isNotEmpty) {
      selectedPayer = widget.group.members.first;
    }
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
      final splitAmt = total / widget.group.members.length;
      for (var user in widget.group.members) {
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
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: selectedPayer,
              decoration: const InputDecoration(labelText: 'Paid By'),
              items: widget.group.members.map((user) {
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
              onChanged: (val) => setState(() => isCustom = val),
            ),
            if (isCustom)
              Column(
                children: widget.group.members.map((user) {
                  return TextField(
                    decoration: InputDecoration(labelText: 'Amount for $user'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => customSplits[user] =
                        double.tryParse(val) ?? 0.0,
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

