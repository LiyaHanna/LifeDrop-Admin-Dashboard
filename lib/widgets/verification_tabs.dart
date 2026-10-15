import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verification_cards.dart';

/// The tab content for managing support tickets (blood type change requests).
class SupportTicketsTab extends StatelessWidget {
  final Function(String ticketId, String userId, String requestedBloodType) onApprove;
  final Function(String ticketId, String userId) onReject;

  const SupportTicketsTab({
    super.key,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support Requests',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Requests to change blood type via support message.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_tickets')
                  .where('status', isEqualTo: 'open')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = snapshot.data!.docs;
                if (tickets.isEmpty) {
                  return const Center(
                    child: Text('No pending support requests', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticketDoc = tickets[index];
                    return SupportTicketCard(
                      ticketId: ticketDoc.id,
                      ticketData: ticketDoc.data() as Map<String, dynamic>,
                      onApprove: onApprove,
                      onReject: onReject,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The tab content for reviewing users who are awaiting their initial profile verification.
class ProfileVerificationsTab extends StatelessWidget {
  final Function(String userId) onApprove;
  final Function(String userId) onReject;

  const ProfileVerificationsTab({
    super.key,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Verifications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Users who uploaded ID and Medical Proof for verification.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('verificationStatus', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No pending profile verifications', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    return ProfileVerificationCard(
                      userId: userDoc.id,
                      userData: userDoc.data() as Map<String, dynamic>,
                      onApprove: onApprove,
                      onReject: onReject,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
