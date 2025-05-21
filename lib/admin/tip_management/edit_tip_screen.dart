import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget để chỉnh sửa thông tin của một tip
class EditTipScreen extends StatefulWidget {
  final String TipId; // ID của tip cần chỉnh sửa
  final Map<String, dynamic> tipData; // Dữ liệu của tip

  const EditTipScreen({
    Key? key,
    required this.TipId,
    required this.tipData,
  }) : super(key: key);

  @override
  State<EditTipScreen> createState() => _EditTipScreenState();
}

class _EditTipScreenState extends State<EditTipScreen> {
  // Key để quản lý form
  final _formKey = GlobalKey<FormState>();

  // Các controller để quản lý dữ liệu nhập vào
  late final TextEditingController _contentController; // Quản lý nội dung tip
  late final TextEditingController _imageUrlController; // Quản lý URL hình ảnh
  late final TextEditingController _tipIdController; // Quản lý ID của tip
  late final TextEditingController
      _animalIdController; // Quản lý ID của động vật
  late final TextEditingController _animalNameController =
      TextEditingController(); // Quản lý tên động vật

  // Các biến trạng thái
  bool _isLoading = false; // Trạng thái đang tải
  bool _isEditing = false; // Trạng thái đang chỉnh sửa
  List<Map<String, dynamic>> _animalsList =
      []; // Danh sách động vật từ database
  int? _selectedAnimalId; // ID động vật được chọn
  String? _selectedAnimalName; // Tên động vật được chọn

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với dữ liệu từ tip hiện tại
    _contentController = TextEditingController(text: widget.tipData['tip']);
    _imageUrlController =
        TextEditingController(text: widget.tipData['imageUrl']);
    _tipIdController = TextEditingController(text: widget.tipData['TipID']);
    _animalIdController =
        TextEditingController(text: widget.tipData['AnimalID'].toString());
    _selectedAnimalId = widget.tipData['AnimalID'] as int;
    _selectedAnimalName = widget.tipData['nameAnimal'] ?? '';
    _animalNameController.text = _selectedAnimalName ?? '';
    _loadAnimals().then((_) {
      // Sau khi tải danh sách động vật, tìm và set tên động vật tương ứng
      final selectedAnimal = _animalsList.firstWhere(
        (animal) => animal['AnimalID'] == _selectedAnimalId,
        orElse: () => {'nameAnimal': 'Không tìm thấy'},
      );
      setState(() {
        _selectedAnimalName = selectedAnimal['nameAnimal'];
        _animalNameController.text = _selectedAnimalName ?? '';
      });
      // Thêm log để kiểm tra tên động vật đã chọn
      print('DEBUG: _selectedAnimalId = $_selectedAnimalId');
      print('DEBUG: _selectedAnimalName = $_selectedAnimalName');
    });
  }

  // Hàm tải danh sách động vật từ database
  Future<void> _loadAnimals() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('animalDB').get();

      setState(() {
        _animalsList = snapshot.docs
            .map((doc) => {
                  'AnimalID': doc['AnimalID'] as int,
                  'nameAnimal': doc['nameAnimal'] ?? '',
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
      });
      // Thêm log để kiểm tra danh sách động vật
      print('DEBUG: _animalsList = \n');
      for (var animal in _animalsList) {
        print(
            'AnimalID: ${animal['AnimalID']}, nameAnimal: ${animal['nameAnimal']}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi tải danh sách động vật: ${e.toString()}')),
        );
      }
    }
  }

  // Hàm giải phóng bộ nhớ khi widget bị hủy
  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    _tipIdController.dispose();
    _animalIdController.dispose();
    _animalNameController.dispose();
    super.dispose();
  }

  // Hàm cập nhật thông tin tip vào database
  Future<void> _updateTip() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Cập nhật dữ liệu vào Firestore
        await FirebaseFirestore.instance
            .collection('tipsDB')
            .doc(widget.TipId)
            .update({
          // 'tên động vật': _selectedAnimalName,
          'tip': _contentController.text,
          'imageUrl': _imageUrlController.text,
          'TipID': widget.tipData['TipID'],
          'AnimalID': _selectedAnimalId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tip đã được cập nhật thành công')),
          );
          setState(() {
            _isEditing = false;
          });
          // Quay lại màn hình trước đó sau khi cập nhật thành công
          Navigator.pop(context, true); // Trả về true để báo hiệu đã cập nhật
        }
      } catch (e) {
        if (mounted) {
          // Hiển thị thông báo lỗi chi tiết hơn
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật tip: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề và nút chỉnh sửa
      appBar: AppBar(
        title: const Text('Chi tiết Tip'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      // Form chứa các trường thông tin
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown chọn động vật (chỉ hiện khi đang chỉnh sửa)
              if (_isEditing)
                DropdownButtonFormField<int>(
                  value: _selectedAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Tên động vật',
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _animalsList.map((animal) {
                    return DropdownMenuItem<int>(
                      value: animal['AnimalID'],
                      child: Text(animal['nameAnimal'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedAnimalId = newValue;
                        final selectedAnimal = _animalsList.firstWhere(
                          (animal) => animal['AnimalID'] == newValue,
                          orElse: () => {'nameAnimal': ''},
                        );
                        _selectedAnimalName = selectedAnimal['nameAnimal'];
                        _animalIdController.text = newValue.toString();
                        _animalNameController.text = _selectedAnimalName ?? '';
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn động vật';
                    }
                    return null;
                  },
                )
              else
                // Hiển thị tên động vật (khi không chỉnh sửa)
                TextFormField(
                  controller: _animalNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên động vật',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              const SizedBox(height: 16),
              // Trường hiển thị TipID (chỉ đọc)
              TextFormField(
                controller: _tipIdController,
                decoration: const InputDecoration(
                  labelText: 'TipID',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey,
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 16),
              // Trường hiển thị AnimalID (chỉ đọc)
              TextFormField(
                controller: _animalIdController,
                decoration: const InputDecoration(
                  labelText: 'AnimalID',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey,
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 16),
              // Trường nhập nội dung tip
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                readOnly: !_isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Trường nhập URL hình ảnh
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL hình ảnh',
                  border: OutlineInputBorder(),
                ),
                readOnly: !_isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập URL hình ảnh';
                  }
                  return null;
                },
              ),
              // Các nút điều khiển khi đang chỉnh sửa
              if (_isEditing) ...[
                const SizedBox(height: 24),
                // Nút lưu thay đổi
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateTip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Lưu thay đổi'),
                ),
                const SizedBox(height: 16),
                // Nút hủy thay đổi
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Khôi phục lại giá trị ban đầu
                      _contentController.text = widget.tipData['tip'];
                      _imageUrlController.text = widget.tipData['imageUrl'];
                      _tipIdController.text = widget.tipData['TipID'];
                      _animalIdController.text =
                          widget.tipData['AnimalID'].toString();
                      _selectedAnimalId = widget.tipData['AnimalID'] as int;
                      // Lấy lại tên động vật từ tipData hoặc từ _animalsList nếu bị null/rỗng
                      _selectedAnimalName = widget.tipData['nameAnimal'];
                      if (_selectedAnimalName == null ||
                          _selectedAnimalName!.isEmpty) {
                        final animal = _animalsList.firstWhere(
                          (animal) => animal['AnimalID'] == _selectedAnimalId,
                          orElse: () => {'nameAnimal': ''},
                        );
                        _selectedAnimalName = animal['nameAnimal'];
                      }
                      _animalNameController.text = _selectedAnimalName ?? '';
                    });
                    // Hiển thị thông báo đã hủy thay đổi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã hủy thay đổi'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
