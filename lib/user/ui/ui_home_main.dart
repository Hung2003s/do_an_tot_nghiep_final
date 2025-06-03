// ignore_for_file: unused_local_variable, avoid_print, unrelated_type_equality_checks, prefer_typing_uninitialized_variables;

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../const/ar_color.dart';
import '../const/ar_image.dart';
import '../const/ar_list_color.dart';
import '../const/cache/ar_cache_image.dart';
import '../pages/detail_animal_screen.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({
    super.key,
    required this.id,
    required this.isVipUser,
  });

  final id;
  final bool isVipUser;

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final CollectionReference data =
      FirebaseFirestore.instance.collection("animalDB");
  final CollectionReference habitatsData =
      FirebaseFirestore.instance.collection("habitats");

  Map<int, String> habitatNames = {};
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabitatNames();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHabitatNames() async {
    try {
      final habitatsSnapshot = await habitatsData.get();
      final Map<int, String> names = {};
      for (var doc in habitatsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final id = int.tryParse(doc.id.replaceAll('habitat', ''));
        if (id != null) {
          names[id] = data['habitat_name'] ?? '';
        }
      }
      if (mounted) {
        setState(() {
          habitatNames = names;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> getHabitatName(dynamic habitatId) async {
    try {
      if (habitatId == null || habitatId == 0) {
        return '';
      }
      String habitatIdStr = "habitat" + habitatId.toString();
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
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: StreamBuilder(
              stream: data.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        if (id == 1) ...[
                          _buildSection(
                            'Động vật ăn cỏ',
                            snapshot,
                            "Ăn cỏ",
                            isFoodFilter: true,
                          ),
                          _buildSection(
                            'Động vật ăn thịt',
                            snapshot,
                            "Ăn thịt",
                            isFoodFilter: true,
                          ),
                        ] else if (id == 2) ...[
                          _buildSection(
                            'Động vật sống ở nước mặn',
                            snapshot,
                            "Nước mặn",
                          ),
                          _buildSection(
                            'Động vật sống ở nước ngọt',
                            snapshot,
                            "Nước ngọt",
                          ),
                          _buildSection(
                            'Động vật sống ở rừng rậm',
                            snapshot,
                            "Rừng rậm",
                          ),
                          _buildSection(
                            'Động vật sống ở thảo nguyên',
                            snapshot,
                            "Thảo nguyên",
                          ),
                          _buildSection(
                            'Động vật sống ở bầu trời',
                            snapshot,
                            "Bầu trời",
                          ),
                        ] else if (id == 3) ...[
                          _buildSection(
                            'Nông trại',
                            snapshot,
                            "Nông trại",
                          ),
                        ] else if (id == 4) ...[
                          _buildSection(
                            'Khủng long',
                            snapshot,
                            "Tiền sử",
                           // isPrehistoric: true,
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title,
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String filter,
      {bool isFoodFilter = false}) {
    return Column(
      children: [
        _buildNoidung(title),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          width: MediaQuery.of(context).size.width,
          child: _buildListView(snapshot, filter, isFoodFilter: isFoodFilter),
        ),
      ],
    );
  }

  Widget _buildAnimalCard(DocumentSnapshot records, int indexRandom) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () =>
            _handleAnimalTap(context, records, indexRandom, widget.isVipUser),
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
                        topRight: Radius.circular(30),
                      ),
                      color: ColorRamdom.animalColor[indexRandom],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 90),
                    child: Stack(
                      children: [
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.grey, blurRadius: 10)
                            ],
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 300,
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff95BDFF),
                                      borderRadius: BorderRadius.circular(10),
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
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          records["nameAnimal"] ?? "",
                                          style: GoogleFonts.aBeeZee(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
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
                                    style: GoogleFonts.aBeeZee(fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (records['required_vip'] == true)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Icon(Icons.lock,
                                color: Colors.orange, size: 24),
                          ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 100,
                      child: CachedNetworkImage(
                        imageUrl: records["imageUrl"],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _buildListView(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, String filterValue,
      {bool isFoodFilter = false, bool isPrehistoric = false}) {
    if (!snapshot.hasData) {
      return const SizedBox();
    }

    final filteredDocs = snapshot.data!.docs.where((records) {
      dynamic habitatId = records["habitat_id"];
      String animalFood = records["food"] ?? '';
      String lifePeriod = records["life_period"] ?? '';

      bool isPrehistoricAnimal = lifePeriod == "Tiền sử";
      bool isLandPrehistoric =
          isPrehistoricAnimal && (habitatId >= 1 && habitatId <= 4);
      bool isWaterPrehistoric =
          isPrehistoricAnimal && (habitatId == 5 || habitatId == 6);

      String habitatName = habitatNames[habitatId] ?? '';

      return isFoodFilter
          ? animalFood == filterValue
          : isPrehistoric
              ? (filterValue == "trencan" && isLandPrehistoric) ||
                  (filterValue == "duoinuoc" && isWaterPrehistoric)
              : habitatName == filterValue;
    }).toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final records = filteredDocs[index];
        Random random = Random();
        var indexRandom = random.nextInt(ColorRamdom.animalColor.length);
        return _buildAnimalCard(records, indexRandom);
      },
    );
  }

  void _handleAnimalTap(BuildContext context, DocumentSnapshot records,
      int indexRandom, bool isVipUser) async {
    try {
      if (records['required_vip'] == true && !isVipUser) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Chỉ dành cho tài khoản VIP'),
              content: const Text(
                  'Vui lòng nâng cấp tài khoản để truy cập động vật VIP.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
        return;
      }
      if (context.mounted) {
        Get.to(
          () => DetailAnimalScreen(
            arguments: records,
            colors: ColorRamdom.animalColor[indexRandom],
          ),
          curve: Curves.linear,
          transition: Transition.rightToLeft,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text('Đã xảy ra lỗi khi kiểm tra quyền truy cập: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  Container _buildNoidung(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xff95BDFF),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Text(
          title,
          style: GoogleFonts.aBeeZee(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: OneColors.textWhite,
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader _buildHeader(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SliverAppBarDelegate(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 20.0, left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
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
                  child: Center(
                    child: Text(
                      'Khám phá động vật',
                      style: GoogleFonts.aBeeZee(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
