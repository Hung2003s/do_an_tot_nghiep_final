import 'dart:math';

import 'package:animal_2/user/const/ar_image.dart';
import 'package:animal_2/user/pages/detail_animal_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../admin/list_product/animal_info_screen.dart';
import '../../admin/list_product/list_animal_screen.dart';
import '../const/ar_list_color.dart';

class FavoriteModelScreen extends StatefulWidget {
  const FavoriteModelScreen({super.key});

  @override
  State<FavoriteModelScreen> createState() => _FavoriteModelScreenState();
}

class _FavoriteModelScreenState extends State<FavoriteModelScreen> {
  final CollectionReference data =
      FirebaseFirestore.instance.collection("animalDB");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(OneImages.ar_background), fit: BoxFit.cover)),
        child: Column(
          children: [
            Container(
              height: 50,
            ),
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
            _buildListAnimal(context, 'anco')
          ],
        ),
      ),
    );
  }

  Widget _buildListAnimal(BuildContext context, String food) {
    return StreamBuilder(
      stream: data.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {}
        if (snapshot.hasData) {
          return Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Random random = Random();
                var indexRandom =
                    random.nextInt(ColorRamdom.animalColor.length);
                final DocumentSnapshot records = snapshot.data!.docs[index];
                String animalID = records["AnimalID"];
                return (animalID == food)
                    ? GestureDetector(
                        onTap: () {
                          Get.to(
                              () => DetailAnimalScreen(
                                    arguments: records,
                                    colors:
                                        ColorRamdom.animalColor[indexRandom],
                                  ),
                              curve: Curves.linear,
                              transition: Transition.rightToLeft);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 10), // Padding dọc cho mỗi item
                          decoration: BoxDecoration(
                              color: Color(0xff77a8a0).withValues(alpha: 0.8),
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.0), // Đường phân cách mỏng
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Placeholder Ảnh/Biểu tượng
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Bo tròn góc
                                ),
                                child: Image.asset(
                                  records["imageUrl"],
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 16.0), // Khoảng cách

                              // Phần Nội dung (Tên, Loại, Rating)
                              Expanded(
                                // Chiếm hết không gian còn lại trừ phần bên phải cố định
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
                                      // Container cho label loại
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .orange[100], // Màu nền nhạt cam
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        records['AnimalID'],
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black), // Màu chữ cam
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      // Rating
                                      children: [
                                        const Icon(Icons.favorite,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          '${records["favorcount"]}', // Định dạng rating 1 chữ số thập phân
                                          style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Phần bên phải (Giá, ...)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .end, // Căn chỉnh sang phải
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Miễn phí', // Định dạng giá
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 4.0),
                                      // Icon ba chấm
                                    ],
                                  ),
                                  const SizedBox(height: 8.0), // Khoảng cách
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container();
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}
