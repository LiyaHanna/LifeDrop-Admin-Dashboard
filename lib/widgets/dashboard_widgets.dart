import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'stat_card.dart';
import 'request_card.dart';

/// A widget that displays a row of statistics cards for the dashboard.
class StatsSummaryRow extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsSummaryRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Each card represents a key metric of the system.
        Expanded(
          child: StatCard(
            title: 'Total Users',
            value: stats['totalUsers'] ?? 0,
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: StatCard(
            title: 'Verified Users',
            value: stats['verifiedUsers'] ?? 0,
            icon: Icons.verified,
            color: Colors.teal,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: StatCard(
            title: 'Blood Requests',
            value: stats['totalRequests'] ?? 0,
            icon: Icons.bloodtype,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: StatCard(
            title: 'Hospitals',
            value: stats['totalHospitals'] ?? 0,
            icon: Icons.local_hospital,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: StatCard(
            title: 'Blood Banks',
            value: stats['totalBloodBanks'] ?? 0,
            icon: Icons.medical_services,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

/// A widget that shows an alert banner if there are any open support tickets.
class PendingAlertsSection extends StatelessWidget {
  final VoidCallback onReviewNow;

  const PendingAlertsSection({super.key, required this.onReviewNow});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Listen to the support tickets collection for any 'open' status tickets.
      stream: FirebaseFirestore.instance
          .collection('support_tickets')
          .where('status', isEqualTo: 'open')
          .snapshots(),
      builder: (context, snapshot) {
        // If there are no pending tickets, hide the alert section.
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

        int pendingCount = snapshot.data!.docs.length;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 12),
              // Display the count of pending tickets.
              Text(
                '$pendingCount Support ticket(s) waiting for verification.',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              const Spacer(),
              // Action button to navigate to the verification screen.
              TextButton(
                onPressed: onReviewNow,
                child: const Text('Review Now'),
              )
            ],
          ),
        );
      },
    );
  }
}

/// A horizontal list that shows the distribution of users across different blood types.
class BloodTypeDistributionRow extends StatelessWidget {
  final Map<String, int>? distribution;

  const BloodTypeDistributionRow({super.key, this.distribution});

  @override
  Widget build(BuildContext context) {
    if (distribution == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Blood Type Distribution',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Horizontally scrollable row of blood type cards.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: distribution!.entries
                .map((entry) => Container(
                      margin: const EdgeInsets.only(right: 10, bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // The blood type label (e.g., A+).
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          const SizedBox(height: 4),
                          // The count of users for that blood type.
                          Text(
                            '${entry.value} users',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// A widget that displays the list of recent blood requests on the dashboard.
class RecentRequestsSection extends StatelessWidget {
  final FirebaseService firebase;
  final bool Function() isMounted;

  const RecentRequestsSection({
    super.key,
    required this.firebase,
    required this.isMounted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: firebase.getRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return const Center(child: Text('No requests found'));
          }

          return ListView.builder(
            // Show at most 10 recent requests.
            itemCount: requests.length > 10 ? 10 : requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              return RequestCard(
                id: doc.id,
                data: data,
                onStatusUpdate: (status) async {
                  await firebase.updateRequestStatus(doc.id, status);
                  if (isMounted()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated to $status')),
                    );
                  }
                },
                onDelete: () async {
                  await firebase.deleteRequest(doc.id);
                  if (isMounted()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request deleted')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
