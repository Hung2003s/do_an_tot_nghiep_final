import 'package:flutter/material.dart';
 // Import widget NotificationListItem
import 'messenger_item.dart';
import 'notification_item.dart'; // Import model NotificationItem

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu thông báo giả định
  // final List<NotificationItem> _notifications = [
  //   NotificationItem(avatarUrl: '', name: 'Tanbir Ahmed', action: 'Placed a new order', timeAgo: '20 min ago', rightPlaceholderUrl: ''),
  //   NotificationItem(avatarUrl: '', name: 'Sallim Smith', action: 'left a 5 star review', timeAgo: '20 min ago', rightPlaceholderUrl: ''),
  //   NotificationItem(avatarUrl: '', name: 'Royal Bengal', action: 'agreed to cancel', timeAgo: '20 min ago', rightPlaceholderUrl: ''),
  //   NotificationItem(avatarUrl: '', name: 'Pabel Vulya', action: 'Placed a new order', timeAgo: '20 min ago', rightPlaceholderUrl: ''),
  //   // Thêm các thông báo khác ở đây
  // ];

  // Dữ liệu tin nhắn giả định (Chỉ là placeholder cho ví dụ này)
  final List<String> _messages = ['Tin nhắn 1', 'Tin nhắn 2', 'Tin nhắn 3'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tab
  }

  @override
  void dispose() {
    _tabController.dispose(); // Giải phóng tab controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        title: const Text('Thông báo'),
        centerTitle: true, // Căn giữa tiêu đề
        bottom: TabBar( // Tab Bar ở dưới AppBar
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông báo'),
            Tab(text: 'Tin nhắn'),
          ],
          indicatorColor: Colors.orange, // Màu gạch chân tab được chọn
          labelColor: Colors.orange, // Màu chữ tab được chọn
          unselectedLabelColor: Colors.grey, // Màu chữ tab không được chọn
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: TabBarView( // Nội dung của Tab Bar
        controller: _tabController,
        children: [
          // Tab "Thông báo"
          _buildNotificationTab(),
          // Tab "Tin nhắn" (Placeholder)
          _buildMessageTab(),
        ],
      ),
      // Bottom Navigation Bar (Tái sử dụng từ màn hình trước)
      // bottomNavigationBar: _buildBottomNavigationBar(), // Cần implement hàm này
      // floatingActionButton: FloatingActionButton(...), // Cần implement nút này
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Cần implement vị trí này
    );
  }

  // Hàm build nội dung tab "Thông báo"
  Widget _buildNotificationTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding ngang cho danh sách
      itemCount: 6,
      itemBuilder: (context, index) {
        // final notification = _notifications[index];
        return NotificationListItem();
      },
    );
  }

  // Hàm build nội dung tab "Tin nhắn" (Placeholder)
  Widget _buildMessageTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      margin: EdgeInsets.only(bottom: 5),
      child: Center( // Chỉ là placeholder
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Ví dụ hiển thị danh sách tin nhắn giả định
            Expanded( // Đảm bảo ListView chiếm hết không gian trong Column
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return MessageListItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// TODO: Implement hàm build Bottom Navigation Bar (tái sử dụng từ màn hình trước)
// Widget _buildBottomNavigationBar() {
//   return BottomAppBar(...);
// }
}