import 'package:dhan_mitra_final/pages/introduction_pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted || _isNavigating) return;
      
      setState(() => _isNavigating = true);
      
      // Navigate to AuthPage
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    } catch (e) {
      print('Error during navigation: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // App logo or icon
              const Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              // Animated text
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Dhan Mitra',
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


