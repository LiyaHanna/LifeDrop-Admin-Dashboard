import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service class that handles all interactions with Firebase services (Firestore, Auth, and Storage).
class FirebaseService {
  // Singleton pattern to ensure only one instance of FirebaseService exists.
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Instances of Firebase services.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Collection references for easy access to Firestore data.
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference requestsCollection = FirebaseFirestore.instance.collection('blood_requests');
  final CollectionReference hospitalsCollection = FirebaseFirestore.instance.collection('hospitals');
  final CollectionReference bloodBanksCollection = FirebaseFirestore.instance.collection('blood_banks');

  /// Placeholder initialization method.
  Future<void> initialize() async {
    print('✅ Firebase service ready!');
  }

  // ==================== AUTHENTICATION ====================

  /// Signs in an administrator using email and password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Provides a stream of user authentication state changes (login/logout).
  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  // ==================== USERS ====================

  /// Retrieves all users ordered by their creation date.
  Stream<QuerySnapshot> getUsers() {
    return usersCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Retrieves users filtered by a specific role.
  Stream<QuerySnapshot> getUsersByRole(String role) {
    return usersCollection
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Retrieves users whose role is within a provided list.
  Stream<QuerySnapshot> getUsersByRoles(List<String> roles) {
    return usersCollection
        .where('role', whereIn: roles)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Updates the active status of a user.
  Future<void> updateUserStatus(String userId, bool isActive) async {
    await usersCollection.doc(userId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Verifies a user and updates their verification-related flags.
  Future<void> verifyUser(String userId) async {
    await usersCollection.doc(userId).update({
      'isVerified': true,
      'verifiedAt': FieldValue.serverTimestamp(),
      'isAccountVerified': true,
      'isDocsVerified': true,
      'accountStatus': 'active',
    });
  }

  /// Blocks a user by setting isBlocked to true and recording the reason.
  Future<void> blockUser(String userId, String reason) async {
    await usersCollection.doc(userId).update({
      'isActive': false,
      'isBlocked': true,
      'blockedAt': FieldValue.serverTimestamp(),
      'blockReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Unblocks a user and restores their active status.
  Future<void> unblockUser(String userId) async {
    await usersCollection.doc(userId).update({
      'isActive': true,
      'isBlocked': false,
      'blockedAt': null,
      'blockReason': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a user document from Firestore.
  Future<void> deleteUser(String userId) async {
    await usersCollection.doc(userId).delete();
  }

  /// Updates a user's role (e.g., to 'Admin').
  Future<void> updateUserRole(String userId, String role) async {
    await usersCollection.doc(userId).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates a user's blood type.
  Future<void> updateUserBloodType(String userId, String bloodType) async {
    await usersCollection.doc(userId).update({
      'bloodType': bloodType,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches data for a specific user.
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await usersCollection.doc(userId).get();
  }

  /// Listens for real-time changes to a specific user's document.
  Stream<DocumentSnapshot> listenToUserData(String userId) {
    return usersCollection.doc(userId).snapshots();
  }

  // ==================== REQUESTS ====================

  /// Retrieves all blood requests ordered by their creation date.
  Stream<QuerySnapshot> getRequests() {
    return requestsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Retrieves blood requests filtered by their status.
  Stream<QuerySnapshot> getRequestsByStatus(String status) {
    return requestsCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Updates the status of a blood request.
  Future<void> updateRequestStatus(String requestId, String status) async {
    await requestsCollection.doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': status == 'completed' ? FieldValue.serverTimestamp() : null,
    });
  }

  /// Assigns a donor to a specific blood request.
  Future<void> assignDonorToRequest(String requestId, String donorId, String donorName) async {
    await requestsCollection.doc(requestId).update({
      'donorId': donorId,
      'donorName': donorName,
      'status': 'approved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a blood request document.
  Future<void> deleteRequest(String requestId) async {
    await requestsCollection.doc(requestId).delete();
  }

  /// Checks all pending blood requests and marks them as 'expired' if they were created more than 48 hours ago.
  Future<void> checkAndExpireRequests() async {
    try {
      final now = DateTime.now();
      final threshold = now.subtract(const Duration(hours: 48));

      final querySnapshot = await requestsCollection
          .where('status', isEqualTo: 'pending')
          .where('createdAt', isLessThan: Timestamp.fromDate(threshold))
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error checking and expiring requests: $e');
    }
  }

  // ==================== HOSPITALS ====================

  /// Retrieves all hospitals ordered by name.
  Stream<QuerySnapshot> getHospitals() {
    return hospitalsCollection
        .orderBy('name')
        .snapshots();
  }

  /// Adds a new hospital to Firestore.
  Future<void> addHospital(Map<String, dynamic> data) async {
    await hospitalsCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  /// Updates an existing hospital's information.
  Future<void> updateHospital(String hospitalId, Map<String, dynamic> data) async {
    await hospitalsCollection.doc(hospitalId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a hospital document.
  Future<void> deleteHospital(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(documentId)
          .delete();
      print('Hospital successfully deleted!');
    } catch (e) {
      print('Error deleting hospital: $e');
      throw e;
    }
  }

  // ==================== BLOOD BANKS ====================

  /// Retrieves all blood banks ordered by name.
  Stream<QuerySnapshot> getBloodBanks() {
    return bloodBanksCollection
        .orderBy('name')
        .snapshots();
  }

  /// Adds a new blood bank to Firestore.
  Future<void> addBloodBank(Map<String, dynamic> data) async {
    await bloodBanksCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  /// Updates an existing blood bank's information.
  Future<void> updateBloodBank(String bloodBankId, Map<String, dynamic> data) async {
    await bloodBanksCollection.doc(bloodBankId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a blood bank document.
  Future<void> deleteBloodBank(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('blood_banks')
          .doc(documentId)
          .delete();
      print('Blood bank successfully deleted!');
    } catch (e) {
      print('Error deleting blood bank: $e');
      throw e;
    }
  }

  // ==================== STATISTICS ====================

  /// Fetches various system statistics for the dashboard.
  Future<Map<String, dynamic>> getStats() async {
    await checkAndExpireRequests();
    final usersSnapshot = await usersCollection.get();
    final requestsSnapshot = await requestsCollection.get();
    final hospitalsSnapshot = await hospitalsCollection.get();
    final bloodBanksSnapshot = await bloodBanksCollection.get();

    // Fetch counts for specific categories.
    final pendingRequests = await requestsCollection
        .where('status', isEqualTo: 'pending')
        .get();

    final donors = await usersCollection
        .where('role', whereIn: ['donor', 'both', 'Donor', 'Both', 'BOTH'])
        .get();

    final requesters = await usersCollection
        .where('role', whereIn: ['requester', 'both', 'Requester', 'Both', 'BOTH'])
        .get();

    final verifiedUsers = await usersCollection
        .where('verificationStatus', isEqualTo: 'approved')
        .get();

    // Calculate Blood Type Distribution among all users.
    Map<String, int> bloodTypeDistribution = {
      'A+': 0, 'A-': 0, 'B+': 0, 'B-': 0, 'AB+': 0, 'AB-': 0, 'O+': 0, 'O-': 0
    };

    for (var doc in usersSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['bloodType']?.toString() ?? 'Unknown';
      if (bloodTypeDistribution.containsKey(type)) {
        bloodTypeDistribution[type] = (bloodTypeDistribution[type] ?? 0) + 1;
      }
    }

    return {
      'totalUsers': usersSnapshot.size,
      'totalRequests': requestsSnapshot.size,
      'totalHospitals': hospitalsSnapshot.size,
      'totalBloodBanks': bloodBanksSnapshot.size,
      'pendingRequests': pendingRequests.size,
      'totalDonors': donors.size,
      'totalRequesters': requesters.size,
      'verifiedUsers': verifiedUsers.size,
      'bloodTypeDistribution': bloodTypeDistribution,
    };
  }

  // ==================== STORAGE ====================

  /// Uploads a file to Firebase Storage and returns its download URL.
  Future<String> uploadFile(String path, String fileName, dynamic file) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('$path/$fileName');
      final uploadTask = await ref.putData(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Deletes a file from Firebase Storage using its URL.
  Future<void> deleteFile(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // ==================== MESSAGING ====================

  /// Sends a notification to a specific user by adding it to their Firestore collection.
  Future<void> sendNotification(String userId, String title, String body) async {
    try {
      await firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  // ==================== REPORTS ====================

  /// Fetches data for request analytics reports.
  Future<Map<String, dynamic>> getRequestAnalytics() async {
    await checkAndExpireRequests();
    final snapshot = await requestsCollection.get();
    final Map<String, int> dailyStats = {};
    final Map<String, int> bloodTypeStats = {};
    final Map<String, int> statusStats = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['createdAt'] as Timestamp?)?.toDate();
      final bloodType = data['bloodType'] ?? 'Unknown';
      final status = data['status'] ?? 'Unknown';

      if (date != null) {
        final dateKey = '${date.year}-${date.month}-${date.day}';
        dailyStats[dateKey] = (dailyStats[dateKey] ?? 0) + 1;
      }

      bloodTypeStats[bloodType] = (bloodTypeStats[bloodType] ?? 0) + 1;
      statusStats[status] = (statusStats[status] ?? 0) + 1;
    }

    return {
      'dailyStats': dailyStats,
      'bloodTypeStats': bloodTypeStats,
      'statusStats': statusStats,
      'totalRequests': snapshot.size,
    };
  }

  /// Exports all data from a specified collection as a list of maps.
  Future<List<Map<String, dynamic>>> exportData(String collectionName) async {
    final _db = FirebaseFirestore.instance;
    final snapshot = await _db.collection(collectionName).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include the document ID in the export.
      return data;
    }).toList();
  }

  /// Compiles a comprehensive system statistics report.
  Future<List<Map<String, dynamic>>> getSystemStatisticsReport() async {
    final _db = FirebaseFirestore.instance;

    // Fetch all main collections exactly once.
    final usersSnap = await _db.collection('users').get();
    final requestsSnap = await _db.collection('blood_requests').get();
    final hospitalsSnap = await _db.collection('hospitals').get();
    final banksSnap = await _db.collection('blood_banks').get();

    // 2. Setup our tally counters
    int donors = 0;
    int requesters = 0;
    int adminOrBoth = 0;
    int pendingVerifications = 0;
    Map<String, int> bloodTypeCounts = {};

    // Iterate through users to tally roles and statuses.
    for (var doc in usersSnap.docs) {
      final data = doc.data();

      // Count Roles
      final role = data['role']?.toString().toLowerCase() ?? '';
      if (role == 'donor') {
        donors++;
      } else if (role == 'requester') {
        requesters++;
      } else if (role == 'both') {
        donors++;
        requesters++;
      } else {
        adminOrBoth++;
      }

      // Count Pending Verifications
      if (data['isAccountVerified'] == false || data['isDocsVerified'] == false) {
        pendingVerifications++;
      }

      // Count Blood Types
      final bloodType = data['bloodType']?.toString() ?? 'Unknown';
      if (bloodType.isNotEmpty && bloodType != 'Unknown') {
        bloodTypeCounts[bloodType] = (bloodTypeCounts[bloodType] ?? 0) + 1;
      }
    }

    // Format the report for CSV export.
    List<Map<String, dynamic>> reportCsvRows = [
      {'Metric': 'Total Hospitals', 'Value': hospitalsSnap.size},
      {'Metric': 'Total Blood Banks', 'Value': banksSnap.size},
      {'Metric': 'Total Blood Requests', 'Value': requestsSnap.size},
      {'Metric': 'Total Registered Users', 'Value': usersSnap.size},
      {'Metric': 'Total Donors', 'Value': donors},
      {'Metric': 'Total Requesters', 'Value': requesters},
      {'Metric': 'Admins / Both Roles', 'Value': adminOrBoth},
      {'Metric': 'Users Awaiting Verification', 'Value': pendingVerifications},
      {'Metric': '---', 'Value': '---'},
      {'Metric': 'BLOOD TYPE BREAKDOWN', 'Value': ''},
    ];

    // Add the specific blood type counts dynamically
    final sortedBloodTypes = bloodTypeCounts.keys.toList()..sort();
    for (String type in sortedBloodTypes) {
      reportCsvRows.add({'Metric': 'Users with $type', 'Value': bloodTypeCounts[type]});
    }

    return reportCsvRows;
  }
}
