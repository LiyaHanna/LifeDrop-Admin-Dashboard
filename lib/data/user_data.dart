import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model class representing a user in the LifeDrop system.
class UserData {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String bloodType;
  final String role; // Valid roles: 'requester', 'donor', 'both', 'admin'
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastActive;
  final String? photoURL;
  final Map<String, dynamic>? medicalInfo;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.bloodType,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.lastActive,
    this.photoURL,
    this.medicalInfo,
  });

  // Helper getters for role checks.
  bool get isDonor => role == 'donor' || role == 'both';
  bool get isRequester => role == 'requester' || role == 'both';
  bool get isAdmin => role == 'admin';

  /// Creates a [UserData] instance from a Firestore document snapshot.
  factory UserData.fromFirestore(String id, Map<String, dynamic> data) {
    return UserData(
      id: id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      phone: data['phone'],
      bloodType: data['bloodType'] ?? 'Unknown',
      role: data['role'] ?? 'requester',
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      photoURL: data['photoURL'],
      medicalInfo: data['medicalInfo'],
    );
  }

  /// Converts the [UserData] instance into a map for saving to Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bloodType': bloodType,
      'role': role,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'lastActive': lastActive,
      'photoURL': photoURL,
      'medicalInfo': medicalInfo,
    };
  }
}
