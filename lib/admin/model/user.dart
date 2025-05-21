import 'package:cloud_firestore/cloud_firestore.dart';

// user.dart (Cập nhật model cho đúng với Firestore)
enum Gender { male, female, unknown }

class User {
  final String docId; // Document ID trong Firestore
  final String userId; // UserID trong Firestore
  final String firstName; // FirstName
  final String lastName; // LastName
  final String gender; // Gender (Nam/Nữ)
  final DateTime? dateOfBirth; // DateofBirth
  final String parentEmail; // ParentEmail
  final String parentNumber; // ParentNumber
  final String avatarUrl; // avatar

  User({
    required this.docId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.parentEmail,
    required this.parentNumber,
    required this.avatarUrl,
  });

  // Hàm tạo User từ Firestore document
  factory User.fromFirestore(String id, Map<String, dynamic> data) {
    return User(
      docId: id,
      userId: data['UserID'].toString(),
      firstName: data['FirstName'] ?? '',
      lastName: data['LastName'] ?? '',
      gender: data['Gender'] ?? '',
      dateOfBirth: data['DateofBirth'] != null
          ? (data['DateofBirth'] is Timestamp
              ? (data['DateofBirth'] as Timestamp).toDate()
              : data['DateofBirth'] as DateTime)
          : null,
      parentEmail: data['ParentEmail'] ?? '',
      parentNumber: data['ParentNumber'] ?? '',
      avatarUrl: data['avatar'] ?? '',
    );
  }
}
