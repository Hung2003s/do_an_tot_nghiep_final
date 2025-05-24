import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
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
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phylumController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();
  final TextEditingController _kingdomController = TextEditingController();

  // Biến trạng thái cho Checkboxes
  bool _isPremium = false;
  bool _isFree = false;

  // Biến trạng thái cho các mục phân loại được chọn
  int _selectedHabitatIndex = -1;
  int _selectedFoodIndex = -1;
  int _selectedPeriodIndex = -1;

  // Dữ liệu giả định cho các mục phân loại
  final List<Map<String, dynamic>> _habitats = [
    {'icon': Icons.forest, 'label': 'Rừng rậm'},
    {'icon': Icons.grass, 'label': 'Thảo nguyên'},
    {'icon': Icons.water_drop, 'label': 'Nước ngọt'},
    {'icon': Icons.waves, 'label': 'Nước mặn'},
    {'icon': Icons.agriculture, 'label': 'Nông trại'},
    {'icon': Icons.cloud, 'label': 'Bầu trời'},
  ];

  final List<Map<String, dynamic>> _foods = [
    {'icon': Icons.grass, 'label': 'Ăn Cỏ'},
    {'icon': Icons.fastfood, 'label': 'Ăn Thịt'},
  ];

  final List<Map<String, dynamic>> _periods = [
    {'icon': Icons.history, 'label': 'Hiện đại'},
    {'icon': Icons.history_edu, 'label': 'Tiền sử'},
  ];

  // Thêm biến để lưu thông tin file GLB
  String? _glbFileName;
  String? _glbFilePath;

  @override
  void dispose() {
    // Giải phóng controllers khi widget bị hủy
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _phylumController.dispose();
    _classController.dispose();
    _orderController.dispose();
    _kingdomController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nút RESET được bấm
  void _resetForm() {
    _nameController.clear();
    _nameEnController.clear();
    _descriptionController.clear();
    _phylumController.clear();
    _classController.clear();
    _orderController.clear();
    _kingdomController.clear();
    setState(() {
      _isPremium = false;
      _isFree = false;
      _selectedHabitatIndex = -1;
      _selectedFoodIndex = -1;
      _selectedPeriodIndex = -1;
      _glbFileName = null;
      _glbFilePath = null;
    });
    // TODO: Reset các trạng thái khác nếu có (ví dụ: ảnh đã chọn)
  }

  // Hàm xử lý khi nút LƯU THAY ĐỔI được bấm
  void _saveChanges() {
    final animalName = _nameController.text;
    final animalNameEn = _nameEnController.text;
    final description = _descriptionController.text;
    final phylum = _phylumController.text;
    final animalClass = _classController.text;
    final order = _orderController.text;
    final kingdom = _kingdomController.text;

    final selectedHabitat = _selectedHabitatIndex != -1
        ? _habitats[_selectedHabitatIndex]['label']
        : null;
    final selectedFood =
        _selectedFoodIndex != -1 ? _foods[_selectedFoodIndex]['label'] : null;
    final selectedPeriod = _selectedPeriodIndex != -1
        ? _periods[_selectedPeriodIndex]['label']
        : null;

    print('Tên động vật (VN): $animalName');
    print('Tên động vật (EN): $animalNameEn');
    print('Cao cấp: $_isPremium, Miễn phí: $_isFree');
    print('Môi trường sống: $selectedHabitat');
    print('Thức ăn: $selectedFood');
    print('Thời kỳ: $selectedPeriod');
    print('Ngành: $phylum');
    print('Lớp: $animalClass');
    print('Bộ: $order');
    print('Giới: $kingdom');
    print('Mô tả: $description');
    print('File GLB: $_glbFileName');
    print('Đường dẫn file: $_glbFilePath');

    // TODO: Xử lý việc lưu dữ liệu (gửi lên API, lưu vào DB, v.v.)
    // Navigator.pop(context); // Đóng màn hình sau khi lưu
  }

  // Hàm để chọn file GLB
  Future<void> _pickGLBFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb'],
      );

      if (result != null) {
        setState(() {
          _glbFileName = result.files.single.name;
          _glbFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thêm động vật mới'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: const Text('RESET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Tên động vật (Tiếng Việt) ---
            const Text('TÊN ĐỘNG VẬT (TIẾNG VIỆT)',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Cá sấu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 20.0),

            // --- Tên động vật (Tiếng Anh) ---
            const Text('TÊN ĐỘNG VẬT (TIẾNG ANH)',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _nameEnController,
              decoration: InputDecoration(
                hintText: 'Crocodile',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 20.0),

            // --- Phân loại khoa học ---
            const Text('PHÂN LOẠI KHOA HỌC',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),

            // Giới
            TextFormField(
              controller: _kingdomController,
              decoration: InputDecoration(
                hintText: 'Giới (Kingdom)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 12.0),

            // Ngành
            TextFormField(
              controller: _phylumController,
              decoration: InputDecoration(
                hintText: 'Ngành (Phylum)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 12.0),

            // Lớp
            TextFormField(
              controller: _classController,
              decoration: InputDecoration(
                hintText: 'Lớp (Class)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 12.0),

            // Bộ
            TextFormField(
              controller: _orderController,
              decoration: InputDecoration(
                hintText: 'Bộ (Order)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 20.0),

            // --- Đăng hình ảnh ---
            const Text('ĐĂNG HÌNH ẢNH',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.cloud_upload,
                            size: 24, color: Colors.grey),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.grid_view,
                            size: 24, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // Thêm phần upload file GLB sau phần đăng hình ảnh
            const SizedBox(height: 20.0),
            const Text('UPLOAD FILE 3D (GLB)',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _glbFileName ?? 'Chưa chọn file',
                          style: TextStyle(
                            color: _glbFileName != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton.icon(
                        onPressed: _pickGLBFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Chọn file'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_glbFileName != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      'Định dạng: GLB',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // --- Loại tài khoản ---
            const Text('LOẠI TÀI KHOẢN',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _isPremium,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _isPremium = newValue ?? false;
                          if (_isPremium) _isFree = false;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                    const Text('Cao cấp'),
                  ],
                ),
                const SizedBox(width: 16.0),
                Row(
                  children: [
                    Checkbox(
                      value: _isFree,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _isFree = newValue ?? false;
                          if (_isFree) _isPremium = false;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                    const Text('Miễn phí'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // --- Thời kỳ sống ---
            const Text('THỜI KỲ SỐNG',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            Container(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_periods.length, (index) {
                    final period = _periods[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CircleCategory(
                        icon: period['icon'],
                        label: period['label'],
                        isSelected: _selectedPeriodIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedPeriodIndex = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // --- Phân loại (Môi Trường Sống) ---
            const Text('MÔI TRƯỜNG SỐNG',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            Container(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_habitats.length, (index) {
                    final habitat = _habitats[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CircleCategory(
                        icon: habitat['icon'],
                        label: habitat['label'],
                        isSelected: _selectedHabitatIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedHabitatIndex = index;
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
            const Text('THỨC ĂN',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            Container(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_foods.length, (index) {
                    final food = _foods[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CircleCategory(
                        icon: food['icon'],
                        label: food['label'],
                        isSelected: _selectedFoodIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedFoodIndex = index;
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
            const Text('MÔ TẢ',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _descriptionController,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Có lẽ ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 30.0),

            // --- Nút LƯU THAY ĐỔI ---
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: const Text(
                  'LƯU THAY ĐỔI',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
