import 'package:cloud_firestore/cloud_firestore.dart';

// user.dart (Cập nhật model cho đúng với Firestore)
enum Gender { male, female, unknown }

class User {
  final String docId; // Document ID trong Firestore
  final String userId; // UserID trong Firestore
  final String firstName; // FirstName
  final String lastName; // LastName
  final String gender; // Gender (Nam/Nữ)
  final DateTime? dateOfBirth; // DateOfBirth
  final String email; // Email
  final String phoneNumber; // Phone_number
  final String avatarUrl; // avatar
  final int roleId; // role_id

  User({
    required this.docId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.roleId,
  });

  // Hàm tạo User từ Firestore document
  factory User.fromFirestore(String id, Map<String, dynamic> data) {
    return User(
      docId: id,
      userId: data['UserID'].toString(),
      firstName: data['FirstName'] ?? '',
      lastName: data['LastName'] ?? '',
      gender: data['Gender'] ?? '',
      dateOfBirth: data['DateOfBirth'] != null
          ? (data['DateOfBirth'] is Timestamp
              ? (data['DateOfBirth'] as Timestamp).toDate()
              : data['DateOfBirth'] as DateTime)
          : null,
      email: data['Email'] ?? '',
      phoneNumber: data['Phone_number'] ?? '',
      avatarUrl: data['avatar'] ?? '',
      roleId: data['role_id'] is int
          ? data['role_id']
          : int.tryParse(data['role_id']?.toString() ?? '0') ?? 0,
    );
  }
}
