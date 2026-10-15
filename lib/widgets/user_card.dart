import 'package:flutter/material.dart';

/// A card widget that displays information about a specific user and provide management actions.
class UserCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final Function(String, String) onBlock;
  final Function(String) onUnblock;
  final Function(String) onVerify;
  final Function(String) onDelete;
  final Function(String) onSendNotification;
  final Function(String, String) onUpdateRole;
  final Function(String, String) onUpdateBloodType;

  const UserCard({
    super.key,
    required this.id,
    required this.data,
    required this.onBlock,
    required this.onUnblock,
    required this.onVerify,
    required this.onDelete,
    required this.onSendNotification,
    required this.onUpdateRole,
    required this.onUpdateBloodType,
  });

  @override
  Widget build(BuildContext context) {
    // Extract user data with fallbacks for missing fields.
    final name = data['name'] ?? 'Unknown User';
    final email = data['email'] ?? 'No email';
    final role = data['role'] ?? 'user';
    final bloodType = data['bloodType'] ?? 'Unknown';
    final isVerified = data['isVerified'] ?? false;
    final isBlocked = data['isBlocked'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        // Avatar showing the first letter of the user's name.
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role).withValues(alpha: 0.2),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(color: _getRoleColor(role), fontWeight: FontWeight.bold),
          ),
        ),
        // Title showing user's name and status icons.
        title: Row(
          children: [
            Text(name),
            if (isVerified)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.verified, size: 16, color: Colors.blue),
              ),
            if (isBlocked)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.block, size: 16, color: Colors.red),
              ),
          ],
        ),
        // Subtitle showing email, role, and blood type.
        subtitle: Text('$email • ${role.toUpperCase()} • Blood: $bloodType'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick action to send a priority notification.
            IconButton(
              icon: const Icon(Icons.notification_important, color: Colors.orange),
              onPressed: () => onSendNotification(id),
              tooltip: 'Send Notification',
            ),
            // Popup menu containing various management actions.
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'verify') {
                  onVerify(id);
                } else if (value == 'block') {
                  if (isBlocked) {
                    onUnblock(id);
                  } else {
                    _showBlockDialog(context);
                  }
                } else if (value == 'delete') {
                  _showDeleteDialog(context);
                } else if (value == 'make_admin') {
                  _showMakeAdminDialog(context);
                } else if (value == 'remove_admin') {
                  _showRemoveAdminDialog(context);
                } else if (value == 'change_blood') {
                  _showBloodTypeDialog(context);
                }
              },
              itemBuilder: (context) => [
                if (!isVerified)
                  const PopupMenuItem(
                    value: 'verify',
                    child: Text('Verify User'),
                  ),
                const PopupMenuItem(
                  value: 'change_blood',
                  child: Text('Change Blood Type'),
                ),
                // Show role-specific options.
                if (role.toLowerCase() != 'admin')
                  const PopupMenuItem(
                    value: 'make_admin',
                    child: Text('Make Admin'),
                  ),
                if (role.toLowerCase() == 'admin')
                  const PopupMenuItem(
                    value: 'remove_admin',
                    child: Text('Remove Admin Privileges'),
                  ),
                PopupMenuItem(
                  value: 'block',
                  child: Text(isBlocked ? 'Unblock User' : 'Block User'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete User', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Determines the brand color based on the user's role.
  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Colors.purple;
      case 'DONOR':
        return Colors.red;
      case 'REQUESTER':
        return Colors.blue;
      case 'BOTH':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Displays a dialog to select a new blood type for the user.
  void _showBloodTypeDialog(BuildContext context) {
    final List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    String selectedType = data['bloodType'] ?? 'O+';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Blood Type'),
          content: DropdownButton<String>(
            value: bloodTypes.contains(selectedType) ? selectedType : 'O+',
            isExpanded: true,
            items: bloodTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() => selectedType = value!);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onUpdateBloodType(id, selectedType);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a confirmation dialog before making a user an admin.
  void _showMakeAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Admin'),
        content: const Text('Are you sure you want to grant admin access to this user? They will be able to manage the dashboard.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onUpdateRole(id, 'Admin');
              Navigator.pop(context);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Displays a dialog to remove admin privileges and assign a new role.
  void _showRemoveAdminDialog(BuildContext context) {
    String selectedRole = 'Requester';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Remove Admin Privileges'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select new role for the user:'),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Requester', child: Text('Requester')),
                  DropdownMenuItem(value: 'Donor', child: Text('Donor')),
                  DropdownMenuItem(value: 'BOTH', child: Text('BOTH (Donor & Requester)')),
                ],
                onChanged: (value) {
                  setState(() => selectedRole = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onUpdateRole(id, selectedRole);
                Navigator.pop(context);
              },
              child: const Text('Remove Admin', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog to block a user with a reason.
  void _showBlockDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Reason for blocking'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onBlock(id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Displays a final confirmation dialog before deleting a user.
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
