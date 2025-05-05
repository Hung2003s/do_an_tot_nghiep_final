import 'package:flutter/material.dart';
// Import model MessageItem

class MessageListItem extends StatelessWidget {
  const MessageListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding dọc
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ), // Đường phân cách
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // Căn giữa các mục theo chiều dọc
        children: [
          SizedBox(width: 10),
          // Avatar và chấm trạng thái
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300], // Màu placeholder
                // backgroundImage: NetworkImage(message.avatarUrl), // Ảnh thật
              ),
              // Chấm trạng thái online (Positioned để đặt lên trên avatar)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, // Màu của chấm trạng thái
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ), // Viền trắng
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16.0), // Khoảng cách
          // Tên và tin nhắn cuối
          Expanded(
            // Chiếm hết không gian còn lại trừ phần bên phải
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'lastMessage',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14.0),
                  maxLines: 1, // Giới hạn 1 dòng
                  overflow: TextOverflow.ellipsis, // Hiển thị ... nếu quá dài
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0), // Khoảng cách
          // Thời gian và Badge chưa đọc
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            // Căn sang phải
            mainAxisAlignment: MainAxisAlignment.center,
            // Căn giữa theo chiều dọc
            children: [
              Text(
                'time',
                style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
              ),
              // if (message.unreadCount != null && message.unreadCount! > 0) // Chỉ hiển thị nếu có tin nhắn chưa đọc
              Padding(
                padding: const EdgeInsets.only(top: 4.0), // Khoảng cách trên
                child: Container(
                  padding: const EdgeInsets.all(5.0), // Padding bên trong badge
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange, // Màu nền badge
                  ),
                  child: Text(
                    '3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
