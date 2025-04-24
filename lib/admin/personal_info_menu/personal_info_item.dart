import 'package:flutter/material.dart';

class MenuListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor; // Màu nền của icon
  final String label;
  final Widget? rightWidget; // Widget tùy chọn ở bên phải (mũi tên hoặc giá trị)
  final VoidCallback? onTap; // Callback khi mục được bấm

  const MenuListItem({
    Key? key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.label,
    this.rightWidget,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell( // Sử dụng InkWell để có hiệu ứng gợn sóng khi bấm
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding cho mục
        decoration: BoxDecoration(
          color: Colors.white, // Nền màu trắng cho mục
          borderRadius: BorderRadius.circular(8.0), // Bo tròn góc nhẹ
          boxShadow: [ // Thêm bóng đổ nhẹ
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // Vị trí bóng đổ
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 12.0), // Khoảng cách dưới mỗi mục
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon với nền màu
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: iconBackgroundColor, // Màu nền icon
                shape: BoxShape.circle, // Hình tròn (hoặc BoxShape.rectangle với borderRadius nếu muốn vuông bo tròn)
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white, // Màu icon (thường là trắng trên nền màu)
              ),
            ),
            const SizedBox(width: 16.0), // Khoảng cách

            // Label
            Expanded( // Chiếm hết không gian còn lại cho label
              child: Text(
                label,
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ),

            // Widget bên phải (mũi tên hoặc giá trị)
            if (rightWidget != null) // Chỉ hiển thị nếu rightWidget được cung cấp
              rightWidget!,
          ],
        ),
      ),
    );
  }
}