import 'package:animal_2/admin/personal_info_menu/user_management/add_user.dart';
import 'package:animal_2/admin/personal_info_menu/user_management/user_infomation_screen.dart';
import 'package:animal_2/admin/personal_info_menu/user_management/user_item.dart';
import 'package:flutter/material.dart';
 // Import widget UserListItem

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Dữ liệu danh sách người dùng giả định
  // Trong ứng dụng thực tế, bạn sẽ lấy dữ liệu này từ API hoặc nguồn khác.
  // List<User> _users = [
  //   User(name: 'Lê Minh Hùng', userId: '1', avatarUrl: ''),
  //   User(name: 'Lê Minh Hùng', userId: '1', avatarUrl: ''),
  //   User(name: 'Lê Minh Hùng', userId: '1', avatarUrl: ''),
  //   // Thêm người dùng khác ở đây
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton( // Nút quay lại
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Hoặc GoRouter.of(context).pop();
          },
        ),
        title: const Text('Quản lý người dùng'),
        centerTitle: true, // Căn giữa tiêu đề
        actions: [ // Icon bên phải
          IconButton(
            icon: const Icon(Icons.code), // Icon mã code
            onPressed: () {
              // TODO: Xử lý khi bấm icon code
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding ngang cho danh sách
        child: ListView.builder(
          itemCount: 3, // Số lượng người dùng
          itemBuilder: (context, index) {
            // final user = _users[index]; // Lấy dữ liệu cho người dùng hiện tại

            // Xác định widget bên phải cho item này
            Widget rightSideWidget;
            if (index == 2) { // Nếu là item cuối cùng
              rightSideWidget = ElevatedButton(
                onPressed: () {
                  // TODO: Xử lý khi bấm nút XÓA cho người dùng cuối cùng
                  print('Bấm XÓA cho UserId: ');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Màu nền cam
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Bo tròn góc
                  ),
                  minimumSize: const Size(0, 36), // Chiều cao tối thiểu
                ),
                child: const Text('XÓA'),
              );
            } else { // Các item khác
              rightSideWidget = Container( // Widget trạng thái "sửa" nhỏ
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xfffff9a2), // Màu nền xám
                ),
                child: Text(
                  'sửa', // Text "sửa"
                  style: TextStyle(fontSize: 10.0, color: Colors.white),
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_)=> UserInfoScreen()));
              },
              child: UserListItem(
                //user: user, // Truyền dữ liệu người dùng
                rightWidget: rightSideWidget, // Truyền widget bên phải đã xác định
              ),
            );
          },
        ),
      ),
      // Nút '+' nổi ở dưới cùng bên phải
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> AddUserScreen()));
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