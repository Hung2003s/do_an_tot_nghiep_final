import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../manage_animal/add_animal_item.dart';
import '../manage_animal/add_animal_screen.dart';
// Import widget CircularCategoryChip

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class AnimalInfoScreen extends StatefulWidget {
  final arguments;

  const AnimalInfoScreen({super.key, required this.arguments});

  @override
  State<AnimalInfoScreen> createState() => _AnimalInfoScreenState();
}

class _AnimalInfoScreenState extends State<AnimalInfoScreen> {
  final CollectionReference data = FirebaseFirestore.instance.collection(
    "animalDB",
  );
  int _selectedHabitatIndex = -1; // -1 nghĩa là chưa chọn
  int _selectedFoodIndex = -1;
  int _selectedPeriodIndex = -1;

  // Dữ liệu giả định cho các mục phân loại
  final List<Map<String, dynamic>> _habitats = [
    {'icon': Icons.forest, 'label': 'Rừng rậm'},
    {'icon': Icons.grass, 'label': 'Thảo nguyên'},
    {'icon': Icons.agriculture, 'label': 'Nông trại'},
    {'icon': Icons.cloud, 'label': 'Bầu trời'},
    {'icon': Icons.water_drop, 'label': 'Nước ngọt'},
    {'icon': Icons.waves, 'label': 'Nước mặn'},
    // Đã bổ sung đầy đủ các môi trường sống
  ];

  final List<Map<String, dynamic>> _foods = [
    {'icon': Icons.grass, 'label': 'Ăn cỏ'},
    {'icon': Icons.fastfood, 'label': 'Ăn thịt'},
    {'icon': Icons.restaurant, 'label': 'Ăn tạp'},
  ];

  final List<Map<String, dynamic>> _periods = [
    {'icon': Icons.history, 'label': 'Tiền sử'},
    {'icon': Icons.update, 'label': 'Hiện đại'},
  ];

  Widget buildPlkhRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final plkh = widget.arguments["plkh"] ?? {};
    final String gioi = plkh["gioi"] ?? "";
    final String bo = plkh["bo"] ?? "";
    final String lop = plkh["lop"] ?? "";
    final String nganh = plkh["nganh"] ?? "";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Hoặc GoRouter.of(context).pop();
          },
        ),
        title: const Text('Thông tin động vật'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddAnimalScreen(
                      animalData: getAnimalData(widget.arguments)),
                ),
              );
            },
            child: const Text(
              'SỬA',
              style: TextStyle(color: Colors.orange),
            ), // Màu cam cho nút SỬA
          ),
        ],
      ),
      body: StreamBuilder(
        stream: data.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {}
          if (snapshot.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                // Cho phép cuộn toàn bộ nội dung
                padding: const EdgeInsets.all(16.0),
                // Padding cho toàn bộ nội dung
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Khu vực hình ảnh lớn và labels ---
                    Stack(
                      clipBehavior: Clip.none,
                      // Cho phép các widget con hiển thị bên ngoài bounds
                      children: [
                        // Placeholder Hình ảnh lớn
                        Container(
                          width: double.infinity, // Chiếm hết chiều rộng
                          height: 200, // Chiều cao cố định
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              16.0,
                            ), // Bo tròn góc
                          ),
                          child: CachedNetworkImage(
                              imageUrl: widget.arguments["imageUrl"]),
                        ),
                        // Labels phủ lên ảnh
                        Positioned(
                          bottom: 8.0, // Cách đáy ảnh 8.0
                          left: 8.0, // Cách lề trái ảnh 8.0
                          right: 8.0, // Cách lề phải ảnh 8.0
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildOverlaidLabel(
                                (widget.arguments["required_vip"] == true)
                                    ? "Cao cấp"
                                    : "Miễn phí",
                                color:
                                    (widget.arguments["required_vip"] == true)
                                        ? Colors.amber
                                        : Colors.grey,
                              ),
                              _buildOverlaidLabel(
                                  widget.arguments["food"]), // Label thứ hai
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // --- Tên, Phụ đề, Giá, Rating ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // Chiếm hết không gian còn lại cho tên và phụ đề
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.arguments["nameAnimal"]}',
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${widget.arguments["nameAnimalEnglish"]}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Giá, ..., View
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Free',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                const Icon(
                                  Icons.more_horiz,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              // Rating
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${widget.arguments["favorcount"]}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Có thể thêm review count ở đây nếu cần
                                // if (animal.reviewCount != null)
                                //   Padding(
                                //     padding: const EdgeInsets.only(left: 4.0),
                                //     child: Text('(${animal.reviewCount} Review)', style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                                //   ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Favorite', // Text "View"
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    // --- Phân loại (các chips hình tròn) ---
                    const Text(
                      'PHÂN LOẠI',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Môi Trường Sống',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Xem Tất Cả',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 80,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_habitats.length, (index) {
                            final habitat = _habitats[index];
                            final animalHabitat =
                                widget.arguments["habitat_id"];
                            bool isActive = false;
                            if (animalHabitat is List) {
                              isActive = animalHabitat.contains(index + 1);
                            } else {
                              isActive = animalHabitat == (index + 1);
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: CircleCategory(
                                icon: habitat['icon'],
                                label: habitat['label'],
                                isSelected: isActive,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thức Ăn',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Xem Tất Cả',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 80,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_foods.length, (index) {
                            final food = _foods[index];
                            final animalFood = widget.arguments["food"];
                            bool isActive = animalFood == food['label'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: CircleCategory(
                                icon: food['icon'],
                                label: food['label'],
                                isSelected: isActive,
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

                    // --- Phân loại (Thời Kỳ) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thời Kỳ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Xem Tất Cả',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 80,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_periods.length, (index) {
                            final period = _periods[index];
                            final animalPeriod =
                                widget.arguments["life_period"];
                            bool isActive = animalPeriod == period['label'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: CircleCategory(
                                icon: period['icon'],
                                label: period['label'],
                                isSelected: isActive,
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

                    // --- Phân loại khoa học ---
                    Row(
                      children: [
                        Expanded(
                            child: SizedBox(
                                height: 120,
                                child: _buildPlkhCard(Icons.public, "Giới",
                                    gioi, Colors.blue[100]!))),
                        Expanded(
                            child: SizedBox(
                                height: 120,
                                child: _buildPlkhCard(Icons.account_tree,
                                    "Ngành", nganh, Colors.green[100]!))),
                        Expanded(
                            child: SizedBox(
                                height: 120,
                                child: _buildPlkhCard(Icons.class_, "Lớp", lop,
                                    Colors.purple[100]!))),
                        Expanded(
                            child: SizedBox(
                                height: 120,
                                child: _buildPlkhCard(Icons.bug_report, "Bộ",
                                    bo, Colors.orange[100]!))),
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // --- Mô tả ---
                    const Text(
                      'Mô tả',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.arguments["infoAnimal"] ?? '',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20.0),

                    // Khoảng cách trước Bottom Bar
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
      // Bottom Navigation Bar (Tái sử dụng)
      // bottomNavigationBar: _buildBottomNavigationBar(), // Cần implement hàm này
      // floatingActionButton: FloatingActionButton(...), // Cần implement nút này
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Cần implement vị trí này
    );
  }

  // Hàm build widget label phủ lên ảnh
  Widget _buildOverlaidLabel(String text, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12.0, color: Colors.white),
      ),
    );
  }

  Widget _buildPlkhCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.black54),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Hàm chuyển đổi arguments sang Map<String, dynamic>
  Map<String, dynamic> getAnimalData(dynamic arguments) {
    if (arguments is Map<String, dynamic>) return arguments;
    if (arguments is DocumentSnapshot)
      return arguments.data() as Map<String, dynamic>;
    if (arguments is QueryDocumentSnapshot)
      return arguments.data() as Map<String, dynamic>;
    return {};
  }
}
