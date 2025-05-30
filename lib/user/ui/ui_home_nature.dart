import 'package:animal_2/user/pages/favorite_model.dart';
import 'package:animal_2/user/ui/ui_home_main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../const/ar_card.dart';
import '../const/ar_color.dart';
import '../const/ar_image.dart';
import '../pages/evolution_screen.dart';
import '../pages/screen_tips.dart';
import '../pages/screen_two.dart';
import 'login_screen/login_screen.dart';
import 'ui_home_tracking.dart';
import 'ui_home_tabs.dart';
import '../const/ar_theme.dart';
import 'personal_info/personal_info.dart';

class HomeNature extends StatefulWidget {
  const HomeNature({super.key});

  @override
  State<HomeNature> createState() => _HomeNatureState();
}

class _HomeNatureState extends State<HomeNature> {
  int? animalId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool? isVipUser;

  @override
  void initState() {
    super.initState();
    _fetchVipStatus();
  }

  Future<void> _fetchVipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    bool vip = false;
    if (user != null) {
      final userQuery =
          await FirebaseFirestore.instance.collection('user').get();
      final matchingDocs = userQuery.docs
          .where((doc) =>
              doc.data().containsKey('Email') &&
              doc.data()['Email']?.toString().toLowerCase() ==
                  user.email?.toLowerCase())
          .toList();
      if (matchingDocs.isNotEmpty) {
        vip = matchingDocs.first.data()['vip'] == true;
      }
    }
    setState(() {
      isVipUser = vip;
    });
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isVipUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 10, bottom: 40),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.16,
                                child: Image.asset(
                                    'assets/images/animal_kid.png')),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                'Chào mừng bạn đã đến',
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5, bottom: 5),
                              child: Text(
                                'Dạng thiên nhiên nổi bật',
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Get.to(
                                  () => HomeMain(
                                      id: 1, isVipUser: isVipUser ?? false),
                                  curve: Curves.linear,
                                  transition: Transition.rightToLeft);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: 1,
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.asset(
                                          'assets/images/5371964.jpg')),
                                ),
                                SizedBox(
                                  height: 270,
                                  width: 270,
                                  child: Image.asset(
                                      'assets/images/tiger_kid.png'),
                                ),
                                Positioned(
                                  bottom: 40,
                                  right: 20,
                                  child: OneCard(
                                    borderRadius: BorderRadius.circular(25),
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: const [
                                        Text(
                                          'Tìm hiểu thêm',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.navigate_next,
                                          size: 12,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Get.to(() => const ScreenTips(),
                                curve: Curves.linear,
                                transition: Transition.rightToLeft);
                          },
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    height: 100,
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(30)),
                                      color: Color(0xFFFCC2FC),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: SizedBox(
                                        height: 150,
                                        child: Image.asset(
                                          'assets/images/image_tip.png',
                                        ),
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 80),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                            color: Colors.white),
                                        child: SizedBox(
                                          height: 100,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff95BDFF),
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
                                                      "Tips",
                                                      style:
                                                          GoogleFonts.aBeeZee(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => const EvolutionScreen(),
                                curve: Curves.linear,
                                transition: Transition.rightToLeft);
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30),
                                            bottomLeft: Radius.circular(30),
                                            bottomRight: Radius.circular(30)),
                                        color: Color(0xFFCDE990),
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.topCenter,
                                        child: SizedBox(
                                          height: 150,
                                          child: Image.asset(
                                            'assets/images/image_tienhoa.png',
                                          ),
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 80),
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(15),
                                                bottomRight:
                                                    Radius.circular(15),
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 3),
                                              color: Colors.white),
                                          child: SizedBox(
                                            height: 100,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff95BDFF),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0xffBAD7E9),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Text(
                                                        "Tiến Hóa",
                                                        style:
                                                            GoogleFonts.aBeeZee(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 30),
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Các dạng thiên nhiên khác',
                                        style: GoogleFonts.aBeeZee(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: InkWell(
                                        child: Image.asset(
                                            'assets/images/ocean.png'),
                                        onTap: () {
                                          Get.to(
                                              () => HomeMain(
                                                  id: 2,
                                                  isVipUser:
                                                      isVipUser ?? false),
                                              curve: Curves.linear,
                                              transition:
                                                  Transition.rightToLeft);
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: InkWell(
                                        child: Image.asset(
                                            'assets/images/grass.png'),
                                        onTap: () {
                                          Get.to(
                                              () => HomeMain(
                                                  id: 3,
                                                  isVipUser:
                                                      isVipUser ?? false),
                                              curve: Curves.linear,
                                              transition:
                                                  Transition.rightToLeft);
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: InkWell(
                                        child: Image.asset(
                                            'assets/images/jura.png'),
                                        onTap: () {
                                          Get.to(
                                              () => HomeMain(
                                                  id: 4,
                                                  isVipUser:
                                                      isVipUser ?? false),
                                              curve: Curves.linear,
                                              transition:
                                                  Transition.rightToLeft);
                                        }),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          )
                        ]),
                  ),
                ]),
            _buildButtonOpenSideBar(context),
          ],
        ),
        endDrawer: Drawer(
          backgroundColor: Colors.transparent,
          width: MediaQuery.of(context).size.width * 0.75,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/17545.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('user').get(),
              builder: (context, snapshot) {
                final user = FirebaseAuth.instance.currentUser;
                if (!snapshot.hasData || user == null) {
                  return const SizedBox.shrink();
                }
                final docs = snapshot.data!.docs;
                final userDoc = docs
                    .cast<QueryDocumentSnapshot<Map<String, dynamic>>?>()
                    .firstWhere(
                      (doc) =>
                          doc != null &&
                          doc.data().containsKey('Email') &&
                          doc.data()['Email']?.toString().toLowerCase() ==
                              user.email?.toLowerCase(),
                      orElse: () => null,
                    );
                final avatarUrl =
                    userDoc != null ? userDoc['avatar'] ?? '' : '';
                final firstName =
                    userDoc != null ? userDoc['FirstName'] ?? '' : '';
                final lastName =
                    userDoc != null ? userDoc['LastName'] ?? '' : '';
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 50, bottom: 20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                (avatarUrl != null && avatarUrl != '')
                                    ? NetworkImage(avatarUrl)
                                    : null,
                            child: (avatarUrl == null || avatarUrl == '')
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                          SizedBox(height: 10),
                          Text(
                            (lastName != '' || firstName != '')
                                ? '$lastName $firstName'
                                : 'Chào mừng',
                            style: GoogleFonts.aBeeZee(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            if (user == null)
                              _buildDrawerItem(
                                icon: Icons.login,
                                title: 'Đăng nhập',
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                  );
                                },
                              ),
                            _buildDrawerItem(
                              icon: Icons.person,
                              title: 'Thông tin cá nhân',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PersonalInfoScreen1()),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              icon: Icons.upgrade,
                              title: 'Nâng cấp tài khoản',
                              onTap: () {
                                // TODO: Thêm logic nâng cấp tài khoản
                              },
                            ),
                            _buildDrawerItem(
                              icon: Icons.favorite,
                              title: 'Yêu thích',
                              onTap: () {
                                Get.to(() => const FavoriteAnimalScreen(),
                                    curve: Curves.linear,
                                    transition: Transition.rightToLeft);
                              },
                            ),
                            _buildDrawerItem(
                              icon: Icons.quiz,
                              title: 'Kiểm tra kiến thức',
                              onTap: () {
                                Navigator.pop(context);
                                // Add navigation to quiz screen
                              },
                            ),
                            if (user != null)
                              _buildDrawerItem(
                                icon: Icons.logout,
                                title: 'Đăng xuất',
                                onTap: _signOut,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 30,
        color: Color(0xff601b7c),
      ),
      title: Text(
        title,
        style: GoogleFonts.aBeeZee(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      hoverColor: Color(0xff601b7c).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  Widget _buildButtonOpenSideBar(BuildContext context) {
    return Builder(
      builder: (context) => Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(top: 70, right: 20),
            decoration: BoxDecoration(
                color: const Color(0xFFA084DC),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: OneColors.grey,
                    blurRadius: 5,
                  ),
                ],
                border: Border.all(color: OneColors.white, width: 1)),
            child: const Icon(
              Icons.article_outlined,
              size: 25,
              color: OneColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
