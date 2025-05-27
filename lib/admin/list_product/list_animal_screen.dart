import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../user/const/ar_list_color.dart';
import '../../user/pages/detail_animal_screen.dart';
import 'animal_info_screen.dart';

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({Key? key}) : super(key: key);

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final CollectionReference data =
      FirebaseFirestore.instance.collection("animalDB");

  // Danh sách các danh mục lọc
  final List<String> _categories = [
    'All',
    'Ăn cỏ',
    'Ăn thịt',
    'Trên cạn',
    'Dưới nước',
    'Khủng long'
  ];
  int _selectedCategoryIndex = 0;
  late String type = "All";

  // Thêm biến cho chế độ chọn nhiều
  final Set<String> _selectedAnimals = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    // _filterAnimals(_selectedCategoryIndex); // Lọc danh sách ban đầu khi màn hình khởi tạo
  }

  // Hàm lọc danh sách động vật theo danh mục
  void _filterAnimals(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    switch (_selectedCategoryIndex) {
      case 0:
        type = "All";
        break;
      case 1:
        type = "Ăn cỏ";
        break;
      case 2:
        type = "Ăn thịt";
        break;
      case 3:
        type = "trencan";
        break;
      case 4:
        type = "duoinuoc";
        break;
      case 5:
        type = "tienSu";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? 'Đã chọn ${_selectedAnimals.length}'
            : 'Danh sách động vật'),
        centerTitle: true,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed:
                  _selectedAnimals.isEmpty ? null : _showDeleteConfirmation,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedAnimals.clear();
                });
              },
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
              child: const Text('Chọn',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
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
            child: StreamBuilder(
                stream: data.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  int totalCount = 0;
                  for (var doc in snapshot.data!.docs) {
                    String foodValue = doc["food"] ?? '';
                    dynamic habitatId = doc["habitat_id"];
                    String lifePeriod = doc["life_period"] ?? '';

                    bool isPrehistoricAnimal = lifePeriod == "Tiền sử";
                    bool isLandAnimal = habitatId >= 1 && habitatId <= 4;
                    bool isWaterAnimal = habitatId == 5 || habitatId == 6;

                    bool shouldCount = _selectedCategoryIndex == 0
                        ? true
                        : _selectedCategoryIndex == 1
                            ? foodValue == "Ăn cỏ"
                            : _selectedCategoryIndex == 2
                                ? foodValue == "Ăn thịt"
                                : _selectedCategoryIndex == 3
                                    ? isLandAnimal && !isPrehistoricAnimal
                                    : _selectedCategoryIndex == 4
                                        ? isWaterAnimal && !isPrehistoricAnimal
                                        : _selectedCategoryIndex == 5
                                            ? isPrehistoricAnimal
                                            : false;

                    if (shouldCount) totalCount++;
                  }

                  return Text(
                    'Tổng cộng: $totalCount',
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  );
                }),
          ),

          // Danh sách động vật
          _buildListAnimal(context, _selectedCategoryIndex)
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
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_categories.length, (index) {
            final category = _categories[index];
            final isSelected = _selectedCategoryIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  _filterAnimals(index);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.orange : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    if (isSelected)
                      Container(
                        height: 2.0,
                        width: 30.0,
                        color: Colors.orange,
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

  Widget _buildListAnimal(
    BuildContext context,
    int index,
  ) {
    return StreamBuilder(
      stream: data.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {}
        if (snapshot.hasData) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot records = snapshot.data!.docs[index];
                  String foodValue = records["food"] ?? '';
                  dynamic habitatId = records["habitat_id"];
                  String lifePeriod = records["life_period"] ?? '';
                  final animalName = records['nameAnimal'] as String;
                  final isSelected = _selectedAnimals.contains(animalName);

                  bool isLandAnimal = habitatId >= 1 && habitatId <= 4;
                  bool isWaterAnimal = habitatId == 5 || habitatId == 6;
                  bool isFarmAnimal = habitatId == 7;
                  bool isSkyAnimal = habitatId == 8;
                  bool isPrehistoricAnimal = lifePeriod == "Tiền sử";

                  bool shouldShow = _selectedCategoryIndex == 0
                      ? true
                      : _selectedCategoryIndex == 1
                          ? foodValue == "Ăn cỏ"
                          : _selectedCategoryIndex == 2
                              ? foodValue == "Ăn thịt"
                              : _selectedCategoryIndex == 3
                                  ? (isLandAnimal ||
                                          isFarmAnimal ||
                                          isSkyAnimal) &&
                                      !isPrehistoricAnimal
                                  : _selectedCategoryIndex == 4
                                      ? isWaterAnimal && !isPrehistoricAnimal
                                      : _selectedCategoryIndex == 5
                                          ? isPrehistoricAnimal
                                          : false;

                  if (!shouldShow) return Container();

                  return GestureDetector(
                    onTap: _isSelectionMode
                        ? () {
                            setState(() {
                              if (isSelected) {
                                _selectedAnimals.remove(animalName);
                              } else {
                                _selectedAnimals.add(animalName);
                              }
                            });
                          }
                        : () {
                            Get.to(
                                () => AnimalInfoScreen(
                                      arguments: records,
                                    ),
                                curve: Curves.linear,
                                transition: Transition.rightToLeft);
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey[300]!, width: 1.0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isSelectionMode)
                            Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedAnimals.add(animalName);
                                  } else {
                                    _selectedAnimals.remove(animalName);
                                  }
                                });
                              },
                            ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: records["imageUrl"],
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  records['nameAnimal'],
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    records['AnimalID'].toString(),
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.orange[700]),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    const Icon(Icons.favorite,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '${records["favorcount"]}',
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Miễn phí',
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4.0),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              const Text(
                                'Có sẵn',
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  // Thêm hàm xóa động vật
  Future<void> _deleteAnimals(List<String> animalNames) async {
    try {
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

      // Xóa từng động vật
      for (final animalName in animalNames) {
        // Lấy thông tin động vật
        final docSnapshot = await FirebaseFirestore.instance
            .collection('animalDB')
            .doc(animalName)
            .get();

        if (docSnapshot.exists) {
          final animalData = docSnapshot.data() as Map<String, dynamic>;

          // Xóa ảnh từ Storage nếu có
          if (animalData['imageUrl'] != null) {
            try {
              final ref =
                  FirebaseStorage.instance.refFromURL(animalData['imageUrl']);
              await ref.delete();
            } catch (e) {
              print('Error deleting image for $animalName: $e');
            }
          }

          // Xóa file 3D từ Storage nếu có
          if (animalData['3Dimage'] != null) {
            try {
              final ref =
                  FirebaseStorage.instance.refFromURL(animalData['3Dimage']);
              await ref.delete();
            } catch (e) {
              print('Error deleting 3D model for $animalName: $e');
            }
          }

          // Xóa document từ Firestore
          await FirebaseFirestore.instance
              .collection('animalDB')
              .doc(animalName)
              .delete();
        }
      }

      // Đóng dialog loading
      Navigator.of(context).pop();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${animalNames.length} động vật thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Tắt chế độ chọn nếu đang bật
      if (_isSelectionMode) {
        setState(() {
          _isSelectionMode = false;
          _selectedAnimals.clear();
        });
      }
    } catch (e) {
      // Đóng dialog loading
      Navigator.of(context).pop();

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa động vật: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Thêm hàm hiển thị dialog xác nhận xóa
  void _showDeleteConfirmation([List<String>? animalNames]) {
    final namesToDelete = animalNames ?? _selectedAnimals.toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text(
            namesToDelete.length == 1
                ? 'Bạn có chắc chắn muốn xóa động vật này?'
                : 'Bạn có chắc chắn muốn xóa ${namesToDelete.length} động vật đã chọn?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAnimals(namesToDelete);
              },
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
