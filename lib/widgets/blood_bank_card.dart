import 'package:flutter/material.dart';

/// A card widget that displays information about a blood bank and provides management actions.
class BloodBankCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggleActive;

  const BloodBankCard({
    super.key,
    required this.id,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    // Extract blood bank data with fallbacks.
    final isActive = data['isActive'] ?? true;
    final name = data['name'] ?? 'Unknown';
    final city = data['city'] ?? '';
    final address = data['address'] ?? 'No address';
    final phone = data['phone'] ?? 'No phone';
    // List of blood types currently available at this bank.
    final bloodTypes = List<String>.from(data['bloodTypesAvailable'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Blood Bank Name.
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status label (Active / Inactive).
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'INACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Location information (City, Address).
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    city.isNotEmpty ? '$city, $address' : address,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Phone number display.
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  phone,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tags showing available blood types.
            if (bloodTypes.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: bloodTypes.map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const Spacer(),
            // Management action buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Quick toggle for activation/deactivation.
                IconButton(
                  icon: Icon(
                    isActive ? Icons.visibility : Icons.visibility_off,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                  tooltip: isActive ? 'Deactivate' : 'Activate',
                  onPressed: () => onToggleActive(!isActive),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Edit Blood Bank',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete Blood Bank',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
