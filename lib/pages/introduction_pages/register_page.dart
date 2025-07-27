import 'package:dhan_mitra_final/Widgets/my_button.dart';
import 'package:dhan_mitra_final/Widgets/my_text_field.dart';
import 'package:dhan_mitra_final/Widgets/squaretile.dart';
import 'package:dhan_mitra_final/services/google_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final _firestore = FirebaseFirestore.instance;

  // Helper method to get short user ID
  String getShortUserId(String uid) {
    return uid.length >= 6 ? uid.substring(0, 6) : uid;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Sign up method
  Future<void> signUserUp() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate inputs
      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty ||
          confirmPasswordController.text.trim().isEmpty) {
        showErrorMessage("Please fill in all fields");
        setState(() => _isLoading = false);
        return;
      }

      // Password match check
      if (passwordController.text != confirmPasswordController.text) {
        showErrorMessage("Passwords don't match");
        setState(() => _isLoading = false);
        return;
      }

      // Attempt to create user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Create user document with short ID
      if (userCredential.user != null) {
        final shortUserId = getShortUserId(userCredential.user!.uid);
        final userDoc = _firestore.collection('users').doc(shortUserId);
        
        await userDoc.set({
          'name': userCredential.user!.displayName ?? 'User_$shortUserId',
          'email': userCredential.user!.email ?? '',
          'userid': shortUserId,
          'createdAt': Timestamp.now(),
        });
      }

      // Clear inputs on success
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      showErrorMessage(errorMessage);
    } catch (e) {
      showErrorMessage("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showErrorMessage(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.money_sharp, size: 75),
                  const SizedBox(height: 50),
                  const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Welcome To Dhan Mitra!'),
                  const SizedBox(height: 50),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  MyButton(
                    onTap: _isLoading ? null : signUserUp,
                    text: "Sign UP",
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 30),
                  const Text('Or Continue With'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                          imagePath: 'assets/images/google.jpeg',
                          onTap: () => AuthService().signInWithGoogle()),
                      const SizedBox(width: 25),
                      SquareTile(
                        imagePath: 'assets/images/apple.jpeg',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already a User?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Login Here',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
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
}
