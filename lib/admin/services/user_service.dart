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
      // Lấy số lượng document hiện tại
      final snapshot = await _firestore.collection('user').get();
      final nextIndex = snapshot.docs.length + 1;
      final docId = 'user${nextIndex.toString().padLeft(2, '0')}';

      await _firestore.collection('user').doc(docId).set({
        ...userData,
        'UserID': nextIndex,
        'createdAt': FieldValue.serverTimestamp(),
      });
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
