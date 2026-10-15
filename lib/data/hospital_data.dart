import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model class representing a hospital.
class HospitalData {
  final String id;
  final String name;
  final String type; //'Hospital' or 'Blood Bank'
  final String address;
  final String phone;
  final String? email;
  final GeoPoint? location;
  final bool isActive;
  final int? bedCount;
  final List<String>? bloodTypesAvailable;
  final String? city;
  final Map<String, int>? bloodInventory;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HospitalData({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    this.email,
    this.location,
    required this.isActive,
    this.bedCount,
    this.bloodTypesAvailable,
    this.city,
    this.bloodInventory,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [HospitalData] instance from a Firestore document snapshot.
  factory HospitalData.fromFirestore(String id, Map<String, dynamic> data) {
    return HospitalData(
      id: id,
      name: data['name'] ?? 'Unknown',
      type: data['type'] ?? 'Hospital', //Fallback to 'Hospital' if missing
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      location: data['location'],
      isActive: data['isActive'] ?? true,
      bedCount: data['bedCount'],
      bloodTypesAvailable: List<String>.from(data['bloodTypesAvailable'] ?? []),
      city: data['city'],
      bloodInventory: Map<String, int>.from(data['bloodInventory'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts the [HospitalData] instance into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type, //Explicitly save the type to Firestore
      'address': address,
      'phone': phone,
      'email': email,
      'location': location,
      'isActive': isActive,
      'bedCount': bedCount,
      'city': city,
      'bloodTypesAvailable': bloodTypesAvailable,
      'bloodInventory': bloodInventory,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Helper getters to access coordinates.
  double? get latitude => location?.latitude;
  double? get longitude => location?.longitude;
}