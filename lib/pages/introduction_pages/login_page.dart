import 'package:dhan_mitra_final/Widgets/my_button.dart';
import 'package:dhan_mitra_final/Widgets/my_text_field.dart';
import 'package:dhan_mitra_final/Widgets/squaretile.dart';
import 'package:dhan_mitra_final/services/google_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dhan_mitra_final/firebase_options.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //sign in method
  Future<void> signUserIn() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if Firebase is initialized
      if (!Firebase.apps.isNotEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Validate inputs
      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
        showErrorMessage("Please fill in all fields");
        return;
      }

      // Attempt sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        // imp to remember
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
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

  Future<void> handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final userCredential = await AuthService().signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (userCredential != null) {
      // Navigate to your homepage (or main app screen)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/homepage');
        // OR if using a widget directly:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } else {
      // User cancelled login or error occurred
      showErrorMessage("Google Sign-In failed or was cancelled.");
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
                    'Login',
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
                  const Text('Forgot Password?'),
                  const SizedBox(height: 10),
                  MyButton(
                    onTap: _isLoading ? null : signUserIn,
                    text: "Sign IN",
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
                        onTap: () => AuthService().signInWithGoogle(),
                      ),
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
                      const Text('Not a User?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Register Now',
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
