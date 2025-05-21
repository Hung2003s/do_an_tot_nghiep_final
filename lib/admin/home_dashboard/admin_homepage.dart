import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../list_product/animal_info_screen.dart';
import '../list_product/list_animal_screen.dart';

class ChartData {
  ChartData(this.x, this.y);

  final dynamic x; // Có thể là DateTime hoặc String tùy thuộc vào trục X
  final double y;
}

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  final CollectionReference data = FirebaseFirestore.instance.collection(
    "animalDB",
  );

  late Future<AggregateQuerySnapshot> _totalLikesFuture;
  //hàm truy vấn tổng hợp

  VoidCallback? onDelete; // Callback khi nút Xóa được bấm
  VoidCallback? onCancelOrDone; // Callback khi nút Hủy/Done được bấm
  final bool isDoneState = false;

  // Dữ liệu giả định cho biểu đồ (cần thay thế bằng dữ liệu từ API)
  final List<ChartData> _chartData = [
    ChartData('10AM', 10),
    ChartData('11AM', 12),
    ChartData('12PM', 15),
    ChartData('01PM', 13),
    ChartData('02PM', 14),
    ChartData('03PM', 11),
    ChartData('04PM', 16),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _totalLikesFuture = _fetchTotalLikes();
  }

  void _showMyModalBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      elevation: 2,
      builder: (BuildContext context) {
        return Container(
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: StreamBuilder(
            stream: data.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {}
              if (snapshot.hasData) {
                return Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot records =
                                snapshot.data!.docs[index];
                            return _buildBottomSheetItem(
                              records["idName"],
                              records["nameAnimal"],
                              records["imageUrl"],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        );
      },
    );
  }

  Future<AggregateQuerySnapshot> _fetchTotalLikes() async {
    return await FirebaseFirestore.instance
        .collection('animalDB')
        .aggregate(sum('favorcount'))
        .get();
  }

  Future<AggregateQuerySnapshot> _fetchdModelCount() async {
    return await FirebaseFirestore.instance
        .collection('animalDB')
        .count()
        .get();
  }

  void printcount() async {
    final snapshot = await _fetchdModelCount();
    print('Số lượng documents: ${snapshot.count}');
  }

  // Thêm hàm lấy tổng số user từ Firestore
  Future<int> _fetchUserCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('user').count().get();
    return snapshot.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Section
                    _buildStatisticsSection(),
                    SizedBox(height: 20),

                    // Graph Section
                    _buildGraphSection(),
                    SizedBox(height: 20),

                    // Favorites Section
                    _buildFavoritesSection(),
                    SizedBox(height: 20),

                    // _buildCommentSection(),
                    // SizedBox(height: 20),

                    // Popular Models Section
                    _buildPopularModelsSection(context, "trencan"),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white, // Màu nền Header
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.menu, color: Colors.grey[700]),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'XIN CHÀO',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Text(
                        'Lê Minh Hùng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Placeholder Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300], // Màu placeholder
            // backgroundImage: AssetImage('assets/images/avatar.png'), // Thay bằng ảnh thật
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showMyModalBottomSheet,
            //     () {
            //   setState(() {
            //     // _showBottomSheet = true;
            //   });
            // },
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<AggregateQuerySnapshot>(
                  future: _fetchdModelCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Đang trong quá trình fetch dữ liệu
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Có lỗi xảy ra trong quá trình fetch
                      return Text('Lỗi: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      // Dữ liệu đã fetch thành công
                      // Lấy giá trị tổng lượt thích từ kết quả truy vấn tổng hợp
                      // Sử dụng .getSum('likes') với tên trường đã dùng trong sum()
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${snapshot.data?.count}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'MÔ HÌNH HIỆN CÓ',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      );
                    } else {
                      return const Text('Không có dữ liệu tổng lượt thích');
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<int>(
                future: _fetchUserCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Lỗi: \\${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${snapshot.data}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'NGƯỜI DÙNG ĐĂNG KÝ',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Không có dữ liệu');
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraphSection() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số lượt xem',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      '2,241',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Placeholder Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        children: [
                          Text('Daily', style: TextStyle(fontSize: 12)),
                          Icon(Icons.arrow_drop_down, size: 16),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ), // Màu link
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Placeholder Chart Area (replace with actual chart widget)
            SizedBox(
              height: 150, // Chiều cao của biểu đồ
              child: SfCartesianChart(
                // Sử dụng SfCartesianChart
                // Cấu hình trục X (Thời gian)
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  // Ẩn grid line chính
                  // majorGridLines: MinorGridLines(width: 0), // Ẩn grid line phụ
                  axisLine: AxisLine(width: 0),
                  // Ẩn đường trục
                  // Tùy chỉnh nhãn (nếu cần)
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
                // Cấu hình trục Y
                primaryYAxis: NumericAxis(
                  isVisible: false, // Ẩn trục Y
                  majorGridLines: MajorGridLines(width: 0),
                  minorGridLines: MinorGridLines(width: 0),
                  axisLine: AxisLine(width: 0),
                ),
                // Ẩn chú thích
                legend: Legend(isVisible: false),
                // Tooltip (để hiển thị giá trị khi chạm vào điểm)
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: '\$point.y',
                ),
                // Hiển thị giá trị Y (ví dụ: $500)
                // Series dữ liệu
                series: [
                  SplineAreaSeries<ChartData, String>(
                    // Sử dụng SplineAreaSeries cho biểu đồ vùng mượt
                    dataSource: _chartData,
                    // Dữ liệu biểu đồ
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.transparent,
                    // Đường spline trong suốt
                    gradient: LinearGradient(
                      // Gradient cho vùng bên dưới
                      colors: [
                        Colors.orange.withValues(alpha: 0.3),
                        // Màu bắt đầu gradient (cam nhạt)
                        Colors.transparent,
                        // Màu kết thúc gradient (trong suốt)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    // Tùy chỉnh đường viền của vùng
                    borderDrawMode: BorderDrawMode.top,
                    borderColor: Colors.orange,
                    // Màu đường viền
                    borderWidth: 2,
                    // Độ dày đường viền
                    // Điểm đánh dấu (marker) cho các điểm dữ liệu
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      // Hiển thị marker
                      shape: DataMarkerType.circle,
                      // Hình tròn
                      color: Colors.orange,
                      // Màu marker
                      borderColor: Colors.white,
                      // Màu viền marker
                      borderWidth: 2,
                      // Độ dày viền marker
                      height: 8,
                      width: 8, // Kích thước marker
                    ),
                    // Data Label (hiển thị giá trị trên điểm - có thể ẩn nếu dùng tooltip)
                    dataLabelSettings: DataLabelSettings(
                      isVisible: false,
                    ), // Ẩn data label
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem(String type, String name, String image) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      // Khoảng cách giữa các item dọc
      elevation: 2.0,
      // Độ nổi của card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Bo tròn góc card
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding bên trong card
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Căn chỉnh các mục con theo chiều dọc lên trên
          children: [
            // Placeholder Ảnh/Biểu tượng
            Container(
              width: 80, // Chiều rộng placeholder
              height: 80, // Chiều cao placeholder
              decoration: BoxDecoration(
                color: Colors.grey[300], // Màu nền placeholder
                borderRadius: BorderRadius.circular(
                  8.0,
                ), // Bo tròn góc placeholder
              ),
              child: Image.asset(image),
            ),
            SizedBox(width: 16.0),
            // Khoảng cách giữa ảnh và nội dung text/button
            // Phần Nội dung Text và Buttons
            Expanded(
              // Sử dụng Expanded để phần này chiếm hết không gian còn lại
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Căn chỉnh nội dung bên trái
                children: [
                  // Category
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.redAccent,
                    ), // Màu đỏ nhạt như hình
                  ),
                  SizedBox(height: 4.0),
                  // Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),

                  // ID
                  Text(
                    'ID: 01',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.0),

                  // Price và Buttons (trong một Row)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // Đẩy Price sang trái, Buttons sang phải
                    crossAxisAlignment: CrossAxisAlignment.end,
                    // Căn chỉnh các mục con theo chiều dọc xuống dưới
                    children: [
                      // Price
                      Text(
                        'VNĐ ${'200.000'}',
                        // Định dạng giá (ví dụ không lấy phần thập phân)
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Buttons
                      Row(
                        children: [
                          // Nút 1 (Xóa hoặc Done)
                          Container(
                            decoration: BoxDecoration(),
                            child: ElevatedButton(
                              onPressed:
                                  isDoneState ? onCancelOrDone : onDelete,
                              // Gán callback tương ứng với trạng thái
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff774606),
                                // Màu nền nút Xóa/Done
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.orange,
                                // Màu chữ nút Xóa/Done
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8.0,
                                  ), // Bo tròn góc nút
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                // Padding nút
                                minimumSize: Size(0, 36), // Chiều cao tối thiểu
                              ),
                              child: Text(
                                isDoneState ? 'Done' : 'Xóa',
                                style: TextStyle(color: Colors.white),
                              ), // Text nút
                            ),
                          ),
                          SizedBox(width: 8.0), // Khoảng cách giữa hai nút
                          // Nút 2 (Hủy hoặc Cancel)
                          OutlinedButton(
                            // Sử dụng OutlinedButton cho nút có viền
                            onPressed: onCancelOrDone, // Gán callback
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDoneState
                                  ? Colors.redAccent
                                  : Colors.redAccent,
                              // Màu chữ nút Hủy/Cancel (màu đỏ nhạt)
                              side: BorderSide(
                                color: isDoneState
                                    ? Colors.redAccent
                                    : Colors.redAccent,
                                width: 1.0,
                              ),
                              // Màu viền
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8.0,
                                ), // Bo tròn góc nút
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              // Padding nút
                              minimumSize: Size(0, 36), // Chiều cao tối thiểu
                            ),
                            child: Text(
                              isDoneState ? 'Cancel' : 'Hủy',
                            ), // Text nút
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng số lượt yêu thích',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.favorite, color: Colors.orange, size: 20),
              // Icon ngôi sao
              SizedBox(width: 4),
              FutureBuilder<AggregateQuerySnapshot>(
                future: _totalLikesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Đang trong quá trình fetch dữ liệu
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // Có lỗi xảy ra trong quá trình fetch
                    return Text('Lỗi: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    // Dữ liệu đã fetch thành công
                    final totalLikesSnapshot = snapshot.data!;
                    // Lấy giá trị tổng lượt thích từ kết quả truy vấn tổng hợp
                    // Sử dụng .getSum('likes') với tên trường đã dùng trong sum()
                    final totalLikes = totalLikesSnapshot.getSum('favorcount');
                    return Text(
                      totalLikes?.toInt().toString() ??
                          'không có dữ liệu', // Giá trị rating
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const Text('Không có dữ liệu tổng lượt thích');
                  }
                },
              ),
              SizedBox(width: 10),
            ],
          ),

          // Text(
          //   'Số lượt thích',
          //   style: TextStyle(fontSize: 12, color: Colors.blue), // Màu link
          // ),
        ],
      ),
    );
  }

  // Widget _buildCommentSection() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         'Tổng số lượt bình luận',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       Row(
  //         children: [
  //           SizedBox(width: 16),
  //           Icon(Icons.message, color: Colors.orange, size: 20),
  //           // Icon ngôi sao
  //           SizedBox(width: 4),
  //           Text(
  //             '100', // Giá trị rating
  //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(width: 10),
  //         ],
  //       ),
  //
  //       // Text(
  //       //   'Số lượt thích',
  //       //   style: TextStyle(fontSize: 12, color: Colors.blue), // Màu link
  //       // ),
  //     ],
  //   );
  // }

  Widget _buildPopularModelsSection(BuildContext context, String idName) {
    return StreamBuilder(
      stream: data.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {}
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Những mô hình được phổ biến',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => AnimalListScreen(),
                          curve: Curves.linear,
                          transition: Transition.rightToLeft);
                    },
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ), // Màu link
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Horizontal scrollable list of model placeholders
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot records =
                                snapshot.data!.docs[index];
                            String idname = records["idName"];
                            return (idname == idName)
                                ? GestureDetector(
                                    onTap: () {
                                      Get.to(
                                          () => AnimalInfoScreen(
                                                arguments: records,
                                              ),
                                          curve: Curves.linear,
                                          transition: Transition.rightToLeft);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      width: 150,
                                      // Chiều rộng của mỗi model placeholder
                                      height: 100,
                                      // Chiều cao của mỗi model placeholder
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.grey[300], // Màu placeholder
                                        borderRadius:
                                            BorderRadius.circular(12.0),

                                        // TODO: Thêm nội dung cho mỗi model (ảnh, tên, v.v.)
                                      ),
                                      child: CachedNetworkImage(
                                          imageUrl: records["imageUrl"]),
                                      // Child: Text('Model Placeholder'), // Ví dụ nội dung
                                    ),
                                  )
                                : Container();
                          },
                        ),
                      ), // Thêm các placeholder khác nếu cần
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  // Widget _buildModelPlaceholder(String image) {
  //   return Container(
  //     margin: EdgeInsets.only(right: 5),
  //     width: 150, // Chiều rộng của mỗi model placeholder
  //     height: 100, // Chiều cao của mỗi model placeholder
  //     decoration: BoxDecoration(
  //       color: Colors.grey[300], // Màu placeholder
  //       borderRadius: BorderRadius.circular(12.0),
  //       image: DecorationImage(image: AssetImage(image)),
  //       // TODO: Thêm nội dung cho mỗi model (ảnh, tên, v.v.)
  //     ),
  //     // Child: Text('Model Placeholder'), // Ví dụ nội dung
  //   );
  // }
}
