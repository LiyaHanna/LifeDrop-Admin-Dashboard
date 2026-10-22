import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model class representing a blood request.
class RequestData {
  final String id;
  final String userId;
  final String patientName;
  final String bloodType;
  final int quantity;
  final String status; // Possible values: 'pending', 'approved', 'fulfilled', 'cancelled', 'expired'
  final String urgency; // Possible values: 'low', 'medium', 'high', 'critical'
  final String? hospitalId;
  final String? hospitalName;
  final String? hospitalAddress;
  final String? donorId;
  final String? donorName;
  final String? notes;
  final GeoPoint? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? scheduledAt;
  final DateTime? fulfilledAt;

  RequestData({
    required this.id,
    required this.userId,
    required this.patientName,
    required this.bloodType,
    required this.quantity,
    required this.status,
    required this.urgency,
    this.hospitalId,
    this.hospitalName,
    this.hospitalAddress,
    this.donorId,
    this.donorName,
    this.notes,
    this.location,
    required this.createdAt,
    this.updatedAt,
    this.scheduledAt,
    this.fulfilledAt,
  });

  /// Creates a [RequestData] instance from a Firestore document snapshot.
  factory RequestData.fromFirestore(String id, Map<String, dynamic> data) {
    return RequestData(
      id: id,
      userId: data['userId'] ?? '',
      patientName: data['patientName'] ?? 'Unknown',
      bloodType: data['bloodType'] ?? 'Unknown',
      quantity: data['quantity'] ?? 1,
      status: data['status'] ?? 'pending',
      urgency: data['urgency'] ?? 'medium',
      hospitalId: data['hospitalId'],
      hospitalName: data['hospitalName'],
      hospitalAddress: data['hospitalAddress'],
      donorId: data['donorId'],
      donorName: data['donorName'],
      notes: data['notes'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      fulfilledAt: (data['fulfilledAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Helper getter to determine the appropriate color for the request status.
  String get statusColor {
    switch (status) {
      case 'pending':
        return 'orange';
      case 'approved':
        return 'blue';
      case 'fulfilled':
        return 'green';
      case 'cancelled':
        return 'red';
      case 'expired':
        return 'grey';
      default:
        return 'grey';
    }
  }
}
