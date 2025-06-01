import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../model/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Lấy danh sách tất cả người dùng
  Stream<List<User>> getUsers() {
    return _firestore.collection('user').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  // Lấy thông tin người dùng theo ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('user').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return User.fromFirestore(doc.id, data);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Thêm người dùng mới
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      // Lấy UID từ userData (đã được set trong add_user.dart)
      final String uid = userData['uid'] as String;
      if (uid.isEmpty) {
        throw Exception('UID không được để trống');
      }

      // Đảm bảo role_id được set là 2
      final dataToSave = {
        ...userData,
        'UserID': uid, // Sử dụng UID làm UserID
        'role_id': 2, // Đảm bảo role_id luôn là 2
        'vip': false, // Thêm trường vip mặc định là false
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Log để kiểm tra dữ liệu trước khi lưu
      print('Saving user data: $dataToSave');

      // Sử dụng UID làm document ID
      await _firestore.collection('user').doc(uid).set(dataToSave);
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('user').doc(userId).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Xóa người dùng
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('user').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
