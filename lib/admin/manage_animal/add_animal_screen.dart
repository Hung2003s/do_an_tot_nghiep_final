import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'add_animal_item.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
// Import widget CategoryChip

class AddAnimalScreen extends StatefulWidget {
  final Map<String, dynamic>? animalData;

  const AddAnimalScreen({Key? key, this.animalData}) : super(key: key);

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
    {'icon': Icons.forest, 'label': 'Rừng rậm', 'name': 'Rừng rậm'},
    {'icon': Icons.grass, 'label': 'Thảo nguyên', 'name': 'Thảo nguyên'},
    {'icon': Icons.water_drop, 'label': 'Nước ngọt', 'name': 'Nước ngọt'},
    {'icon': Icons.waves, 'label': 'Nước mặn', 'name': 'Nước mặn'},
    {'icon': Icons.agriculture, 'label': 'Nông trại', 'name': 'Nông trại'},
    {'icon': Icons.cloud, 'label': 'Bầu trời', 'name': 'Bầu trời'},
  ];

  final List<Map<String, dynamic>> _foods = [
    {'icon': Icons.grass, 'label': 'Ăn Cỏ', 'value': 'Ăn cỏ'},
    {'icon': Icons.fastfood, 'label': 'Ăn Thịt', 'value': 'Ăn thịt'},
    {'icon': Icons.restaurant, 'label': 'Ăn tạp', 'value': 'Ăn tạp'},
  ];

  final List<Map<String, dynamic>> _periods = [
    {'icon': Icons.history, 'label': 'Hiện đại', 'value': 'Hiện đại'},
    {'icon': Icons.history_edu, 'label': 'Tiền sử', 'value': 'Tiền sử'},
  ];

  // Thêm biến để lưu thông tin file GLB
  String? _glbFileName;
  String? _glbFilePath;

  String? _imagePath;

  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.animalData != null) {
      final data = widget.animalData!;
      _nameController.text = data['nameAnimal'] ?? '';
      _nameEnController.text = data['nameAnimalEnglish'] ?? '';
      _descriptionController.text = data['infoAnimal'] ?? '';
      _kingdomController.text = data['plkh']?['gioi'] ?? '';
      _phylumController.text = data['plkh']?['nganh'] ?? '';
      _classController.text = data['plkh']?['lop'] ?? '';
      _orderController.text = data['plkh']?['bo'] ?? '';
      _imagePath = data['imageUrl'];
      _isPremium = data['required_vip'] ?? false;
      _isFree = !(data['required_vip'] ?? false);
      // Habitat index (habitat_id là int, index = id - 1)
      if (data['habitat_id'] != null && data['habitat_id'] is int) {
        _selectedHabitatIndex = (data['habitat_id'] as int) - 1;
      }
      // Food index
      if (data['food'] != null) {
        _selectedFoodIndex =
            _foods.indexWhere((f) => f['value'] == data['food']);
      }
      // Period index
      if (data['life_period'] != null) {
        _selectedPeriodIndex =
            _periods.indexWhere((p) => p['value'] == data['life_period']);
      }
      // Nếu có 3D model thì gán _glbFileName, _glbFilePath nếu muốn (bổ sung sau)
    }
  }

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận reset'),
          content: Text('Bạn có chắc chắn muốn xóa tất cả thông tin đã nhập?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
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
                  _imagePath = null;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã reset form thành công')),
                );
              },
              child: Text('Xác nhận', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Hàm xử lý khi nút LƯU THAY ĐỔI được bấm
  void _saveChanges() async {
    // Kiểm tra các trường bắt buộc
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên động vật (Tiếng Việt)')),
      );
      return;
    }

    if (_nameEnController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên động vật (Tiếng Anh)')),
      );
      return;
    }

    if (_selectedHabitatIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn môi trường sống')),
      );
      return;
    }

    if (_selectedFoodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn thức ăn')),
      );
      return;
    }

    if (_selectedPeriodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn thời kỳ sống')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập mô tả cho động vật')),
      );
      return;
    }

    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      },
    );

    try {
      // 1. Upload ảnh nếu có
      String imageUrl = '';
      if (_imagePath != null) {
        try {
          final file = File(_imagePath!);
          if (!await file.exists()) {
            throw Exception('File không tồn tại');
          }

          // Kiểm tra kích thước file (giới hạn 10MB)
          final fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            throw Exception('Kích thước file quá lớn (tối đa 10MB)');
          }

          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_imagePath!)}';
          final ref =
              FirebaseStorage.instance.ref().child('animal_images/$fileName');

          // Tạo metadata cho file ảnh
          final metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedBy': 'admin',
              'uploadTime': DateTime.now().toIso8601String(),
            },
            cacheControl: 'public,max-age=31536000', // Cache for 1 year
          );

          // Upload file với metadata
          final uploadTask = await ref.putFile(file, metadata);
          imageUrl = await uploadTask.ref.getDownloadURL();
          print('Image uploaded successfully. URL: $imageUrl'); // Debug log
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi upload ảnh: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop(); // Đóng dialog loading
          return;
        }
      }

      // 2. Tạo map phân loại khoa học
      final plkh = {
        'gioi': _kingdomController.text,
        'nganh': _phylumController.text,
        'lop': _classController.text,
        'bo': _orderController.text,
      };

      // 3. Lưu lên Firestore
      await saveAnimalToFirestore(
        name: _nameController.text,
        nameEn: _nameEnController.text,
        plkh: plkh,
        imageUrl: imageUrl,
      );

      // Đóng dialog loading
      Navigator.of(context).pop();

      // Hiển thị dialog thành công
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thành công'),
            content: Text('Đã thêm động vật thành công!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Quay lại màn hình trước
                },
                child: Text('Quay lại'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetForm(); // Reset form và ở lại màn hình
                },
                child: Text('Thêm mới', style: TextStyle(color: Colors.orange)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Đóng dialog loading
      Navigator.of(context).pop();

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm để chọn file GLB
  Future<void> _pickGLBFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        final fileName = result.files.single.name;
        if (!fileName.toLowerCase().endsWith('.glb')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chỉ chấp nhận file .glb!')),
          );
          return;
        }
        setState(() {
          _glbFileName = fileName;
          _glbFilePath = result.files.single.path;
        });
        print('Selected GLB file path: $_glbFilePath'); // Debug log
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn file: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Giới hạn kích thước ảnh
        maxHeight: 1080,
        imageQuality: 85, // Chất lượng ảnh
      );

      if (picked != null) {
        // Kiểm tra file có tồn tại không
        final file = File(picked.path);
        if (!await file.exists()) {
          throw Exception('File không tồn tại');
        }

        // Kiểm tra kích thước file (giới hạn 10MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          throw Exception('Kích thước file quá lớn (tối đa 10MB)');
        }

        setState(() {
          _imagePath = picked.path;
        });
      }
    } on PlatformException catch (e) {
      print('Image picker error: $e');
      String errorMessage = 'Lỗi khi chọn ảnh';

      if (e.code == 'photo_access_denied') {
        errorMessage = 'Không có quyền truy cập thư viện ảnh';
      } else if (e.code == 'camera_access_denied') {
        errorMessage = 'Không có quyền truy cập camera';
      } else if (e.code == 'invalid_image') {
        errorMessage = 'File không phải là ảnh hợp lệ';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi không xác định: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showFullImage(BuildContext context) {
    if (_imagePath == null) return;

    try {
      // Kiểm tra nếu là URL
      if (_imagePath!.startsWith('http')) {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                child: Image.network(
                  _imagePath!,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading network image: $error');
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'Không thể tải ảnh',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      } else {
        // Nếu là file local
        final file = File(_imagePath!);
        if (!file.existsSync()) {
          throw Exception('File không tồn tại');
        }

        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                child: Image.file(
                  file,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading local image: $error');
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'Không thể tải ảnh',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error showing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi hiển thị ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> uploadAnimalImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final ref = FirebaseStorage.instance.ref().child('animal_avt/$fileName');
      final uploadTask = await ref.putFile(File(filePath));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Kiểm tra URL hợp lệ
      if (downloadUrl.isEmpty || !downloadUrl.startsWith('http')) {
        throw Exception('Invalid download URL');
      }

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Hàm để lấy habitat_id từ tên môi trường sống
  Future<int> getHabitatId(String habitatName) async {
    try {
      print('Searching for habitat: $habitatName'); // Debug log

      // In ra toàn bộ dữ liệu từ collection habitats
      final allHabitats =
          await FirebaseFirestore.instance.collection('habitats').get();

      print('All habitats in database:');
      for (var doc in allHabitats.docs) {
        print('Document ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }

      // So sánh từng document với habitatName
      for (var doc in allHabitats.docs) {
        final dbName = doc.get('habitat_name').toString();
        print('So sánh: "' +
            dbName +
            '" == "' +
            habitatName +
            '" ? ' +
            (dbName == habitatName).toString());
        if (dbName == habitatName) {
          final habitatId = doc.get('habitat_id');
          print('Found habitat_id (so sánh trực tiếp): $habitatId');
          return habitatId is int ? habitatId : int.parse(habitatId.toString());
        }
        // So sánh không phân biệt hoa thường
        if (dbName.toLowerCase() == habitatName.toLowerCase()) {
          final habitatId = doc.get('habitat_id');
          print('Found habitat_id (case insensitive): $habitatId');
          return habitatId is int ? habitatId : int.parse(habitatId.toString());
        }
      }

      print('No habitat found for: $habitatName'); // Debug log
      return 0;
    } catch (e) {
      print('Error getting habitat_id: $e');
      return 0;
    }
  }

  Future<void> saveAnimalToFirestore({
    required String name,
    required String nameEn,
    required Map<String, String> plkh,
    required String imageUrl,
  }) async {
    try {
      // Kiểm tra xem document đã tồn tại chưa
      final docRef =
          FirebaseFirestore.instance.collection('animalDB').doc(name);
      final docSnapshot = await docRef.get();

      // Lấy tất cả documents để tìm AnimalID nhỏ nhất chưa được sử dụng
      QuerySnapshot allDocs =
          await FirebaseFirestore.instance.collection('animalDB').get();
      Set<int> usedIds = {};

      // Thu thập tất cả AnimalID đã được sử dụng
      for (var doc in allDocs.docs) {
        if (doc.data() is Map<String, dynamic>) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('AnimalID') && data['AnimalID'] is int) {
            usedIds.add(data['AnimalID'] as int);
          }
        }
      }

      // Tìm số nhỏ nhất chưa được sử dụng
      int newAnimalId = 1;
      while (usedIds.contains(newAnimalId)) {
        newAnimalId++;
      }

      // Lấy habitat_id từ tên môi trường sống đã chọn
      int habitatId = 0;
      if (_selectedHabitatIndex >= 0 &&
          _selectedHabitatIndex < _habitats.length) {
        String habitatName = _habitats[_selectedHabitatIndex]['name'];
        habitatId = await getHabitatId(habitatName);
      }

      // Lấy giá trị food và life_period
      String food = '';
      if (_selectedFoodIndex >= 0 && _selectedFoodIndex < _foods.length) {
        food = _foods[_selectedFoodIndex]['value'];
      }

      String lifePeriod = '';
      if (_selectedPeriodIndex >= 0 && _selectedPeriodIndex < _periods.length) {
        lifePeriod = _periods[_selectedPeriodIndex]['value'];
      }

      // Xử lý upload file 3D nếu có
      String model3dUrl = '';
      if (_glbFilePath != null && _glbFilePath!.isNotEmpty) {
        try {
          print('Starting GLB file upload...'); // Debug log
          final file = File(_glbFilePath!);
          if (!await file.exists()) {
            throw Exception(
                'GLB file không tồn tại tại đường dẫn: $_glbFilePath');
          }

          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_glbFilePath!)}';
          print('Uploading GLB file: $fileName'); // Debug log

          final ref =
              FirebaseStorage.instance.ref().child('model_3d/$fileName');

          // Tạo metadata cho file với đầy đủ thông tin
          final metadata = SettableMetadata(
            contentType: 'model/gltf-binary',
            customMetadata: {
              'uploadedBy': 'admin',
              'uploadTime': DateTime.now().toIso8601String(),
            },
            cacheControl: 'public,max-age=31536000', // Cache for 1 year
          );

          // Upload file với metadata
          final uploadTask = await ref.putFile(file, metadata);
          model3dUrl = await uploadTask.ref.getDownloadURL();
          print(
              'GLB file uploaded successfully. URL: $model3dUrl'); // Debug log
        } catch (e) {
          print('Error uploading GLB file: $e');
          // Không throw exception ở đây, để tiếp tục lưu thông tin khác
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi upload file 3D: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      // Tạo hoặc cập nhật document với AnimalID mới
      await docRef.set({
        'AnimalID': newAnimalId,
        'nameAnimal': name,
        'nameAnimalEnglish': nameEn,
        'plkh': plkh,
        'imageUrl': imageUrl,
        'required_vip': _isPremium,
        'habitat_id': habitatId,
        'food': food,
        'life_period': lifePeriod,
        'infoAnimal': _descriptionController.text,
        '3Dimage': model3dUrl,
        'favorcount': 0, // Thêm trường favorcount với giá trị mặc định là 0
      });

      print(
          'Document saved successfully with AnimalID: $newAnimalId'); // Debug log
    } catch (e) {
      print('Error in saveAnimalToFirestore: $e');
      rethrow;
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
                GestureDetector(
                  onTap: () {
                    if (_imagePath != null) _showFullImage(context);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                      image: _imagePath != null
                          ? DecorationImage(
                              image: _imagePath!.startsWith('http')
                                  ? NetworkImage(_imagePath!) as ImageProvider
                                  : FileImage(File(_imagePath!))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                print('Error loading image: $exception');
                              },
                            )
                          : null,
                    ),
                    child: _imagePath == null
                        ? Icon(Icons.image, size: 40, color: Colors.grey[600])
                        : null,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.cloud_upload),
                        label: Text('Chọn ảnh'),
                      ),
                      const SizedBox(width: 8.0),
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
            const SizedBox(height: 20.0),
            // --- Loại tài khoản ---
            const Text('LOẠI MÔ HÌNH',
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
