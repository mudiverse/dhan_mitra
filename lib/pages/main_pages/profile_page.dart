import 'package:dhan_mitra_final/services/user_service.dart';
import 'package:dhan_mitra_final/themes/lightmode.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final data = await UserService().getUserData();
    setState(() {
      userData = data;
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add actual logout logic here
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = isDarkMode ? darkmode : lightmode;

    return Theme(
      data: currentTheme,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "PROFILE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: currentTheme.colorScheme.primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Profile Picture Section
                  Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          currentTheme.colorScheme.primary,
                          currentTheme.colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(70),
                      boxShadow: [
                        BoxShadow(
                          color:
                              currentTheme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_2_rounded,
                      size: 80,
                      color: currentTheme.colorScheme.onPrimary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User Information Cards
                  // This SingleChildScrollView is nested, which is fine, but the outer one is what fixes the overflow.
                  Column(
                    // Changed from SingleChildScrollView to Column as the outer SingleChildScrollView handles scrolling
                    children: [
                      _buildInfoCard(
                        'Name',
                        userData?['name'] ?? 'Mudit',
                        Icons.person_outline,
                        currentTheme,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        'User ID',
                        userData?['userid']?.substring(0, 5) ?? 'abc12345',
                        Icons.fingerprint,
                        currentTheme,
                        isSelectable: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        'Email',
                        userData?['email'] ?? 'example@gmail.com',
                        Icons.email_outlined,
                        currentTheme,
                      ),

                      const SizedBox(height: 20),

                      // Theme Toggle Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: currentTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: currentTheme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: currentTheme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isDarkMode,
                              onChanged: (value) => _toggleTheme(),
                              activeColor: currentTheme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      // Logout Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 20),
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String label, String value, IconData icon, ThemeData theme,
      {bool isSelectable = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                isSelectable
                    ? SelectableText(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
