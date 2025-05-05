

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'animal_info_screen.dart';

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({Key? key}) : super(key: key);

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final CollectionReference data = FirebaseFirestore.instance.collection("animalDB");

  // Danh sách các danh mục lọc
  final List<String> _categories = ['All', 'An co', 'An thit', 'Khung Long'];
  int _selectedCategoryIndex = 0; // Chỉ mục danh mục đang được chọn
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
      _selectedCategoryIndex = index; // Cập nhật chỉ mục danh mục được chọn
    });
    switch (_selectedCategoryIndex) {
      case 0 :
        type = "All";
        break;
      case 1 :
        type = "anco";
        break;
      case 2 :
        type = "anthit";
        break;
      case 3 :
        type = "trencan";
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
            child: Text(
              'Tổng cộng: 20', // Hiển thị tổng số sau khi lọc
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
          ),

          // Danh sách động vật (cuộn được và chiếm hết không gian còn lại)
          _buildListAnimal(context,  _selectedCategoryIndex)
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
            final isSelected =
                _selectedCategoryIndex == index; // Kiểm tra xem đây có phải mục được chọn không
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
                        fontWeight:
                            isSelected
                                ? FontWeight.bold
                                : FontWeight.normal, // Chữ đậm nếu được chọn
                        color:
                            isSelected
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
  Widget _buildListAnimal(BuildContext context, int index) {
    return StreamBuilder(
      stream: data.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {}
        if (snapshot.hasData) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AnimalInfoScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // Padding ngang cho ListView
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot records = snapshot.data!.docs[index];
                    String idname = records["idName"];
                    return (_selectedCategoryIndex == 0) ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding dọc cho mỗi item
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0), // Đường phân cách mỏng
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Placeholder Ảnh/Biểu tượng
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12.0), // Bo tròn góc
                            ),
                            child: Image.asset(records["imageUrl"], fit: BoxFit.cover,),
                          ),
                          const SizedBox(width: 16.0), // Khoảng cách

                          // Phần Nội dung (Tên, Loại, Rating)
                          Expanded( // Chiếm hết không gian còn lại trừ phần bên phải cố định
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  records['nameAnimal'],
                                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0),
                                Container( // Container cho label loại
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100], // Màu nền nhạt cam
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    records['idName'],
                                    style: TextStyle(fontSize: 12.0, color: Colors.orange[700]), // Màu chữ cam
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row( // Rating
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '${records["favorcount"]}', // Định dạng rating 1 chữ số thập phân
                                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Phần bên phải (Giá, ...)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // Căn chỉnh sang phải
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Miễn phí', // Định dạng giá
                                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4.0),
                                  // Icon ba chấm
                                ],
                              ),
                              const SizedBox(height: 8.0), // Khoảng cách
                              const Text(
                                'Có sẵn', // Text "Pick UP"
                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ) : (idname == type) ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding dọc cho mỗi item
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0), // Đường phân cách mỏng
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Placeholder Ảnh/Biểu tượng
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12.0), // Bo tròn góc
                            ),
                            child: Image.asset(records["imageUrl"], fit: BoxFit.cover,),
                          ),
                          const SizedBox(width: 16.0), // Khoảng cách

                          // Phần Nội dung (Tên, Loại, Rating)
                          Expanded( // Chiếm hết không gian còn lại trừ phần bên phải cố định
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  records['nameAnimal'],
                                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0),
                                Container( // Container cho label loại
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100], // Màu nền nhạt cam
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    records['idName'],
                                    style: TextStyle(fontSize: 12.0, color: Colors.orange[700]), // Màu chữ cam
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row( // Rating
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '${records["favorcount"]}', // Định dạng rating 1 chữ số thập phân
                                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Phần bên phải (Giá, ...)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // Căn chỉnh sang phải
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Miễn phí', // Định dạng giá
                                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4.0),
                                ],
                              ),
                              const SizedBox(height: 8.0), // Khoảng cách
                              const Text(
                                'có sẵn', // Text "Pick UP"
                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ) : Container(); // Sử dụng widget item
                  },
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

}
