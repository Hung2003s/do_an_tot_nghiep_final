import 'package:flutter/material.dart';

class CircleCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CircleCategory({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Gán hàm xử lý khi bấm vào chip
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Hình tròn
              color: isSelected ? Colors.orange[100] : Colors.grey[200], // Màu nền thay đổi khi được chọn
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.orange : Colors.grey[700], // Màu icon thay đổi khi được chọn
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: isSelected ? Colors.orange : Colors.grey[700], // Màu chữ thay đổi khi được chọn
            ),
          ),
        ],
      ),
    );
  }
}