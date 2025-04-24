import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class AnimalListItem extends StatelessWidget {
  const AnimalListItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding dọc cho mỗi item
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0), // Đường phân cách mỏng
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder Ảnh/Biểu tượng
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0), // Bo tròn góc
            ),
            // TODO: Thêm Image.asset hoặc Image.network
          ),
          const SizedBox(width: 16.0), // Khoảng cách

          // Phần Nội dung (Tên, Loại, Rating)
          Expanded( // Chiếm hết không gian còn lại trừ phần bên phải cố định
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'name',
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Container( // Container cho label loại
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.orange[100], // Màu nền nhạt cam
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'phan loai',
                    style: TextStyle(fontSize: 12.0, color: Colors.orange[700]), // Màu chữ cam
                  ),
                ),
                const SizedBox(height: 8.0),
                Row( // Rating
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4.0),
                    Text(
                      '4.5', // Định dạng rating 1 chữ số thập phân
                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    if ('animal.reviewCount' != null) // Hiển thị số review nếu có
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '(10 Review)',
                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Phần bên phải (Giá, ...)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Căn chỉnh sang phải
            children: [
              Row(
                children: [
                  Text(
                    '\$ 200', // Định dạng giá
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(Icons.more_horiz, color: Colors.grey), // Icon ba chấm
                ],
              ),
              const SizedBox(height: 8.0), // Khoảng cách
              const Text(
                'Pick UP', // Text "Pick UP"
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}