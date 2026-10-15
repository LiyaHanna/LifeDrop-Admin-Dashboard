import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A button widget used to view verification documents.
/// When clicked, it attempts to open the provided URL in an external browser.
class VerificationDocButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String url;

  const VerificationDocButton({
    super.key,
    required this.label,
    required this.icon,
    required this.url,
  });

  /// Logic to open an external browser tab for the given document URL.
  Future<void> _viewDocument(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // If the URL is invalid or the browser cannot be opened, show a SnackBar.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _viewDocument(context, url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon representing the document type.
            Icon(icon, size: 14, color: Colors.grey[700]),
            const SizedBox(width: 6),
            // Descriptive label for the document.
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dialog that allows admins to choose a reason for rejecting a verification request.
class RejectReasonDialog extends StatefulWidget {
  final Function(String reason, String note) onConfirm;

  const RejectReasonDialog({super.key, required this.onConfirm});

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  // Keeps track of the currently selected rejection reason.
  String? selectedReason;
  // Controller for the optional custom rejection note.
  final noteController = TextEditingController();
  
  // Standard reasons for rejections.
  final reasons = [
    {'label': 'Blurry Or Unreadable Image', 'icon': Icons.visibility_off},
    {'label': 'Expired Document', 'icon': Icons.document_scanner},
    {'label': 'Identity Mismatch', 'icon': Icons.badge},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Select a reason:'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Map through reasons to build the selectable list.
            ...reasons.map((reason) {
              final isSelected = selectedReason == reason['label'];
              return GestureDetector(
                onTap: () => setState(() => selectedReason = reason['label'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon and Label for the reason.
                      Icon(
                        reason['icon'] as IconData,
                        color: isSelected ? Colors.red : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        reason['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.grey.shade800,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            // Text field for adding extra context or notes.
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add A Note (Optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                // Disable the confirm button until a reason is selected.
                onPressed: selectedReason == null
                    ? null
                    : () => widget.onConfirm(selectedReason!, noteController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.red.shade200,
                ),
                child: const Text('Confirm Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
