import 'package:animal_2/admin/personal_info_menu/user_management/add_user.dart';
import 'package:animal_2/admin/personal_info_menu/user_management/user_infomation_screen.dart';
import 'package:animal_2/admin/personal_info_menu/user_management/user_item.dart';
import 'package:animal_2/admin/services/user_service.dart';
import 'package:animal_2/admin/model/user.dart';
import 'package:flutter/material.dart';
// Import widget UserListItem

// Widget chính để quản lý danh sách người dùng
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Khởi tạo service để tương tác với Firebase
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với nút quay lại và nút thêm người dùng
      appBar: AppBar(
        leading: IconButton(
          // Nút quay lại
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Hoặc GoRouter.of(context).pop();
          },
        ),
        title: const Text('Quản lý người dùng'),
        centerTitle: true, // Căn giữa tiêu đề
        actions: [
          // Icon bên phải
        ],
      ),
      body: StreamBuilder(
        stream: _userService.getUsers(),
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          // Hiển thị loading khi đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hiển thị thông báo lỗi nếu có
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          // Hiển thị thông báo khi không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Không có người dùng nào'),
            );
          }

          // Lấy danh sách người dùng và hiển thị
          final users =
              snapshot.data!.where((user) => user.roleId == 2).toList();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                // Xử lý khi nhấn vào một người dùng
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserInfoScreen(user: user),
                    ),
                  );
                },
                // Hiển thị thông tin người dùng và nút xóa
                child: UserListItem(
                  user: user,
                  rightWidget: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Hiển thị dialog xác nhận xóa
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text(
                              'Bạn có chắc chắn muốn xóa người dùng này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );

                      // Xử lý xóa người dùng nếu được xác nhận
                      if (confirmed == true) {
                        try {
                          await _userService.deleteUser(user.docId);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa người dùng thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi khi xóa người dùng: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // Nút '+' nổi ở dưới cùng bên phải
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddUserScreen()));
          // TODO: Xử lý khi bấm nút '+' (ví dụ: điều hướng đến màn hình thêm người dùng mới)
        },
        backgroundColor: Colors.orange, // Màu nền cam
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        shape: const CircleBorder(), // Hình tròn
        elevation: 2.0, // Độ nổi
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Vị trí mặc định
    );
  }
}
