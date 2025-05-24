import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

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

  // List<Animal> _filteredAnimals = []; // Danh sách động vật sau khi lọc

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

          // Danh sách động vật (cuộn được và chiếm hết không gian còn lại)
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
      height: 50, // Chiều cao cố định cho thanh lọc
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Cho phép cuộn ngang
        child: Row(
          children: List.generate(_categories.length, (index) {
            final category = _categories[index];
            final isSelected = _selectedCategoryIndex ==
                index; // Kiểm tra xem đây có phải mục được chọn không
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              // Khoảng cách giữa các mục lọc
              child: GestureDetector(
                // Sử dụng GestureDetector để có thể bấm vào
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal, // Chữ đậm nếu được chọn
                        color: isSelected
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
                    onTap: () {
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
}
