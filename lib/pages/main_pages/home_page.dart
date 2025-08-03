import 'package:dhan_mitra_final/Widgets/cards.dart';
import 'package:dhan_mitra_final/Widgets/dashboard_summary.dart';
import 'package:dhan_mitra_final/Widgets/money_summaryCard.dart';
import 'package:dhan_mitra_final/data/repositories/userid_fetch.dart';
import 'package:dhan_mitra_final/pages/main_pages/profile_page.dart';
import 'package:dhan_mitra_final/providers/dashboard_state.dart';
import 'package:dhan_mitra_final/providers/app_state.dart';
import 'package:dhan_mitra_final/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //current firebase user
  final user = FirebaseAuth.instance.currentUser;
  //instance of user service to fetch user data
  final UserService _userService = UserService();
  Map<String, dynamic>?
      userData; // map stores data from the getUSerData() function

  void signUserOut() {
    FirebaseAuth.instance.signOut();

    // Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _initUserAndLoadDashboard();
  }

  //intialize user details function
  // Future<void> _initUser() async {
  //   await _userService.createUserIfDocumentNotExists(); // cheks if user exists
  //   final data = await _userService.getUserData(); //fetch the data
  //   setState(() {
  //     userData = data; // save the data from db to userData map we created
  //   });
  // }

  bool _isLoading = true;
  //func to load the global variables data
  // Future<void> _loadSummary() async {
  //   final userId =; // uid
  //   await Provider.of<DashboardState>(context, listen: false)
  //       .loadDashboardData(userId);
  //   setState(() => _isLoading = false);
  // }
  Future<void> _initUserAndLoadDashboard() async {
    try {
      await _userService.createUserIfDocumentNotExists();
      final data = await _userService.getUserData();

      if (!mounted) return;

      setState(() {
        userData = data;
        _isLoading = false;
      });

      if (userData != null) {
        UserSession().setUserId(userData!['userid']);
        // Now load dashboard data and user-specific groups and transactions (after userData is ready)
        final dashboardState = Provider.of<DashboardState>(context, listen: false);
        final appState = Provider.of<AppState>(context, listen: false);
        await dashboardState.loadDashboardData(userData!['userid']);
        await appState.loadUserGroups(userData!['userid']);
        await appState.loadUserTransactions(userData!['userid']);
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {
              setState(() => _isLoading = true);
              await _initUserAndLoadDashboard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signUserOut,
          ),
        ],
      ),
      body: userData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _isLoading = true);
                await _initUserAndLoadDashboard();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Dashboard Summary Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userData?['name'] ?? 'User',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stat cards
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const BalanceCard(
                                  balance: 75000,
                                  expense: 1300,
                                  income: 27272,
                                ),
                                _isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : const DashboardSummary(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Recent Transactions List
                          MoneySummaryCard(
                            label: 'Transaction Summary',
                            userId: userData?['userid'],
                          ),
                        ],
                      ),
                    ),

                    // const Expanded(child: TransactionList()),
                  ],
                ),
              ),
            ),

      //navigations
    );
  }
}
