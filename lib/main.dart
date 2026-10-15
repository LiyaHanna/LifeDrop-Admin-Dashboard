import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/firebase_service.dart';

/// The entry point of the application.
void main() async {
  // Ensures that Flutter widget binding is initialized before Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with web-specific options.
    await Firebase.initializeApp(
      options: FirebaseOptionsConfig.web,
    );
    // Start the application.
    runApp(const MyApp());
  } catch (e) {
    // If Firebase fails to initialize, show a simple error screen with a retry button.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Firebase Connection Failed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(), // Attempt to restart the app.
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provides the FirebaseService to all descendant widgets using the Provider package.
    return Provider<FirebaseService>(
      create: (_) => FirebaseService(),
      child: MaterialApp(
        title: 'LifeDrop Admin',
        theme: ThemeData(
          primarySwatch: Colors.red,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        // The home widget determines whether to show the login screen or dashboard.
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}

/// A wrapper widget that listens to authentication state changes.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    
    // Listen to Firebase Auth state (login/logout).
    return StreamBuilder<User?>(
      stream: firebaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // If a user is logged in, verify their role from Firestore.
        if (snapshot.hasData) {
          return StreamBuilder<DocumentSnapshot>(
            stream: firebaseService.listenToUserData(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                
                // Only allow access if the user has the 'Admin' role.
                if (userData['role'] == 'Admin') {
                  return const DashboardScreen();
                } else {
                  // If the user is authenticated but not an Admin, show an Access Denied screen.
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, size: 80, color: Colors.red),
                          const SizedBox(height: 20),
                          const Text(
                            'Access Denied',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                            child: Text(
                              'Your administrator privileges have been revoked or you do not have permission to access this panel.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => firebaseService.signOut(),
                            child: const Text('Return to Login'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
              // Fallback to login if user data isn't found.
              return const LoginScreen();
            },
          );
        }
        // If no user is logged in, show the login screen.
        return const LoginScreen();
      },
    );
  }
}
