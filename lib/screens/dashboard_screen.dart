import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/dashboard_widgets.dart';
import 'requests_screen.dart';
import 'hospitals_screen.dart';
import 'users_screen.dart';
import 'blood_banks_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'verifications_screen.dart';

/// The main dashboard screen for the admin panel.
/// It uses a NavigationRail for a sidebar and an IndexedStack to switch between different screens.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebase = FirebaseService();
  
  // Stores the calculated statistics for the system.
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  
  // Keeps track of the currently selected sidebar item.
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial statistics when the dashboard is created.
    loadStats();
  }

  /// Fetches system-wide statistics from the Firebase service.
  Future<void> loadStats() async {
    setState(() => isLoading = true);
    try {
      stats = await _firebase.getStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeDrop Admin'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _firebase.signOut();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                _buildDashboardContent(),
                const RequestsScreen(),
                const UsersScreen(),
                const HospitalsScreen(),
                const BloodBanksScreen(),
                const VerificationsScreen(),
                const ReportsScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
//side bar
  Widget _buildSidebar() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
      },
      labelType: NavigationRailLabelType.all,
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                const SizedBox(height: 10),
                const Icon(Icons.account_circle, color: Colors.grey),
                const SizedBox(height: 4),
                Text(
                  _firebase.auth.currentUser?.email ?? 'Admin',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bloodtype),
          label: Text('Requests'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Users'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.local_hospital),
          label: Text('Hospitals'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.medical_services),
          label: Text('Blood Banks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.verified_user),
          label: Text('Verifications'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics),
          label: Text('Reports'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
// dashboard contents
  Widget _buildDashboardContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome to LifeDrop Admin Panel',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          StatsSummaryRow(stats: stats),
          const SizedBox(height: 20),
          PendingAlertsSection(
            onReviewNow: () => setState(() => selectedIndex = 5),
          ),
          BloodTypeDistributionRow(
            distribution: stats['bloodTypeDistribution'] as Map<String, int>?,
          ),
          const Text(
            'Recent Blood Requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RecentRequestsSection(
            firebase: _firebase,
            isMounted: () => mounted,
          ),
        ],
      ),
    );
  }
}
