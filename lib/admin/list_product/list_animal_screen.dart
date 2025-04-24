import 'package:flutter/material.dart';
import 'animal_info_screen.dart';
import 'list_animal_item.dart'; // Import widget AnimalListItem
// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({Key? key}) : super(key: key);

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  // Danh sách các danh mục lọc
  final List<String> _categories = ['All', 'Breakfast', 'Lunch', 'Dinner'];
  int _selectedCategoryIndex = 0; // Chỉ mục danh mục đang được chọn

  // Dữ liệu danh sách động vật (Giả định)
  // List<Animal> _allAnimals = [
  //   Animal(name: 'Cá mập', category: 'Nước mặn', rating: 4.9, price: 60.0),
  //   Animal(name: 'Chicken Bhuna', category: 'Breakfast', rating: 4.9, reviewCount: 10, price: 30.0),
  //   Animal(name: 'Mazalichicken Halim', category: 'Breakfast', rating: 4.9, reviewCount: 10, price: 25.0),
  //   // Thêm các đối tượng Animal khác ở đây
  //   Animal(name: 'Sư tử', category: 'Thịt', rating: 4.8, price: 100.0),
  //   Animal(name: 'Bò', category: 'Cỏ', rating: 4.5, reviewCount: 5, price: 40.0),
  //   Animal(name: 'Cá voi', category: 'Nước mặn', rating: 5.0, reviewCount: 20, price: 120.0),
  // ];

  // List<Animal> _filteredAnimals = []; // Danh sách động vật sau khi lọc

  @override
  void initState() {
    super.initState();
    // _filterAnimals(_selectedCategoryIndex); // Lọc danh sách ban đầu khi màn hình khởi tạo
  }

  // Hàm lọc danh sách động vật theo danh mục
  // void _filterAnimals(int index) {
  //   setState(() {
  //     _selectedCategoryIndex = index; // Cập nhật chỉ mục danh mục được chọn
  //     if (index == 0) {
  //       _filteredAnimals = List.from(_allAnimals); // Chọn "All", hiển thị tất cả
  //     } else {
  //       String selectedCategory = _categories[index];
  //       _filteredAnimals = _allAnimals.where((animal) => animal.category == selectedCategory).toList();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // Nút quay lại
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Hoặc GoRouter.of(context).pop();
          },
        ),
        title: const Text('Danh sách động vật'),
        centerTitle: true, // Căn giữa tiêu đề
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh lọc theo danh mục
          _buildCategoryFilter(),

          // Thông báo tổng số lượng và danh sách
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'Tổng cộng: 20', // Hiển thị tổng số sau khi lọc
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
          ),

          // Danh sách động vật (cuộn được và chiếm hết không gian còn lại)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AnimalInfoScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // Padding ngang cho ListView
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    // final animal = _filteredAnimals[index];
                    return AnimalListItem(); // Sử dụng widget item
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar (Tái sử dụng từ màn hình trước)
      // bottomNavigationBar: _buildBottomNavigationBar(), // Cần implement hàm này
      // floatingActionButton: FloatingActionButton(...), // Cần implement nút này
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Cần implement vị trí này
    );
  }

  // Hàm build thanh lọc theo danh mục
  Widget _buildCategoryFilter() {
    return Container(
      height: 50, // Chiều cao cố định cho thanh lọc
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Cho phép cuộn ngang
        child: Row(
          children: List.generate(_categories.length, (index) {
            final category = _categories[index];
            final isSelected =
                _selectedCategoryIndex ==
                index; // Kiểm tra xem đây có phải mục được chọn không

            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              // Khoảng cách giữa các mục lọc
              child: GestureDetector(
                // Sử dụng GestureDetector để có thể bấm vào
                onTap: () {
                  // _filterAnimals(index); // Gọi hàm lọc khi bấm
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight:
                            isSelected
                                ? FontWeight.bold
                                : FontWeight.normal, // Chữ đậm nếu được chọn
                        color:
                            isSelected
                                ? Colors.orange
                                : Colors.grey[700], // Màu cam nếu được chọn
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    if (isSelected) // Hiển thị thanh gạch chân nếu được chọn
                      Container(
                        height: 2.0,
                        width: 30.0,
                        // Chiều rộng thanh gạch chân (có thể điều chỉnh)
                        color: Colors.orange, // Màu thanh gạch chân
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // TODO: Implement hàm build Bottom Navigation Bar (tái sử dụng từ màn hình trước)
  // Widget _buildBottomNavigationBar() {
  //   return BottomAppBar(...);
  // }
}
