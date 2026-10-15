import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/verification_tabs.dart';
import '../widgets/verification_widgets.dart';

/// The Verifications center where admins review identity documents and blood type change requests.
/// It features a tabbed layout to separate support tickets from profile verifications.
class VerificationsScreen extends StatefulWidget {
  const VerificationsScreen({super.key});

  @override
  State<VerificationsScreen> createState() => _VerificationsScreenState();
}

class _VerificationsScreenState extends State<VerificationsScreen> {
  /// Approves a support request by updating the user's blood type and marking the ticket as approved.
  Future<void> _approveRequest(String ticketId, String userId, String requestedBloodType) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Update the user document with the new blood type.
      batch.update(FirebaseFirestore.instance.collection('users').doc(userId), {
        'bloodType': requestedBloodType,
        'verificationStatus': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mark the support ticket as resolved/approved.
      batch.update(FirebaseFirestore.instance.collection('support_tickets').doc(ticketId), {
        'status': 'approved',
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request Approved! User blood type updated.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Displays a dialog to select a reason for rejecting a request.
  void _showRejectDialog(String ticketId, String userId) {
    showDialog(
      context: context,
      builder: (context) => RejectReasonDialog(
        onConfirm: (reason, note) async {
          await _rejectRequest(ticketId, userId, reason, note);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  /// Rejects a verification request and records the reason.
  Future<void> _rejectRequest(String ticketId, String userId, String reason, String note) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Update the user's verification status and store rejection details.
      batch.update(FirebaseFirestore.instance.collection('users').doc(userId), {
        'verificationStatus': 'rejected',
        'rejectionReason': reason,
        'rejectionNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If a support ticket is involved, mark it as rejected too.
      if (ticketId.isNotEmpty) {
        batch.update(FirebaseFirestore.instance.collection('support_tickets').doc(ticketId), {
          'status': 'rejected',
          'rejectionReason': reason,
          'rejectionNote': note,
          'resolvedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request Rejected: $reason'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Directly approves a user's profile verification.
  Future<void> _approveProfile(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'verificationStatus': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Verified!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Verification Center',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.red,
            tabs: [
              Tab(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('support_tickets')
                      .where('status', isEqualTo: 'open')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Support Requests'),
                        if (count > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Tab(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('verificationStatus', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Profile Verifications'),
                        if (count > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SupportTicketsTab(
              onApprove: _approveRequest,
              onReject: _showRejectDialog,
            ),
            ProfileVerificationsTab(
              onApprove: _approveProfile,
              onReject: (userId) => _showRejectDialog('', userId),
            ),
          ],
        ),
      ),
    );
  }
}
