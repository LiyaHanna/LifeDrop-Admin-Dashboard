import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../widgets/user_card.dart';

/// The screen for managing all registered users in the system.
/// Admins can search for users and filter them by their roles.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Currently selected role filter.
  String _filter = 'all';
  // Stores the search query entered by the admin.
  String _searchQuery = '';

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
              'Users Management',
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
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Dropdown to filter by role.
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(value: 'donor', child: Text('Donors')),
                    DropdownMenuItem(value: 'requester', child: Text('Requesters')),
                    DropdownMenuItem(value: 'both', child: Text('Both (Donors & Requesters)')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
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
            
            // The list of users, fetched in real-time from Firestore.
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Use different service methods based on the active filter.
                stream: _filter == 'all'
                    ? service.getUsers()
                    : _filter == 'donor'
                        ? service.getUsersByRoles(['donor', 'both', 'Donor', 'Both', 'BOTH'])
                        : _filter == 'requester'
                            ? service.getUsersByRoles(['requester', 'both', 'Requester', 'Both', 'BOTH'])
                            : _filter == 'both'
                                ? service.getUsersByRoles(['both', 'Both', 'BOTH'])
                                : service.getUsersByRole(_filter),
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

                  var users = snapshot.data!.docs;

                  // Apply client-side search filtering.
                  if (_searchQuery.isNotEmpty) {
                    users = users.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toString().toLowerCase();
                      final email = (data['email'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery) || email.contains(_searchQuery);
                    }).toList();
                  }

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No users found'),
                    );
                  }

                  // Build the scrollable list of users.
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final doc = users[index];
                      final data = doc.data() as Map<String, dynamic>;
                      // UserCard displays individual user info and provides action callbacks.
                      return UserCard(
                        id: doc.id,
                        data: data,
                        onBlock: (userId, reason) async {
                          try {
                            await service.blockUser(userId, reason);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User blocked successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onUnblock: (userId) async {
                          try {
                            await service.unblockUser(userId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User unblocked successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onVerify: (userId) async {
                          try {
                            await service.verifyUser(userId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User verified successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onDelete: (userId) async {
                          try {
                            await service.deleteUser(userId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User deleted')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onSendNotification: (userId) async {
                          // notification logic will be added later.
                        },
                        onUpdateRole: (userId, role) async {
                          try {
                            await service.updateUserRole(userId, role);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Role updated to $role')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating role: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onUpdateBloodType: (userId, bloodType) async {
                          try {
                            await service.updateUserBloodType(userId, bloodType);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Blood type updated to $bloodType')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating blood type: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
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
