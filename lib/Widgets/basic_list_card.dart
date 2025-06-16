import 'package:flutter/material.dart';

class BasicListCard extends StatefulWidget {
  final String label;
  final double amount;
  final VoidCallback onTap;

  const BasicListCard(
      {super.key,
      required this.amount,
      required this.label,
      required this.onTap});

  @override
  State<BasicListCard> createState() => _BasicListCardState();
}

class _BasicListCardState extends State<BasicListCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 150,
        width: 280,
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 187, 25, 212),
              Color.fromARGB(255, 103, 37, 97)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //list of expenses or data
              ],
            )
          ],
        ),
      ),
    );
  }
}
