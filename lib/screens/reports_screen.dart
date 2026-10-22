import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../services/firebase_service.dart';

/// The screen dedicated to displaying system analytics and exporting data reports.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseService _firebase = FirebaseService();
  bool isLoading = true;
  // Stores the processed analytics data (counts, distributions, etc.).
  Map<String, dynamic> analytics = {};

  @override
  void initState() {
    super.initState();
    // Load analytics data when the screen is initialized.
    loadAnalytics();
  }

  /// Fetches request-based analytics from Firestore.
  Future<void> loadAnalytics() async {
    setState(() => isLoading = true);
    try {
      analytics = await _firebase.getRequestAnalytics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen header with title and export action buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Button to export a summarized system report.
                    ElevatedButton.icon(
                      onPressed: _exportAnalyticsReport,
                      icon: const Icon(Icons.download),
                      label: const Text('Export Summary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Button to trigger a full raw data backup of users and requests.
                    ElevatedButton.icon(
                      onPressed: _exportRawData,
                      icon: const Icon(Icons.storage),
                      label: const Text('Full Backup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Refresh button to reload the analytics view.
                    ElevatedButton(
                      onPressed: loadAnalytics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Main content area: shows a loader while data is being fetched.
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary statistics cards.
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Requests',
                              analytics['totalRequests']?.toString() ?? '0',
                              Icons.bloodtype,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildSummaryCard(
                              'Blood Types',
                              analytics['bloodTypeStats']?.length.toString() ?? '0',
                              Icons.analytics,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildSummaryCard(
                              'Status Types',
                              analytics['statusStats']?.length.toString() ?? '0',
                              Icons.pending_actions,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Section showing the distribution of blood requests by type.
                      const Text(
                        'Blood Type Distribution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildBloodTypeStats(analytics['bloodTypeStats'] ?? {}),
                      const SizedBox(height: 30),

                      // Section showing the distribution of requests by their current status.
                      const Text(
                        'Request Status Distribution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildStatusStats(analytics['statusStats'] ?? {}),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a simple card to display a single metric value.
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a list of progress bars representing the count of requests for each blood type.
  Widget _buildBloodTypeStats(Map<String, int> stats) {
    if (stats.isEmpty) {
      return const Text('No data available');
    }

    final sortedEntries = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sortedEntries.isNotEmpty ? sortedEntries.first.value : 1;

    return Column(
      children: sortedEntries.map((entry) {
        final percentage = (entry.value / maxValue * 100).clamp(0, 100);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 20,
                    backgroundColor: Colors.grey[200],
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 40,
                child: Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Builds colored boxes showing request counts grouped by their status.
  Widget _buildStatusStats(Map<String, int> stats) {
    if (stats.isEmpty) {
      return const Text('No data available');
    }

    final colorMap = {
      'pending': Colors.orange,
      'approved': Colors.blue,
      'fulfilled': Colors.green,
      'cancelled': Colors.red,
      'expired': Colors.grey,
    };

    final sortedEntries = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: sortedEntries.map((entry) {
        final color = colorMap[entry.key] ?? Colors.grey;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                entry.key.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ==============================================================
  // EXPORT 1: The Summary Analytics Report
  // ==============================================================
  /// Generates and triggers the download of a summarized system CSV report.
  void _exportAnalyticsReport() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compiling System Report...')),
    );

    try {
      final statsReport = await _firebase.getSystemStatisticsReport();
      final csvString = _convertToCsv(statsReport);

      final date = DateTime.now();
      final fileName = 'LifeDrop_System_Report_${date.year}-${date.month}-${date.day}';

      _downloadWebFile(csvString, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('System Report downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==============================================================
  // EXPORT 2: The Raw Data Backup
  // ==============================================================
  /// Downloads two CSV files containing the raw data for users and blood requests.
  void _exportRawData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gathering raw database backup...')),
    );

    try {
      final usersData = await _firebase.exportData('users');
      final requestsData = await _firebase.exportData('blood_requests');

      final usersCsv = _convertToCsv(usersData);
      final requestsCsv = _convertToCsv(requestsData);

      // Download the first file (Users).
      _downloadWebFile(usersCsv, 'lifedrop_users_backup');

      // Add a slight delay to ensure browsers don't block multiple concurrent downloads.
      await Future.delayed(const Duration(milliseconds: 500));

      // Download the second file (Requests).
      _downloadWebFile(requestsCsv, 'lifedrop_requests_backup');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully backed up ${usersData.length} users and ${requestsData.length} requests!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==============================================================
  // UTILITY: Converts Firebase JSON Map into a CSV String
  // ==============================================================
  /// Logic to transform a list of maps into a standardized CSV string for export.
  String _convertToCsv(List<Map<String, dynamic>> dataList) {
    if (dataList.isEmpty) return '';

    // Use the keys from the first object as CSV headers.
    List<String> headers = dataList.first.keys.toList();
    String csv = '${headers.join(',')}\n';

    // Loop through each row of data.
    for (var row in dataList) {
      List<String> values = [];
      for (var header in headers) {
        var value = row[header];
        String stringValue = value?.toString() ?? '';

        // Handle escaping for special characters in CSV fields (quotes, commas, newlines).
        if (stringValue.contains(',') || stringValue.contains('"') || stringValue.contains('\n')) {
          stringValue = '"${stringValue.replaceAll('"', '""')}"';
        }
        values.add(stringValue);
      }
      csv += '${values.join(',')}\n';
    }
    return csv;
  }

  // ==============================================================
  // UTILITY: Triggers the browser's native download manager
  // ==============================================================
  /// Uses dart:html to create a blob and trigger a client-side file download.
  void _downloadWebFile(String csvString, String fileName) {
    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element and programmatically click it to start the download.
    html.AnchorElement(href: url)
      ..setAttribute("download", "$fileName.csv")
      ..click();

    // Clean up by revoking the object URL.
    html.Url.revokeObjectUrl(url);
  }
}
