import 'package:animal_2/admin/personal_info_menu/personal_info_item.dart';
import 'package:animal_2/admin/personal_info_menu/user_management/user_management.dart';
import 'package:flutter/material.dart';

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Màu nền tổng thể
      body: Column(
        children: [
          // --- Phần Header Màu Cam ---
          Container(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0, left: 16.0, right: 16.0), // Padding
            width: double.infinity, // Chiếm hết chiều rộng
            decoration: const BoxDecoration(
              color: Color(0xffFF7622), // Màu nền cam
              borderRadius: BorderRadius.only( // Bo tròn góc dưới
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn trái nội dung
              children: [
                // Nút quay lại và Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48.0),
                    // IconButton(
                    //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    //   onPressed: () {
                    //     Navigator.pop(context); // Quay lại màn hình trước
                    //   },
                    // ),
                    // Text Tiêu đề (có thể cần căn chỉnh nếu không dùng AppBar)
                    const Expanded( // Để tiêu đề chiếm không gian còn lại và có thể căn giữa
                      child: Center(
                        child: Text(
                          'Cài đặt',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48.0), // Khoảng trống để cân bằng với nút back
                  ],
                ),
                const SizedBox(height: 10.0), // Khoảng cách

                // Text "Số tiền hiện có"
                // const Text(
                //   'Số tiền hiện có',
                //   style: TextStyle(fontSize: 16.0, color: Colors.white), // Màu trắng mờ
                // ),
                // const SizedBox(height: 8.0),
                //
                // // Số dư
                // Center(
                //   child: const Text(
                //     '\$500.00',
                //     style: TextStyle(
                //       fontSize: 38.0,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 20.0),
                //
                // // Nút Withdraw
                // Center( // Căn giữa nút
                //   child: OutlinedButton(
                //     onPressed: () {
                //       // TODO: Xử lý khi bấm nút Withdraw
                //     },
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: Colors.white, // Màu chữ
                //       side: const BorderSide(color: Colors.white, width: 1.5), // Viền trắng
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20.0), // Bo tròn góc
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0), // Padding
                //     ),
                //     child: const Text('Rút tiền', style: TextStyle(fontSize: 16.0)),
                //   ),
                // ),
              ],
            ),
          ),

          // --- Danh sách Menu/Tùy chọn ---
          Expanded( // Danh sách chiếm hết không gian còn lại và có thể cuộn
            child: SingleChildScrollView( // Sử dụng SingleChildScrollView cho danh sách
              padding: const EdgeInsets.all(16.0), // Padding cho danh sách
              child: Column( // Sử dụng Column để xếp các MenuListItem
                children: [
                  MenuListItem( // Thông tin cá nhân
                    icon: Icons.person_outline,
                    iconBackgroundColor: Colors.blue, // Màu nền icon
                    label: 'Quản lý sản phẩm',
                    rightWidget: const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey), // Mũi tên
                    onTap: () {
                      // TODO: Điều hướng đến màn hình Thông tin cá nhân
                    },
                  ),
                  MenuListItem( // Cài đặt
                    icon: Icons.settings_outlined,
                    iconBackgroundColor: Colors.purple, // Màu nền icon
                    label: 'Thong ke',
                    rightWidget: const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey), // Mũi tên
                    onTap: () {
                      // TODO: Điều hướng đến màn hình Cài đặt
                    },
                  ),
                  MenuListItem( // Quản lý người dùng
                    icon: Icons.people_outline,
                    iconBackgroundColor: Colors.teal, // Màu nền icon
                    label: 'Quản lý người dùng',
                    rightWidget: const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey), // Mũi tên
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_)=> UserManagementScreen()));
                      // TODO: Điều hướng đến màn hình Quản lý người dùng
                    },
                  ),
                  MenuListItem( // Tổng số lượt xem
                    icon: Icons.visibility_outlined,
                    iconBackgroundColor: Colors.orange, // Màu nền icon
                    label: 'Tổng số lượt xem',
                    rightWidget: const Text('29K', style: TextStyle(fontSize: 16.0, color: Colors.grey)), // Giá trị
                    onTap: () {
                      // TODO: Điều hướng đến màn hình Tổng số lượt xem
                    },
                  ),
                  MenuListItem( // Người xem đề xuất
                    icon: Icons.star_border,
                    iconBackgroundColor: Colors.redAccent, // Màu nền icon
                    label: 'Người xem đề xuất',
                    rightWidget: const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey), // Mũi tên
                    onTap: () {
                      // TODO: Điều hướng đến màn hình Người xem đề xuất
                    },
                  ),
                  MenuListItem( // Log Out
                    icon: Icons.logout_outlined,
                    iconBackgroundColor: Colors.grey, // Màu nền icon
                    label: 'Log Out',
                    rightWidget: const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey), // Mũi tên
                    onTap: () {
                      // TODO: Xử lý logic Log Out
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar (Tái sử dụng)
      // bottomNavigationBar: _buildBottomNavigationBar(), // Cần implement hàm này
      // floatingActionButton: FloatingActionButton(...), // Cần implement nút này
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Cần implement vị trí này
    );
  }

// TODO: Implement hàm build Bottom Navigation Bar (tái sử dụng từ màn hình trước)
// Widget _buildBottomNavigationBar() {
//   return BottomAppBar(...);
// }
}