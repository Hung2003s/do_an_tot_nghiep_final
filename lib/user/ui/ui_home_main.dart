// ignore_for_file: unused_local_variable, avoid_print, unrelated_type_equality_checks, prefer_typing_uninitialized_variables;

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../const/ar_color.dart';
import '../const/ar_image.dart';
import '../const/ar_list_color.dart';
import '../const/cache/ar_cache_image.dart';
import '../pages/detail_animal_screen.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({
    super.key,
    required this.id,
  });

  final id;

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final CollectionReference data =
      FirebaseFirestore.instance.collection("animalDB");
  final CollectionReference habitatsData =
      FirebaseFirestore.instance.collection("habitats");

  Future<String> getHabitatName(dynamic habitatId) async {
    try {
      if (habitatId == null || habitatId == 0) {
        return '';
      }
      String habitatIdStr = "habitat${habitatId.toString()}";
      DocumentSnapshot habitatDoc = await habitatsData.doc(habitatIdStr).get();
      if (habitatDoc.exists) {
        Map<String, dynamic> data = habitatDoc.data() as Map<String, dynamic>;
        return data['habitat_name'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(OneImages.ar_background), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Scrollbar(
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildHeader(context),
                _buildListAnimal(context, widget.id),
              ]),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildListAnimal(BuildContext context, int id) {
    Random random = Random();
    return SliverToBoxAdapter(
        child: Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: StreamBuilder(
                stream: data.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {}
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          id == 1
                              ? Column(
                                  children: [
                                    _buildNoidung('Động vật ăn cỏ'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(snapshot, "Ăn cỏ",
                                            isFoodFilter: true)),
                                    // const SizedBox(height: 20),
                                    _buildNoidung('Động vật ăn thịt'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "Ăn thịt",
                                            isFoodFilter: true)),
                                  ],
                                )
                              : const SizedBox(),
                          id == 2
                              ? Column(
                                  children: [
                                    _buildNoidung('Động vật sống ở nước mặn'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "Nước mặn")),
                                    _buildNoidung('Động vật sống ở nước ngọt'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "Nước ngọt")),
                                    _buildNoidung('Động vật sống ở rừng rậm'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "Rừng rậm")),
                                    _buildNoidung(
                                        'Động vật sống ở thảo nguyên'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "Thảo nguyên")),
                                    _buildNoidung('Động vật sống ở bầu trời'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "Bầu trời")),
                                  ],
                                )
                              : const SizedBox(),
                          id == 3
                              ? Column(
                                  children: [
                                    _buildNoidung('Nông trại'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "Nông trại")),
                                    // const SizedBox(height: 10),
                                  ],
                                )
                              : const SizedBox(),
                          id == 4
                              ? Column(
                                  children: [
                                    _buildNoidung('Khủng long trên cạn'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "trencan",
                                            isPrehistoric: true)),
                                    // const SizedBox(height: 10),
                                    _buildNoidung('Khủng long dưới nước'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: _buildListView(
                                            snapshot, "duoinuoc",
                                            isPrehistoric: true)),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    );
                  }
                  return Container();
                })),
      ],
    ));
  }

  ListView _buildListView(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String filterValue,
      {bool isFoodFilter = false, bool isPrehistoric = false}) {
    if (!snapshot.hasData) {
      return ListView();
    }
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: snapshot.data?.docs.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot records = snapshot.data!.docs[index];
          Random random = Random();
          var indexRandom = random.nextInt(ColorRamdom.animalColor.length);
          dynamic habitatId = records["habitat_id"];
          String animalFood = records["food"] ?? '';
          String lifePeriod = records["life_period"] ?? '';

          bool isPrehistoricAnimal = lifePeriod == "Tiền sử";
          bool isLandPrehistoric =
              isPrehistoricAnimal && (habitatId >= 1 && habitatId <= 4);
          bool isWaterPrehistoric =
              isPrehistoricAnimal && (habitatId == 5 || habitatId == 6);

          return FutureBuilder<String>(
              future: getHabitatName(habitatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (snapshot.hasError) {
                  return const SizedBox();
                }
                String habitatName = snapshot.data ?? '';

                bool shouldShow = isFoodFilter
                    ? animalFood == filterValue
                    : isPrehistoric
                        ? (filterValue == "trencan" && isLandPrehistoric) ||
                            (filterValue == "duoinuoc" && isWaterPrehistoric)
                        : habitatName == filterValue;

                if (!shouldShow) return const SizedBox();

                return InkWell(
                  onTap: () {
                    Get.to(
                        () => DetailAnimalScreen(
                              arguments: records,
                              colors: ColorRamdom.animalColor[indexRandom],
                            ),
                        curve: Curves.linear,
                        transition: Transition.rightToLeft);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.36,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                                color: ColorRamdom.animalColor[indexRandom],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 90),
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.grey, blurRadius: 10)
                                      ],
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 300,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              color: const Color(0xff95BDFF),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0xffBAD7E9),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Text(
                                                  records["nameAnimal"] ?? "",
                                                  style: GoogleFonts.aBeeZee(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            records["infoAnimal"] ?? "",
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.aBeeZee(
                                                fontSize: 9),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                            Align(
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  height: 100,
                                  child: CachedNetworkImage(
                                      imageUrl: records["imageUrl"],
                                      fit: BoxFit.cover),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Container _buildNoidung(String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff95BDFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OneColors.textWhite, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10),
        child: Text(title,
            style: GoogleFonts.aBeeZee(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: OneColors.textWhite)),
      ),
    );
  }

  SliverPersistentHeader _buildHeader(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SliverAppBarDelegate(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(width: 0.5, color: OneColors.grey),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: SizedBox(), // SizedBox(
              )
            ],
          ),
        ),
        minHeight: MediaQuery.of(context).padding.top + 70,
        maxHeight: MediaQuery.of(context).padding.top + 70,
      ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
