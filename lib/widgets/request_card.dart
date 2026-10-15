import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A card widget that displays information about a blood request.
/// It dynamically fetches the requester's name based on their ID.
class RequestCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final Function(String) onStatusUpdate;
  final VoidCallback onDelete;

  const RequestCard({
    super.key,
    required this.id,
    required this.data,
    required this.onStatusUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the color scheme based on the request's status.
    final status = data['status'] ?? 'pending';
    final Color color;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'fulfilled':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'expired':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    // Identify the requester's ID from multiple possible field names.
    final String userId = (data['requesterID'] ?? 
                           data['requesterId'] ?? 
                           data['userId'] ?? 
                           data['user_id'] ?? 
                           data['uid'] ?? 
                           data['requester_id'] ?? 
                           '').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      // Use FutureBuilder to fetch the real-time name of the requester.
      child: FutureBuilder<DocumentSnapshot>(
        future: userId.isNotEmpty 
          ? FirebaseFirestore.instance.collection('users').doc(userId).get()
          : null,
        builder: (context, userSnapshot) {
          String requesterName = 'Unknown Requester';
          String bloodType = data['bloodType'] ?? data['blood_type'] ?? 'Unknown';
          
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            requesterName = 'Loading...';
          } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            // Prioritize the real name from the user's profile.
            requesterName = userData['name'] ?? userData['userName'] ?? userData['full_name'] ?? 'No Name';
            // Also sync the blood type from the user's latest profile data.
            bloodType = userData['bloodType'] ?? bloodType;
          } else {
            // Fallback to name/ID info if the user document is missing.
            requesterName = data['userName'] ?? data['user_name'] ?? (userId.isNotEmpty ? 'ID: $userId' : 'Missing ID');
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(Icons.bloodtype, color: color),
            ),
            // The title shows who is asking for blood.
            title: Text(requesterName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Blood Type: $bloodType'),
                // Optionally show the hospital if available in the request.
                if (data['hospitalName'] != null || data['hospital_name'] != null)
                  Text(
                    'Hospital: ${data['hospitalName'] ?? data['hospital_name']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Badge.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Action menu for status updates and deletion.
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(context);
                    } else {
                      onStatusUpdate(value);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'pending',
                      child: Text('Mark as Pending'),
                    ),
                    const PopupMenuItem(
                      value: 'approved',
                      child: Text('Approve'),
                    ),
                    const PopupMenuItem(
                      value: 'fulfilled',
                      child: Text('Mark as Fulfilled'),
                    ),
                    const PopupMenuItem(
                      value: 'expired',
                      child: Text('Mark as Expired'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Displays a confirmation dialog before deleting a request.
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
