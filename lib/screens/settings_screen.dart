import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

/// The screen for managing application-wide settings and the admin account.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _firebase = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Section for General Security and Preferences.
              const Text(
                'General Settings',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.security, color: Colors.red),
                  title: const Text('Security'),
                  subtitle: const Text('Manage security settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to security settings if implemented.
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Section for Account actions.
              const Text(
                'Account',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              
              // Card containing the logout action.
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Sign out from admin panel'),
                  trailing: const Icon(Icons.exit_to_app, color: Colors.red),
                  onTap: _confirmLogout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays a confirmation dialog before logging out.
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog.
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Sign out the user and close the dialog.
              await _firebase.signOut();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
