import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEvolutionScreen extends StatefulWidget {
  const AddEvolutionScreen({Key? key}) : super(key: key);

  @override
  State<AddEvolutionScreen> createState() => _AddEvolutionScreenState();
}

class _AddEvolutionScreenState extends State<AddEvolutionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _newsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _newsIdController = TextEditingController();
  final _animalIdController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _animalsList = [];
  int? _selectedAnimalId;
  String? _selectedAnimalName;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

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
    _newsController.dispose();
    _imageUrlController.dispose();
    _newsIdController.dispose();
    _animalIdController.dispose();
    super.dispose();
  }

  Future<void> _addEvolution() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_selectedAnimalId == null || _selectedAnimalName == null) {
          throw Exception('Vui lòng chọn động vật');
        }

        if (_newsController.text.trim().isEmpty) {
          throw Exception('Nội dung không được để trống');
        }

        // Kiểm tra xem đã chọn ảnh chưa
        if (_imageFile == null && _imageUrlController.text.isEmpty) {
          throw Exception('Vui lòng chọn ảnh');
        }

        String imageUrl = _imageUrlController.text;

        // Nếu có ảnh mới được chọn, upload lên Firebase Storage
        if (_imageFile != null) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
          final ref = FirebaseStorage.instance
              .ref()
              .child('evolution_images/$fileName');

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
          final uploadTask = await ref.putFile(_imageFile!, metadata);
          imageUrl = await uploadTask.ref.getDownloadURL();
        }

        // Lấy số lượng document hiện tại
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('evolutionNews').get();
        int nextNewsNumber = snapshot.docs.length + 1;
        String newNewsId = 'News${nextNewsNumber.toString().padLeft(2, '0')}';

        // Thêm dữ liệu vào Firestore
        await FirebaseFirestore.instance.collection('evolutionNews').add({
          'animal_id': _selectedAnimalId.toString(),
          'news_id': newNewsId,
          'news': _newsController.text,
          'image': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm thông tin tiến hóa thành công')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
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

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isLoading = true;
        });

        // Upload image to Firebase Storage
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        final ref =
            FirebaseStorage.instance.ref().child('evolution_images/$fileName');

        // Create metadata for the image
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': 'admin',
            'uploadTime': DateTime.now().toIso8601String(),
          },
          cacheControl: 'public,max-age=31536000', // Cache for 1 year
        );

        // Upload the file with metadata
        final uploadTask = await ref.putFile(_imageFile!, metadata);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Update the image URL in the controller
        setState(() {
          _imageUrlController.text = downloadUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh đã được tải lên thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải ảnh lên: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showFullImage(BuildContext context) {
    if (_imageFile != null) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: Image.file(
                _imageFile!,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
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
    } else if (_imageUrlController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: Image.network(
                _imageUrlController.text,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading network image: $error');
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thông tin tiến hóa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              TextFormField(
                controller: _newsController,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hình ảnh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showFullImage(context),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : (_imageUrlController.text.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            _imageUrlController.text),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          print(
                                              'Error loading image: $exception');
                                        },
                                      )
                                    : null),
                          ),
                          child: (_imageFile == null &&
                                  _imageUrlController.text.isEmpty)
                              ? Icon(Icons.image,
                                  size: 40, color: Colors.grey[600])
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickImage,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Chọn ảnh'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _addEvolution,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Thêm thông tin tiến hóa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
