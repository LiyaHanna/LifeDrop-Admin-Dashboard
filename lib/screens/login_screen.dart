import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:provider/provider.dart';

/// The login screen for the admin panel.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to capture email and password input.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // State variables to manage loading state and error messages.
  bool _isLoading = false;
  String? _errorMessage;

  /// Attempts to sign in the user using the provided credentials.
  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Access the FirebaseService from the context.
      final service = Provider.of<FirebaseService>(context, listen: false);
      // Call the sign-in method.
      await service.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Navigation is handled automatically by the AuthWrapper in main.dart
      // when it detects a successful authentication state change.
    } catch (e) {
      // If sign-in fails, update the UI with the error message.
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Application Logo
              Image.asset('assets/images/LOGO_PIC.png', width: 80, height: 80),
              const SizedBox(height: 16),
              const Text(
                'LifeDrop Admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Error message display if any error occurs.
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.red[50],
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Email Input Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password Input Field
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
