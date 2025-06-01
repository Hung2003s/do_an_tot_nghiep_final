import 'package:animal_2/user/pages/favorite_model.dart';
import 'package:animal_2/user/ui/ui_home_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class _HomeNatureState extends State<HomeNature>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool? isVipUser;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  ScrollController? _scrollController;
  late final AnimationController _animationController;
  bool _isScrolling = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController?.addListener(_scrollListener);
    _fetchVipStatus();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController?.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!_isScrolling) {
        setState(() => _isScrolling = true);
        _animationController.forward();
      }
    } else if (_scrollController?.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_isScrolling) {
        setState(() => _isScrolling = false);
        _animationController.reverse();
      }
    }
  }

  Future<void> _fetchVipStatus() async {
    if (_currentUser == null) {
      setState(() {
        isVipUser = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('user')
          .where('Email', isEqualTo: _currentUser!.email?.toLowerCase())
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        setState(() {
          _userData = userDoc.data();
          isVipUser = _userData?['vip'] == true;
          _isLoading = false;
        });
      } else {
        setState(() {
          isVipUser = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching VIP status: $e');
      setState(() {
        isVipUser = false;
        _isLoading = false;
      });
    }
  }

  void _navigateToScreen(Widget screen) {
    Get.to(
      () => screen,
      curve: Curves.linear,
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(OneImages.ar_background),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildHeader(),
                _buildFeaturedNature(),
                _buildQuickAccessButtons(),
                _buildOtherNatureTypes(),
              ],
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * _animationController.value),
                  child: _buildButtonOpenSideBar(context),
                );
              },
            ),
          ],
        ),
        endDrawer: _buildDrawer(),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 10, bottom: 40),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.16,
                child: _buildOptimizedImage(
                  'assets/images/animal_kid.png',
                ),
              ),
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
    );
  }

  Widget _buildFeaturedNature() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
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
            _buildFeaturedNatureCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedNatureCard() {
    return RepaintBoundary(
      child: InkWell(
        onTap: () =>
            _navigateToScreen(HomeMain(id: 1, isVipUser: isVipUser ?? false)),
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
                child: _buildOptimizedImage(
                  'assets/images/5371964.jpg',
                ),
              ),
            ),
            SizedBox(
              height: 270,
              width: 270,
              child: _buildOptimizedImage(
                'assets/images/tiger_kid.png',
              ),
            ),
            Positioned(
              bottom: 40,
              right: 20,
              child: OneCard(
                borderRadius: BorderRadius.circular(25),
                padding: const EdgeInsets.all(8),
                child: const Row(
                  children: [
                    Text(
                      'Tìm hiểu thêm',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
    );
  }

  Widget _buildQuickAccessButtons() {
    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildQuickAccessButton(
            title: 'Tips',
            icon: 'assets/images/image_tip.png',
            color: const Color(0xFFFCC2FC),
            onTap: () => _navigateToScreen(const ScreenTips()),
          ),
          _buildQuickAccessButton(
            title: 'Tiến Hóa',
            icon: 'assets/images/image_tienhoa.png',
            color: const Color(0xFFCDE990),
            onTap: () => _navigateToScreen(const EvolutionScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required String title,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    color: color,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 150,
                    child: _buildOptimizedImage(
                      icon,
                    ),
                  ),
                ),
                _buildQuickAccessButtonLabel(title),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButtonLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(color: Colors.white, width: 3),
          color: Colors.white,
        ),
        child: SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width * 0.25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
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
                      title,
                      style: GoogleFonts.aBeeZee(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherNatureTypes() {
    return SliverToBoxAdapter(
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
                  _buildNatureTypeButton(
                    image: 'assets/images/ocean.png',
                    id: 2,
                  ),
                  _buildNatureTypeButton(
                    image: 'assets/images/grass.png',
                    id: 3,
                  ),
                  _buildNatureTypeButton(
                    image: 'assets/images/jura.png',
                    id: 4,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNatureTypeButton({
    required String image,
    required int id,
  }) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: InkWell(
          onTap: () => _navigateToScreen(
              HomeMain(id: id, isVipUser: isVipUser ?? false)),
          child: _buildOptimizedImage(
            image,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/17545.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black,
              BlendMode.darken,
            ),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(50),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildDrawerItems(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final avatarUrl = _userData?['avatar'] as String?;
    final firstName = _userData?['FirstName'] as String?;
    final lastName = _userData?['LastName'] as String?;

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? CachedNetworkImageProvider(
                    avatarUrl,
                    maxWidth: 100,
                    maxHeight: 100,
                  ) as ImageProvider
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey[400],
                  )
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            _getUserDisplayName(),
            style: GoogleFonts.aBeeZee(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return [
      if (_currentUser == null)
        _buildDrawerItem(
          icon: Icons.login,
          title: 'Đăng nhập',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      _buildDrawerItem(
        icon: Icons.person,
        title: 'Thông tin cá nhân',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PersonalInfoScreen1()),
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
          Get.to(
            () => const FavoriteAnimalScreen(),
            curve: Curves.linear,
            transition: Transition.rightToLeft,
          );
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
      if (_currentUser != null)
        _buildDrawerItem(
          icon: Icons.logout,
          title: 'Đăng xuất',
          onTap: () {
            _handleSignOut();
          },
        ),
    ];
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
        color: const Color(0xff601b7c),
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
      hoverColor: const Color(0xff601b7c).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
              border: Border.all(color: OneColors.white, width: 1),
            ),
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

  Widget _buildOptimizedImage(String assetPath,
      {double? width, double? height}) {
    return RepaintBoundary(
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        cacheWidth: width != null
            ? (width * MediaQuery.of(context).devicePixelRatio).toInt()
            : null,
        cacheHeight: height != null
            ? (height * MediaQuery.of(context).devicePixelRatio).toInt()
            : null,
      ),
    );
  }

  String _getUserDisplayName() {
    final firstName = _userData?['FirstName'] as String?;
    final lastName = _userData?['LastName'] as String?;

    if ((lastName != null && lastName.isNotEmpty) ||
        (firstName != null && firstName.isNotEmpty)) {
      return '${lastName ?? ''} ${firstName ?? ''}';
    }
    return 'Chào mừng';
  }

  Future<void> _handleSignOut() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
