import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String phoneNumber;
  final String? role; // 'vendor' or 'customer'
  final String? name;
  
  // Vendor specific fields
  final bool? isOnline;
  final GeoPoint? location;
  final DateTime? lastUpdated;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.role,
    this.name,
    this.isOnline,
    this.location,
    this.lastUpdated,
  });

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? role,
    String? name,
    bool? isOnline,
    GeoPoint? location,
    DateTime? lastUpdated,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'role': role,
      'name': name,
      'isOnline': isOnline,
      'location': location,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    Timestamp? lastUpdatedTimestamp = map['lastUpdated'] as Timestamp?;
    return UserModel(
      id: documentId,
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'],
      name: map['name'],
      isOnline: map['isOnline'],
      location: map['location'] as GeoPoint?,
      lastUpdated: lastUpdatedTimestamp?.toDate(),
    );
  }
}
