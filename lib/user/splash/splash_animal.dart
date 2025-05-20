import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../const/ar_color.dart';
import '../const/ar_image.dart';
import '../const/ar_theme.dart';
import '../ui/ui_home_tabs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final CollectionReference data =
      FirebaseFirestore.instance.collection("modeldata");
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Giảm thời gian chờ xuống 3 giây
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeTabs()),
        );
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(OneImages.ar_splash),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Image.asset(OneImages.ar_logo),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset(
                    "assets/images/loadingAnimal.json",
                    onLoaded: (composition) {
                      setState(() => _isLoading = false);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "Không có kết nối Internet\nVui lòng kiểm tra lại kết nối mạng!",
                          style: OneTheme.of(context).title1.copyWith(
                                color: OneColors.textOrange,
                              ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (!_isLoading)
                  SizedBox(
                    height: 40,
                    child: StreamBuilder(
                      stream: data.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: OneColors.brandVNP,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Có lỗi xảy ra',
                              style: TextStyle(color: OneColors.textOrange),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot records =
                                snapshot.data!.docs[index];
                            String? imageUrl = records["imageUrl"];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: _buildImageUrl(imageUrl ?? ""),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUrl(String imageUrl) {
    return CircleAvatar(
      radius: 10,
      backgroundColor: Colors.transparent,
      child: Image.network(
        imageUrl,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: OneColors.brandVNP,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            Image.asset("assets/images/jura.png"),
      ),
    );
  }
}
