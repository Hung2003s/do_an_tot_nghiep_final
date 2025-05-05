// user.dart (Cập nhật model nếu cần)
enum Gender { male, female, unknown } // Thêm enum cho Giới tính

class User {
  final String name; // Có thể giữ lại name chung hoặc tách thành firstName, lastName
  final String userId;
  final String avatarUrl; // Hoặc placeholder type
  final String? middleLastName; // Họ và tên đệm
  final String? firstName; // Tên
  final String? phoneNumber;
  final String? email;
  final DateTime? dateOfBirth;
  final Gender? gender; // Sử dụng enum Gender

  User({
    required this.name, // Giữ lại nếu cần tên đầy đủ
    required this.userId,
    required this.avatarUrl,
    this.middleLastName,
    this.firstName,
    this.phoneNumber,
    this.email,
    this.dateOfBirth,
    this.gender,
  });
}