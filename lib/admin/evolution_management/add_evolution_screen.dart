import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _addEvolutionNews() async {
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

        if (_imageUrlController.text.trim().isEmpty) {
          throw Exception('URL hình ảnh không được để trống');
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
          'imageUrl': _imageUrlController.text,
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
              ElevatedButton(
                onPressed: _isLoading ? null : _addEvolutionNews,
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
