import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../add_animal/add_animal_item.dart';
// Import widget CircularCategoryChip

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class AnimalInfoScreen extends StatefulWidget {
  // Dữ liệu động vật cụ thể cần hiển thị (Giả định)
  // Trong thực tế, bạn sẽ nhận đối tượng Animal này thông qua arguments khi điều hướng đến màn hình này
  const AnimalInfoScreen({Key? key}) : super(key: key);

  @override
  State<AnimalInfoScreen> createState() => _AnimalInfoScreenState();
}

class _AnimalInfoScreenState extends State<AnimalInfoScreen> {

  int _selectedHabitatIndex = -1; // -1 nghĩa là chưa chọn
  int _selectedFoodIndex = -1;

  // Dữ liệu giả định cho các mục phân loại
  final List<Map<String, dynamic>> _habitats = [
    {'icon': Icons.forest, 'label': 'Rừng rậm'},
    {'icon': Icons.grass, 'label': 'Thảo nguyên'},
    {'icon': Icons.water_drop, 'label': 'Nước ngọt'},
    {'icon': Icons.waves, 'label': 'Nước mặn'},
    // Thêm môi trường sống khác nếu cần
  ];

  final List<Map<String, dynamic>> _foods = [
    {'icon': Icons.grass, 'label': 'Ăn Cỏ'}, // Có thể dùng icon khác cho ăn cỏ
    {'icon': Icons.fastfood, 'label': 'Ăn Thịt'}, // Có thể dùng icon khác cho ăn thịt
    // Thêm loại thức ăn khác nếu cần
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Hoặc GoRouter.of(context).pop();
          },
        ),
        title: const Text('Thông tin động vật'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Xử lý khi bấm nút "SỬA" (ví dụ: điều hướng đến màn hình chỉnh sửa)
            },
            child: const Text('SỬA', style: TextStyle(color: Colors.orange)), // Màu cam cho nút SỬA
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView( // Cho phép cuộn toàn bộ nội dung
          padding: const EdgeInsets.all(16.0), // Padding cho toàn bộ nội dung
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Khu vực hình ảnh lớn và labels ---
              Stack(
                clipBehavior: Clip.none, // Cho phép các widget con hiển thị bên ngoài bounds
                children: [
                  // Placeholder Hình ảnh lớn
                  Container(
                    width: double.infinity, // Chiếm hết chiều rộng
                    height: 200, // Chiều cao cố định
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0), // Bo tròn góc
                    ),
                    // TODO: Thêm Image.asset hoặc Image.network
                  ),
                  // Labels phủ lên ảnh
                  Positioned(
                    bottom: 8.0, // Cách đáy ảnh 8.0
                    left: 8.0, // Cách lề trái ảnh 8.0
                    right: 8.0, // Cách lề phải ảnh 8.0
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildOverlaidLabel('category'), // Label thứ nhất
                        _buildOverlaidLabel('foodType'), // Label thứ hai
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // --- Tên, Phụ đề, Giá, Rating ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded( // Chiếm hết không gian còn lại cho tên và phụ đề
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'name',
                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'subtitle',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  // Giá, ..., View
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            '\$ 200',
                            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(Icons.more_horiz, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Row( // Rating
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4.0),
                          Text(
                            '2000',
                            style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                          // Có thể thêm review count ở đây nếu cần
                          // if (animal.reviewCount != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(left: 4.0),
                          //     child: Text('(${animal.reviewCount} Review)', style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                          //   ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'View', // Text "View"
                        style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // --- Phân loại (các chips hình tròn) ---
              const Text('PHÂN LOẠI', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8.0),
              Row( // Tiêu đề và link "Xem Tất Cả"
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Môi Trường Sống', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      // TODO: Xử lý khi bấm "Xem Tất Cả" Môi Trường Sống
                    },
                    child: const Text('Xem Tất Cả', style: TextStyle(fontSize: 12.0, color: Colors.blue)),
                  ),
                ],
              ),
              // Danh sách Môi Trường Sống cuộn ngang
              Container( // Container giới hạn chiều cao cho danh sách cuộn
                height: 80, // Chiều cao ước tính cho hàng icon/text
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_habitats.length, (index) {
                      final habitat = _habitats[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0), // Khoảng cách giữa các chip
                        child: CircleCategory(
                          icon: habitat['icon'],
                          label: habitat['label'],
                          isSelected: _selectedHabitatIndex == index, // Kiểm tra trạng thái chọn
                          onTap: () {
                            setState(() {
                              _selectedHabitatIndex = index; // Cập nhật trạng thái chọn
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Phân loại (Thức Ăn) ---
              Row( // Tiêu đề và link "Xem Tất Cả"
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thức Ăn', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      // TODO: Xử lý khi bấm "Xem Tất Cả" Thức Ăn
                    },
                    child: const Text('Xem Tất Cả', style: TextStyle(fontSize: 12.0, color: Colors.blue)),
                  ),
                ],
              ),
              // Danh sách Thức Ăn cuộn ngang
              Container( // Container giới hạn chiều cao cho danh sách cuộn
                height: 80, // Chiều cao ước tính cho hàng icon/text
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_foods.length, (index) {
                      final food = _foods[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0), // Khoảng cách giữa các chip
                        child: CircleCategory(
                          icon: food['icon'],
                          label: food['label'],
                          isSelected: _selectedFoodIndex == index, // Kiểm tra trạng thái chọn
                          onTap: () {
                            setState(() {
                              _selectedFoodIndex = index; // Cập nhật trạng thái chọn
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20.0), //Khoảng cách

              // --- Mô tả ---
              const Text('Mô tả', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8.0),
              Text(
                  'description',
                style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20.0), // Khoảng cách trước Bottom Bar

            ],
          ),
        ),
      ),
      // Bottom Navigation Bar (Tái sử dụng)
      // bottomNavigationBar: _buildBottomNavigationBar(), // Cần implement hàm này
      // floatingActionButton: FloatingActionButton(...), // Cần implement nút này
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Cần implement vị trí này
    );
  }

  // Hàm build widget label phủ lên ảnh
  Widget _buildOverlaidLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.black54, // Nền đen trong suốt
        borderRadius: BorderRadius.circular(12.0), // Bo tròn góc
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12.0, color: Colors.white),
      ),
    );
  }
}