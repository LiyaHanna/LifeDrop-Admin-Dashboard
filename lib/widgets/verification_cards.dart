import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verification_widgets.dart';

/// A card representing a single support ticket request.
class SupportTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticketData;
  final String ticketId;
  final Function(String ticketId, String userId, String requestedBloodType) onApprove;
  final Function(String ticketId, String userId) onReject;

  const SupportTicketCard({
    super.key,
    required this.ticketId,
    required this.ticketData,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final userId = ticketData['userId'] ?? '';
    final userEmail = ticketData['userEmail'] ?? 'No email';
    final requestedBloodType = ticketData['requestedBloodType'] ?? 'Unknown';
    final message = ticketData['message'] ?? 'No message';
    final ticketDocs = ticketData['documents'] as Map<String, dynamic>? ?? {};

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnapshot) {
        String userName = ticketData['userName'] ?? 'Unknown';
        Map<String, dynamic> userProfileDocs = {};
        
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          userName = userData['name'] ?? userName;
          userProfileDocs = userData['documents'] as Map<String, dynamic>? ?? {};
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(userName, userEmail, requestedBloodType),
                const Divider(height: 30),
                _buildMessageSection(message),
                const SizedBox(height: 20),
                _buildAttachmentsSection(ticketData, ticketDocs),
                const SizedBox(height: 20),
                _buildProfileDocsSection(userProfileDocs),
                const SizedBox(height: 24),
                _buildActionButtons(userId, requestedBloodType),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name, String email, String type) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.red.shade100,
          child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
          child: Text('Requested: $type', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildMessageSection(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Text(message, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
      ],
    );
  }

  Widget _buildAttachmentsSection(Map<String, dynamic> data, Map<String, dynamic> docs) {
    if (docs.isEmpty && data['documentUrl'] == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ticket Attachments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (data['documentUrl'] != null)
              VerificationDocButton(label: 'Ticket Doc', icon: Icons.file_present, url: data['documentUrl'].toString()),
            ...docs.entries.map((e) => 
              VerificationDocButton(label: e.key.toString().toUpperCase(), icon: Icons.file_present, url: e.value.toString())
            ).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDocsSection(Map<String, dynamic> profileDocs) {
    if (profileDocs.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('User Profile Verification Docs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (profileDocs['idFront'] != null)
              VerificationDocButton(label: 'ID Front', icon: Icons.badge, url: profileDocs['idFront']),
            if (profileDocs['idBack'] != null)
              VerificationDocButton(label: 'ID Back', icon: Icons.badge_outlined, url: profileDocs['idBack']),
            if (profileDocs['medicalDocuments'] != null) ...[
              if (profileDocs['medicalDocuments'] is List)
                ...(profileDocs['medicalDocuments'] as List).map((url) => 
                  VerificationDocButton(label: 'Medical Doc', icon: Icons.medical_services, url: url.toString())
                ).toList()
              else
                VerificationDocButton(label: 'Medical Proof', icon: Icons.medical_services, url: profileDocs['medicalDocuments'].toString())
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(String userId, String type) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => onReject(ticketId, userId),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            child: const Text('Reject Request'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => onApprove(ticketId, userId, type),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Approve Request'),
          ),
        ),
      ],
    );
  }
}

/// A card representing a user's initial profile verification request.
class ProfileVerificationCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;
  final Function(String userId) onApprove;
  final Function(String userId) onReject;

  const ProfileVerificationCard({
    super.key,
    required this.userId,
    required this.userData,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final name = userData['name'] ?? 'Unknown';
    final email = userData['email'] ?? 'No email';
    final profileDocs = userData['documents'] as Map<String, dynamic>? ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(name, email),
            const Divider(height: 30),
            const Text('Uploaded Identity & Medical Documents:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _buildDocumentsList(profileDocs),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.orange.shade100,
          child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsList(Map<String, dynamic> docs) {
    if (docs.isEmpty) {
      return const Text('No documents found in profile', style: TextStyle(color: Colors.grey, fontSize: 13));
    }
    
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (docs['idFront'] != null)
          VerificationDocButton(label: 'ID Front', icon: Icons.badge, url: docs['idFront']),
        if (docs['idBack'] != null)
          VerificationDocButton(label: 'ID Back', icon: Icons.badge_outlined, url: docs['idBack']),
        if (docs['medicalDocuments'] != null) ...[
          if (docs['medicalDocuments'] is List)
            ...(docs['medicalDocuments'] as List).map((url) => 
              VerificationDocButton(label: 'Medical Doc', icon: Icons.medical_services, url: url.toString())
            ).toList()
          else
            VerificationDocButton(label: 'Medical Proof', icon: Icons.medical_services, url: docs['medicalDocuments'].toString())
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => onReject(userId),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            child: const Text('Reject Verification'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => onApprove(userId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Approve Verification'),
          ),
        ),
      ],
    );
  }
}
