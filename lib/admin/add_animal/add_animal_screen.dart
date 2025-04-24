import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'add_animal_item.dart';
 // Import widget CategoryChip

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({Key? key}) : super(key: key);

  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  // Controllers cho Text Input Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Biến trạng thái cho Checkboxes
  bool _isPremium = false;
  bool _isFree = false;

  // Biến trạng thái cho các mục phân loại được chọn (Ví dụ: chỉ lưu index)
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
  void dispose() {
    // Giải phóng controllers khi widget bị hủy
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nút RESET được bấm
  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    setState(() {
      _isPremium = false;
      _isFree = false;
      _selectedHabitatIndex = -1;
      _selectedFoodIndex = -1;
    });
    // TODO: Reset các trạng thái khác nếu có (ví dụ: ảnh đã chọn)
  }

  // Hàm xử lý khi nút LƯU THAY ĐỔI được bấm
  void _saveChanges() {
    // TODO: Thu thập dữ liệu từ các trường input và trạng thái
    final animalName = _nameController.text;
    final price = double.tryParse(_priceController.text); // Cố gắng parse giá
    final description = _descriptionController.text;

    final selectedHabitat = _selectedHabitatIndex != -1 ? _habitats[_selectedHabitatIndex]['label'] : null;
    final selectedFood = _selectedFoodIndex != -1 ? _foods[_selectedFoodIndex]['label'] : null;

    print('Tên động vật: $animalName');
    print('Giá: $price');
    print('Cao cấp: $_isPremium, Miễn phí: $_isFree');
    print('Môi trường sống: $selectedHabitat');
    print('Thức ăn: $selectedFood');
    print('Mô tả: $description');

    // TODO: Xử lý việc lưu dữ liệu (gửi lên API, lưu vào DB, v.v.)
    // Navigator.pop(context); // Đóng màn hình sau khi lưu
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
        title: const Text('Thêm động vật mới'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetForm, // Gọi hàm reset khi bấm
            child: const Text('RESET', style: TextStyle(color: Colors.red)), // Màu đỏ cho nút RESET
          ),
        ],
      ),
      body: SingleChildScrollView( // Cho phép cuộn toàn bộ form
        padding: const EdgeInsets.all(16.0), // Padding cho toàn bộ nội dung form
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh các mục con sang trái
          children: [
            // --- Tên động vật ---
            const Text('TÊN ĐỘNG VẬT', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _nameController, // Gán controller
              decoration: InputDecoration( // Styling cho input
                hintText: 'Cá sấu',
                border: OutlineInputBorder( // Viền bo tròn
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none, // Bỏ viền mặc định
                ),
                filled: true, // Nền màu
                fillColor: Colors.grey[200], // Màu nền
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0), // Padding nội dung
              ),
            ),
            const SizedBox(height: 20.0),

            // --- Đăng hình ảnh ---
            const Text('ĐĂNG HÌNH ẢNH', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8.0),
            Row(
              children: [
                // Placeholder Ảnh chính
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  // TODO: Hiển thị ảnh đã chọn
                ),
                const SizedBox(width: 16.0),
                // Khu vực thêm ảnh
                Expanded( // Chiếm hết không gian còn lại
                  child: Row( // Có thể là GridView nếu muốn nhiều ảnh nhỏ
                    children: [
                      // Icon thêm ảnh
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.cloud_upload, size: 24, color: Colors.grey),
                      ),
                      const SizedBox(width: 8.0),
                      // Icon thêm ảnh khác
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.grid_view, size: 24, color: Colors.grey),
                      ),
                      // TODO: Thêm chức năng chọn ảnh
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // --- Trả phí ---
            const Text('TRẢ PHÍ', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8.0),
            Row(
              children: [
                // Input Giá
                Expanded( // Chiếm một phần không gian
                  flex: 1, // Tỉ lệ chiếm không gian
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true), // Bàn phím số
                    decoration: InputDecoration(
                      prefixText: '\$', // Hiển thị $ phía trước
                      hintText: '50',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Checkboxes
                Expanded( // Chiếm phần còn lại
                  flex: 2, // Tỉ lệ chiếm không gian
                  child: Row(
                    children: [
                      Row( // Checkbox Cao cấp
                        children: [
                          Checkbox(
                            value: _isPremium,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isPremium = newValue ?? false;
                                if (_isPremium) _isFree = false; // Nếu chọn Cao cấp thì bỏ chọn Miễn phí
                              });
                            },
                            activeColor: Colors.orange, // Màu khi được chọn
                          ),
                          const Text('Cao cấp'),
                        ],
                      ),
                      const SizedBox(width: 8.0),
                      Row( // Checkbox Miễn phí
                        children: [
                          Checkbox(
                            value: _isFree,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isFree = newValue ?? false;
                                if (_isFree) _isPremium = false; // Nếu chọn Miễn phí thì bỏ chọn Cao cấp
                              });
                            },
                            activeColor: Colors.orange,
                          ),
                          const Text('Miễn phí'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // --- Phân loại (Môi Trường Sống) ---
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
            const SizedBox(height: 20.0),

            // --- Mô tả ---
            const Text('MÔ TẢ', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _descriptionController,
              maxLines: null, // Cho phép nhập nhiều dòng
              minLines: 4, // Chiều cao tối thiểu là 4 dòng
              keyboardType: TextInputType.multiline, // Kiểu bàn phím cho nhiều dòng
              decoration: InputDecoration( // Styling cho input
                hintText: 'Có lẽ ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 30.0), // Khoảng cách trước nút Lưu

            // --- Nút LƯU THAY ĐỔI ---
            Center( // Căn giữa nút
              child: ElevatedButton(
                onPressed: _saveChanges, // Gọi hàm lưu thay đổi
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Màu nền cam
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0), // Padding nút
                  shape: RoundedRectangleBorder( // Bo tròn góc
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(double.infinity, 50), // Chiếm hết chiều rộng và chiều cao tối thiểu
                ),
                child: const Text(
                  'LƯU THAY ĐỔI',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16.0), // Khoảng trống cuối màn hình
          ],
        ),
      ),
    );
  }
}