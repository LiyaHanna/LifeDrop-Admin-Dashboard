import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../widgets/request_card.dart';

/// The screen for managing and viewing blood requests submitted by users.
/// Admins can filter requests by status and search for specific patients or blood types.
class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  // Currently active status filter.
  String _filter = 'all';
  // Stores the search query entered by the admin.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkExpiredRequests();
  }

  Future<void> _checkExpiredRequests() async {
    try {
      final service = Provider.of<FirebaseService>(context, listen: false);
      await service.checkAndExpireRequests();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Access the FirebaseService via Provider.
    final service = Provider.of<FirebaseService>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Requests',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Search and Filter Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      // Update search query on every keystroke.
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: 'Search requests...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Dropdown to filter requests by their current status.
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Requests')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  ],
                  onChanged: (value) {
                    setState(() => _filter = value!);
                  },
                ),
                const SizedBox(width: 15),
                // Button to manually refresh the list.
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // The list of blood requests, fetched in real-time from Firestore.
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Use different service methods based on the active filter.
                stream: _filter == 'all'
                    ? service.getRequests()
                    : service.getRequestsByStatus(_filter),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var requests = snapshot.data!.docs;

                  // Apply client-side search filtering based on requester name or blood type.
                  if (_searchQuery.isNotEmpty) {
                    requests = requests.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final requesterName = (data['userName'] ?? data['user_name'] ?? '').toString().toLowerCase();
                      final bloodType = (data['bloodType'] ?? data['blood_type'] ?? '').toString().toLowerCase();
                      return requesterName.contains(_searchQuery) ||
                          bloodType.contains(_searchQuery);
                    }).toList();
                  }

                  if (requests.isEmpty) {
                    return const Center(
                      child: Text('No requests found'),
                    );
                  }

                  // Build the scrollable list of blood requests.
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final doc = requests[index];
                      final data = doc.data() as Map<String, dynamic>;
                      // RequestCard displays individual request info and provides action callbacks.
                      return RequestCard(
                        id: doc.id,
                        data: data,
                        onStatusUpdate: (status) async {
                          await service.updateRequestStatus(doc.id, status);
                        },
                        onDelete: () async {
                          await service.deleteRequest(doc.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
