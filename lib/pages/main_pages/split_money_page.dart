import 'package:dhan_mitra_final/Widgets/splits_summary_card.dart';
import 'package:dhan_mitra_final/pages/main_pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:dhan_mitra_final/services/split_transaction_service.dart';
import 'package:dhan_mitra_final/models/multi_transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:dhan_mitra_final/providers/dashboard_state.dart';
import 'package:dhan_mitra_final/shared_split_dialog.dart';
import 'package:dhan_mitra_final/providers/app_state.dart';

class SplitMoneyPage extends StatefulWidget {
  const SplitMoneyPage({super.key});

  @override
  State<SplitMoneyPage> createState() => _SplitMoneyPageState();
}

class _SplitMoneyPageState extends State<SplitMoneyPage> {
  String splitTitle = "";
  String splitAmount = "";
  //MAp of user id's ,amount to be payed
  final Map<String, double> splitUsers = {};
  final TextEditingController userIdController =
      TextEditingController(); // to take the input of userID's
  final TextEditingController userAmountController = TextEditingController();
  List<MultiTransactionModel> pendingSplits = [];
  List<MultiTransactionModel> owedSplits = [];
  final SplitTransactionService _splitService = SplitTransactionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get short user ID
  String getShortUserId(String uid) {
    return uid.length >= 6 ? uid.substring(0, 6) : uid;
  }

  @override
  void initState() {
    super.initState();
    _loadSplits();
  }

  void _loadSplits() {
    final userId = getShortUserId(_auth.currentUser?.uid ?? '');
    if (userId.isEmpty) return;

    try {
      _splitService.getPendingSplits(userId).listen(
        (splits) {
          if (mounted) {
            setState(() {
              pendingSplits = splits;
            });
          }
        },
        onError: (error) {
          print('Error loading pending splits: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error loading splits. Please try again.'),
              ),
            );
          }
        },
      );

      _splitService.getOwedSplits(userId).listen(
        (splits) {
          if (mounted) {
            setState(() {
              owedSplits = splits;
            });
          }
        },
        onError: (error) {
          print('Error loading owed splits: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error loading splits. Please try again.'),
              ),
            );
          }
        },
      );
    } catch (e) {
      print('Error in _loadSplits: $e');
    }
  }

  void addSplit() async {
    final currentUserId = getShortUserId(_auth.currentUser?.uid ?? '');
    // Collect all participants (current user + splitUsers) that will be initially displayed
    final participants = <String>{};
    if (currentUserId.isNotEmpty) {
      participants.add(currentUserId);
    }
    for (var user in splitUsers.keys) {
      participants.add(user);
    }

    final split = await showDialog(
      context: context,
      builder: (_) => SharedSplitDialog(
        participants: participants.toList(),
        initialPayer: currentUserId,
        showAddParticipantSection: true, // Allow adding participants directly
      ),
    );
    if (split != null) {
      await _saveSplitFromDialog(split);
    }
  }

  Future<void> _saveSplitFromDialog(dynamic split) async {
    final userId = getShortUserId(_auth.currentUser?.uid ?? '');
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create splits')),
      );
      return;
    }
    try {
      await _splitService.createSplitTransaction(
        title: split.title,
        amount: split.totalAmount,
        paidBy: split.paidBy,
        participants: split.userSplits.keys.toList(),
        splitDetails: split.userSplits,
      );
      setState(() {
        splitTitle = "";
        splitAmount = "";
        splitUsers.clear();
      });
      _loadSplits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating split: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = Provider.of<DashboardState>(context);
    final currentUserId = getShortUserId(_auth.currentUser?.uid ?? '');
    final pendingAmt = dashboardState.splitToPay;
    final owedAmt = dashboardState.splitOwed;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        title: const Text(
          'Dhan Mitra',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _loadSplits();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            _loadSplits();
          },
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Pending Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${pendingAmt.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Owed Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${owedAmt.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                if (pendingSplits.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Pending Splits',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...pendingSplits.map((split) => SplitSummaryCard(
                        title: split.title,
                        amount: split.amount,
                        userIds: split.splitDetails,
                        paidBy: split.paidBy,
                        currentUserId: currentUserId,
                        dashboardState: dashboardState,
                        transactionId: split.id,
                        settledUsers: split.settledUsers,
                        groupId: split.groupId,
                      )),
                ],
                if (owedSplits.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Owed Splits',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...owedSplits.map((split) => SplitSummaryCard(
                        title: split.title,
                        amount: split.amount,
                        userIds: split.splitDetails,
                        paidBy: split.paidBy,
                        currentUserId: currentUserId,
                        dashboardState: dashboardState,
                        transactionId: split.id,
                        settledUsers: split.settledUsers,
                        groupId: split.groupId,
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSplit,
        focusColor: Colors.purpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
