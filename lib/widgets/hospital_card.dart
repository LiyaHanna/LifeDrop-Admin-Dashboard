import 'package:flutter/material.dart';

/// A card widget that displays information about a hospital and provides management actions.
class HospitalCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggleActive;

  const HospitalCard({
    super.key,
    required this.id,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    // Extract hospital data with fallbacks.
    final isActive = data['isActive'] ?? true;
    final name = data['name'] ?? 'Unknown Hospital';
    final city = data['city'] ?? '';
    final address = data['address'] ?? 'No address provided';
    final phone = data['phone'] ?? 'No phone';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hospital Name.
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Switch to quickly toggle the hospital's active status.
                Switch(
                  value: isActive,
                  onChanged: onToggleActive,
                  activeTrackColor: Colors.green.withValues(alpha: 0.5),
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Location information (City, Address).
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    city.isNotEmpty ? '$city, $address' : address,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Phone number display.
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            // Management action buttons (Edit and Delete).
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Edit Hospital',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete Hospital',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
