// ignore_for_file: deprecated_member_use

import 'dart:io' as io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:native_ar_viewer/native_ar_viewer.dart';
import '../const/ar_color.dart';
import '../const/ar_image.dart';
//import '../const/cache/ar_cache_image.dart';
import '../fireBase/fireBase_help.dart';
import 'image_3D.dart';

class TrackingImange extends StatefulWidget {
  const TrackingImange({super.key});

  @override
  State<TrackingImange> createState() => _TrackingImangeState();
}

class _TrackingImangeState extends State<TrackingImange> {
  List<Map<String, dynamic>> _trackingImageList = [];

  @override
  void initState() {
    super.initState();
    getTrackingImageData().then((data) {
      setState(() {
        _trackingImageList = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(OneImages.ar_background),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [_buildHead(), _buildListTracking()],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHead() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Cách sử dụng quét hình ảnh',
                    style: GoogleFonts.aBeeZee(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: Image.asset(
                                  'assets/images/ex1.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Chọn động vật bạn muốn quét',
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.arrow_right_alt,
                            size: 40,
                            color: OneColors.black,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: Image.asset(
                                  'assets/images/ex2.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Quét vào hình ảnh cố định của nó',
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.arrow_right_alt,
                            size: 40,
                            color: OneColors.black,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: Image.asset(
                                  'assets/images/ex3.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Giữ cố định máy để hiện ảnh 3D',
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(
              'Danh sách động vật có hỗ trợ quét',
              style: GoogleFonts.aBeeZee(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildListTracking() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        // height: MediaQuery.of(context).size.height * 1.2,
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: _trackingImageList.length,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // số cột trong lưới
            mainAxisSpacing: 20, // khoảng cách giữa các hàng
            crossAxisSpacing: 20, // khoảng cách giữa các cột
          ),
          itemBuilder: (context, index) {
            return IntrinsicHeight(
              child: InkWell(
                onTap: () {
                  Get.to(
                    () => Image3D(urls: _trackingImageList[index]['url']),
                    curve: Curves.linear,
                    transition: Transition.rightToLeft,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: OneColors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        color: OneColors.textGreyDark.withValues(alpha: 0.3),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            height: double.infinity,
                            width: 200,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(25),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: _trackingImageList[index]["image"],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 190, 190, 190),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(25),
                            topLeft: Radius.circular(5),
                            // bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 0, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  _trackingImageList[index]["name"],
                                  style: GoogleFonts.aBeeZee(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
