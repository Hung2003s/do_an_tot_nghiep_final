import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEvolutionScreen extends StatefulWidget {
  final String newsId;
  final Map<String, dynamic> newsData;

  const EditEvolutionScreen({
    Key? key,
    required this.newsId,
    required this.newsData,
  }) : super(key: key);

  @override
  State<EditEvolutionScreen> createState() => _EditEvolutionScreenState();
}

class _EditEvolutionScreenState extends State<EditEvolutionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _newsController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _newsIdController;
  late final TextEditingController _animalIdController;
  late final TextEditingController _animalNameController =
      TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  List<Map<String, dynamic>> _animalsList = [];
  int? _selectedAnimalId;
  String? _selectedAnimalName;

  @override
  void initState() {
    super.initState();
    _newsController = TextEditingController(text: widget.newsData['news']);
    _imageUrlController =
        TextEditingController(text: widget.newsData['imageUrl']);
    _newsIdController = TextEditingController(
        text: widget.newsData['news_id']?.toString() ?? '');
    _animalIdController = TextEditingController(
        text: widget.newsData['animal_id']?.toString() ?? '');
    _selectedAnimalId = widget.newsData['animal_id'] is int
        ? widget.newsData['animal_id']
        : int.tryParse(widget.newsData['animal_id']?.toString() ?? '');
    _selectedAnimalName = widget.newsData['nameAnimal'] ?? '';
    _animalNameController.text = _selectedAnimalName ?? '';
    _loadAnimals().then((_) {
      final selectedAnimal = _animalsList.firstWhere(
        (animal) => animal['AnimalID'] == _selectedAnimalId,
        orElse: () => {'nameAnimal': 'Không tìm thấy'},
      );
      setState(() {
        _selectedAnimalName = selectedAnimal['nameAnimal'];
        _animalNameController.text = _selectedAnimalName ?? '';
      });
    });
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
    _animalNameController.dispose();
    super.dispose();
  }

  Future<void> _updateEvolutionNews() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('evolutionNews')
            .doc(widget.newsId)
            .update({
          'news': _newsController.text,
          'imageUrl': _imageUrlController.text,
          'news_id': int.tryParse(_newsIdController.text) ?? 0,
          'animal_id':
              int.tryParse(_animalIdController.text) ?? _selectedAnimalId ?? 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cập nhật thông tin tiến hóa thành công')),
          );
          setState(() {
            _isEditing = false;
          });
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật: ${e.toString()}'),
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
        title: const Text('Chi tiết thông tin tiến hóa'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                TextFormField(
                  controller: _animalNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên động vật',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newsIdController,
                decoration: const InputDecoration(
                  labelText: 'NewsID',
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
                readOnly: !_isEditing,
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
                readOnly: !_isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập URL hình ảnh';
                  }
                  return null;
                },
              ),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateEvolutionNews,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Lưu thay đổi'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _newsController.text = widget.newsData['news'];
                      _imageUrlController.text = widget.newsData['imageUrl'];
                      _newsIdController.text =
                          widget.newsData['news_id']?.toString() ?? '';
                      _animalIdController.text =
                          widget.newsData['animal_id']?.toString() ?? '';
                      _selectedAnimalId = widget.newsData['animal_id'] is int
                          ? widget.newsData['animal_id']
                          : int.tryParse(
                              widget.newsData['animal_id']?.toString() ?? '');
                      _selectedAnimalName = widget.newsData['nameAnimal'];
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
                  },
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
