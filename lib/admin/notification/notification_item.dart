import 'package:flutter/material.dart';
import 'notification_item.dart'; // Import model NotificationItem

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    Key? key,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder Avatar tròn
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300], // Màu placeholder
            // backgroundImage: NetworkImage(notification.avatarUrl), // Sử dụng ảnh thật nếu có URL
          ),
          const SizedBox(width: 16.0), // Khoảng cách

          // Phần Text thông báo
          Expanded( // Chiếm hết không gian còn lại trừ placeholder bên phải
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên và Hành động
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'name ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                      ),
                      TextSpan(
                        text: 'action',
                        style: TextStyle(color: Colors.grey[700], fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),
                // Thời gian
                Text(
                  'timeAgo',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0), // Khoảng cách

          // Placeholder Hình vuông bên phải
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Màu placeholder
              borderRadius: BorderRadius.circular(8.0), // Bo tròn góc
            ),
            // TODO: Thêm ảnh hoặc nội dung khác nếu cần
          ),
        ],
      ),
    );
  }
}