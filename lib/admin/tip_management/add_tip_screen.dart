import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTipScreen extends StatefulWidget {
  const AddTipScreen({Key? key}) : super(key: key);

  @override
  State<AddTipScreen> createState() => _AddTipScreenState();
}

class _AddTipScreenState extends State<AddTipScreen> {
  // Key để quản lý form
  final _formKey = GlobalKey<FormState>();

  // Các controller để quản lý dữ liệu nhập vào
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tipIdController = TextEditingController();
  final _animalIdController = TextEditingController();

  // Các biến trạng thái
  bool _isLoading = false;
  List<Map<String, dynamic>> _animalsList = [];
  int? _selectedAnimalId;
  String? _selectedAnimalName;

  @override
  void initState() {
    super.initState();
    _loadAnimals(); // Tải danh sách động vật
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi tải danh sách động vật: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    _tipIdController.dispose();
    _animalIdController.dispose();
    super.dispose();
  }

  // Hàm thêm tip mới vào database
  Future<void> _addTip() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('Bắt đầu thêm tip mới...');

        // Kiểm tra dữ liệu trước khi thêm
        if (_selectedAnimalId == null || _selectedAnimalName == null) {
          print('Lỗi: Chưa chọn động vật');
          throw Exception('Vui lòng chọn động vật');
        }

        if (_contentController.text.trim().isEmpty) {
          print('Lỗi: Nội dung trống');
          throw Exception('Nội dung không được để trống');
        }

        if (_imageUrlController.text.trim().isEmpty) {
          print('Lỗi: URL hình ảnh trống');
          throw Exception('URL hình ảnh không được để trống');
        }

        print('Dữ liệu tip:');
        print('Tên động vật: $_selectedAnimalName');
        print('AnimalID: $_selectedAnimalId');
        print('Nội dung: ${_contentController.text}');
        print('URL hình ảnh: ${_imageUrlController.text}');

        // Lấy số lượng document hiện tại
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('tipsDB').get();
        int nextTipNumber = snapshot.docs.length + 1;
        String newTipId = 'Tip${nextTipNumber.toString().padLeft(2, '0')}';

        print('Đang tạo document mới trong Firebase...');
        await FirebaseFirestore.instance
            .collection('tipsDB')
            .doc(newTipId)
            .set({
          //'tên động vật': _selectedAnimalName,
          'tip': _contentController.text.trim(),
          'imageUrl': _imageUrlController.text.trim(),
          'AnimalID': _selectedAnimalId,
          'TipID': newTipId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Đã tạo document với ID: $newTipId');

        // Kiểm tra xem document đã được tạo thành công chưa
        print('Đang kiểm tra document...');
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('tipsDB')
            .doc(newTipId)
            .get();
        if (!docSnapshot.exists) {
          print('Lỗi: Document không tồn tại sau khi tạo');
          throw Exception('Không thể tạo tip mới');
        }
        print('Document đã được tạo thành công');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tip đã được thêm thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Lỗi khi thêm tip: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
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
      appBar: AppBar(
        title: const Text('Thêm Tip Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown chọn động vật
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
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn động vật';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập URL hình ảnh';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Nút thêm tip
              ElevatedButton(
                onPressed: _isLoading ? null : _addTip,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Thêm Tip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
