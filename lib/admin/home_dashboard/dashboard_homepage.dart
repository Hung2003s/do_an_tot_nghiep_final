import 'package:animal_2/admin/home_dashboard/admin_homepage.dart';
import 'package:animal_2/admin/notification/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../add_animal/add_animal_screen.dart';
// import '../list_product/list_animal_item.dart';
import '../list_product/list_animal_screen.dart';
import '../personal_info_menu/personal_info_screen.dart'; // Import nếu dùng SfCartesianChart



class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  //bool _showBottomSheet = false;

  static const List<Widget> _screens = <Widget>[
    AdminHomepage(),
    AnimalListScreen(),
    NotificationScreen(),
    RevenueScreen(),
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ mục được chọn
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Màu nền nhạt
      body: _screens[_selectedIndex],
      // bottomSheet:
      //     _showBottomSheet
      //         ? BottomSheet(
      //           elevation: 40,
      //           backgroundColor: Color(0xffb4b4b4),
      //           enableDrag: true,
      //           onClosing: () {},
      //           builder:
      //               (BuildContext ctx) => Container(
      //                 padding: EdgeInsets.symmetric(vertical: 10),
      //                 width: double.infinity,
      //                 height: 600,
      //                 alignment: Alignment.center,
      //                 child: Column(
      //                   children: [
      //                     Expanded(
      //                       child: ListView.builder(
      //                         scrollDirection: Axis.vertical,
      //                         itemCount: 4,
      //                         itemBuilder: (context, index) {
      //                           return _buildBottomSheetItem();
      //                         },
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //         )
      //         : null,
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
      // Floating Action Button (for the centered plus icon)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> AddAnimalScreen()));
        },
        backgroundColor: Colors.orange,
        shape: CircleBorder(),
        // Hình tròn
        elevation: 1.0,
        // Màu nút '+'
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation
          .centerDocked, // Đặt nút '+' ở giữa BottomAppBar
    );
  }

  // --- Widget cho từng phần ---



  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xff808080).withValues(alpha: 0.4),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: CircularNotchedRectangle(), // Tạo khấc tròn cho FAB
        notchMargin: 6.0, // Khoảng cách từ FAB đến BottomAppBar
        color: Colors.white, // Màu nền BottomAppBar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.grid_view),
                onPressed:
                    () {
                  setState(() {
                    _selectedIndex = 0; // Cập nhật chỉ mục
                  });
                },
                color: _selectedIndex == 0 ? Colors.orange : Colors.grey[700],
              ),
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Cập nhật chỉ mục
                  });
                },
                color: _selectedIndex == 1 ? Colors.orange : Colors.grey[700],
              ),
              SizedBox(width: 20), // Khoảng trống cho FAB
              IconButton(
                icon: Icon(Icons.notifications_none),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2; // Cập nhật chỉ mục
                  });
                },
                color: _selectedIndex == 2 ? Colors.orange : Colors.grey[700],
              ),
              IconButton(
                icon: Icon(Icons.person_outline),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 3; // Cập nhật chỉ mục
                  });
                },
                color: _selectedIndex == 3 ? Colors.orange : Colors.grey[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
