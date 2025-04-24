import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  VoidCallback? onDelete ; // Callback khi nút Xóa được bấm
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
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
          ),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return _buildBottomSheetItem();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
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
        
                      // Popular Models Section
                      _buildPopularModelsSection(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '20',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SỐ MÔ HÌNH HIỆN CÓ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '05',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'SỐ NGƯỜI DÙNG',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
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
  Widget _buildBottomSheetItem() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4), // Khoảng cách giữa các item dọc
      elevation: 2.0, // Độ nổi của card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Bo tròn góc card
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding bên trong card
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh các mục con theo chiều dọc lên trên
          children: [
            // Placeholder Ảnh/Biểu tượng
            Container(
              width: 80, // Chiều rộng placeholder
              height: 80, // Chiều cao placeholder
              decoration: BoxDecoration(
                color: Colors.grey[300], // Màu nền placeholder
                borderRadius: BorderRadius.circular(8.0), // Bo tròn góc placeholder
              ),
              // TODO: Thêm Image.asset hoặc Image.network nếu có ảnh thật
            ),
            SizedBox(width: 16.0), // Khoảng cách giữa ảnh và nội dung text/button
            // Phần Nội dung Text và Buttons
            Expanded( // Sử dụng Expanded để phần này chiếm hết không gian còn lại
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh nội dung bên trái
                children: [
                  // Category
                  Text(
                    'Động vật ăn thịt',
                    style: TextStyle(fontSize: 12.0, color: Colors.redAccent), // Màu đỏ nhạt như hình
                  ),
                  SizedBox(height: 4.0),

                  // Name
                  Text(
                    'Sư Tử',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy Price sang trái, Buttons sang phải
                    crossAxisAlignment: CrossAxisAlignment.end, // Căn chỉnh các mục con theo chiều dọc xuống dưới
                    children: [
                      // Price
                      Text(
                        'VNĐ ${'200.000'}', // Định dạng giá (ví dụ không lấy phần thập phân)
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      // Buttons
                      Row(
                        children: [
                          // Nút 1 (Xóa hoặc Done)
                          Container(
                            decoration: BoxDecoration(
                            ),
                            child: ElevatedButton(
                              onPressed: isDoneState ? onCancelOrDone : onDelete, // Gán callback tương ứng với trạng thái
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff774606), // Màu nền nút Xóa/Done
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.orange,// Màu chữ nút Xóa/Done
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0), // Bo tròn góc nút
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding nút
                                minimumSize: Size(0, 36), // Chiều cao tối thiểu
                              ),
                              child: Text(isDoneState ? 'Done' : 'Xóa', style: TextStyle(
                                  color: Colors.white
                              ),), // Text nút
                            ),
                          ),
                          SizedBox(width: 8.0), // Khoảng cách giữa hai nút

                          // Nút 2 (Hủy hoặc Cancel)
                          OutlinedButton( // Sử dụng OutlinedButton cho nút có viền
                            onPressed: onCancelOrDone, // Gán callback
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDoneState ? Colors.redAccent : Colors.redAccent, // Màu chữ nút Hủy/Cancel (màu đỏ nhạt)
                              side: BorderSide(color: isDoneState ? Colors.redAccent : Colors.redAccent, width: 1.0), // Màu viền
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Bo tròn góc nút
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding nút
                              minimumSize: Size(0, 36), // Chiều cao tối thiểu
                            ),
                            child: Text(isDoneState ? 'Cancel' : 'Hủy'), // Text nút
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Yêu thích',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 16),
            Icon(Icons.star, color: Colors.amber, size: 20), // Icon ngôi sao
            SizedBox(width: 4),
            Text(
              '4.9', // Giá trị rating
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          'Số lượt thích',
          style: TextStyle(fontSize: 12, color: Colors.blue), // Màu link
        ),
      ],
    );
  }

  Widget _buildPopularModelsSection() {
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
            Text(
              'Xem tất cả',
              style: TextStyle(fontSize: 12, color: Colors.blue), // Màu link
            ),
          ],
        ),
        SizedBox(height: 16),
        // Horizontal scrollable list of model placeholders
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildModelPlaceholder(),
              SizedBox(width: 16),
              _buildModelPlaceholder(),
              SizedBox(width: 16),
              _buildModelPlaceholder(), // Thêm các placeholder khác nếu cần
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelPlaceholder() {
    return Container(
      width: 150, // Chiều rộng của mỗi model placeholder
      height: 100, // Chiều cao của mỗi model placeholder
      decoration: BoxDecoration(
        color: Colors.grey[300], // Màu placeholder
        borderRadius: BorderRadius.circular(12.0),

        // TODO: Thêm nội dung cho mỗi model (ảnh, tên, v.v.)
      ),
      // Child: Text('Model Placeholder'), // Ví dụ nội dung
    );
  }
}
