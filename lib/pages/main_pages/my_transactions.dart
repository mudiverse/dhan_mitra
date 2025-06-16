import 'package:dhan_mitra_final/Widgets/basic_list_card.dart';
import 'package:dhan_mitra_final/Widgets/special_pages/expenses_page.dart';
import 'package:dhan_mitra_final/Widgets/special_pages/income_page.dart';
import 'package:dhan_mitra_final/Widgets/special_pages/splits_page.dart';
import 'package:dhan_mitra_final/data/repositories/userid_fetch.dart';
import 'package:dhan_mitra_final/pages/main_pages/profile_page.dart';
import 'package:dhan_mitra_final/providers/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTransactions extends StatefulWidget {
  const MyTransactions({super.key});

  @override
  State<MyTransactions> createState() => _MyTransactionsState();
}

class _MyTransactionsState extends State<MyTransactions> {
  String? userId;
  double totExpenses = 0.0;
  double totIncome = 0.0;
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = UserSession().userId;
      if (userId != null) {
        final dashboardState =
            Provider.of<DashboardState>(context, listen: false);
        await dashboardState.loadDashboardData(userId!);
        // now safely update state
        setState(() {
          totExpenses = dashboardState.expenses;
          totIncome = dashboardState.income;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Spent',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${totExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Gained',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${totIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Section Title
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    const Text(
                      "Your Transactions",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),Text("Track Your Expenses and Income",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: theme.colorScheme.primary),),
                  ],
                ),
                
              ),
              const SizedBox(height: 16),

              // Transaction Cards
              BasicListCard(
                amount: totExpenses,
                label: 'Expenses',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpensesPage()),
                ),
              ),
              const SizedBox(height: 12),
              BasicListCard(
                amount: totIncome,
                label: 'Income',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IncomePage()),
                ),
              ),
              const SizedBox(height: 12),
              BasicListCard(
                amount: 1000,
                label: 'Splits',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SplitsPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
