import 'package:flutter/material.dart';
// Import model User

class UserListItem extends StatelessWidget {

  final Widget rightWidget; // Widget hiển thị ở bên phải (trạng thái, nút xóa, v.v.)

  const UserListItem({
    Key? key,
    required this.rightWidget, // Yêu cầu widget bên phải
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding dọc
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0), // Đường phân cách
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa các mục theo chiều dọc
        children: [
          // Placeholder Avatar tròn
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300], // Màu placeholder
            // backgroundImage: NetworkImage(user.avatarUrl), // Ảnh thật nếu có URL
          ),
          const SizedBox(width: 16.0), // Khoảng cách

          // Tên và User ID
          Expanded( // Chiếm hết không gian còn lại trừ phần bên phải
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
              children: [
                Text(
                  'name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'UserId: 02',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0), // Khoảng cách

          // Widget bên phải (Status hoặc Button)
          rightWidget, // Hiển thị widget được truyền vào
        ],
      ),
    );
  }
}