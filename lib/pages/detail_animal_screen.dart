import 'dart:io' as io;

// import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:animal_2/ui/show_image_3d.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:native_ar_viewer/native_ar_viewer.dart';

// import 'package:native_ar_viewer/native_ar_viewer.dart';
import '../const/ar_color.dart';
import '../const/ar_image.dart';
import '../const/cache/ar_cache_image.dart';

class DetailAnimalScreen extends StatefulWidget {
  const DetailAnimalScreen({
    super.key,
    required this.arguments,
    required this.colors,
  });

  final arguments;
  final Color colors;

  @override
  State<DetailAnimalScreen> createState() => _DetailAnimalScreenState();
}

class _DetailAnimalScreenState extends State<DetailAnimalScreen> {
  var plkh;

  _launchAR(String model3DUrl) async {
    // if (io.Platform.isAndroid) {
    //   await NativeArViewer.launchAR(model3DUrl);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Platform not supported')));
    // }
  }

  @override
  Widget build(BuildContext context) {
    plkh = widget.arguments["plkh"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildImageAnimal(context, widget.arguments, widget.colors),
          _buildInfoAnimal(context, widget.arguments, plkh),
          _buildScanButton(context, widget.arguments),
        ],
      ),
    );
  }

  Padding _buildScanButton(BuildContext context, var arguments) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height - 120),
      child: Container(
        height: 150,
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // _launchAR(arguments["3Dimage"]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  // do something
                  return ShowImage3DScreen(image3d: arguments["3Dimage"]);
                },
              ),
            );
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Color(0xFFFCC2FC),
                  ),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Image.asset("assets/images/ar6.png", scale: 6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildInfoAnimal(
    BuildContext context,
    var arguments,
    var plkh,
  ) {
    String gioi = plkh["gioi"];
    String bo = plkh["bo"];
    String lop = plkh["lop"];
    String nganh = plkh["nganh"];

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(color: OneColors.black, width: 0.3),
          image: const DecorationImage(
            image: AssetImage(OneImages.ar_background),
            fit: BoxFit.cover,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 5,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.all(Radius.circular(2.5)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                arguments["nameAnimal"],
                style: GoogleFonts.aBeeZee(
                  fontWeight: FontWeight.w700,
                  fontSize: 35,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "( ${arguments["nameAnimalEnglish"]} )",
                style: GoogleFonts.aBeeZee(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: const Color.fromARGB(255, 148, 149, 152),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(children: [_buildPlkh('Giới'), _buildPlkh('Bộ')]),
                const SizedBox(height: 5),
                Row(children: [_buildInfoPlkh(gioi), _buildInfoPlkh(bo)]),
                const SizedBox(height: 20),
                Row(children: [_buildPlkh('Ngành'), _buildPlkh('Lớp')]),
                const SizedBox(height: 5),
                Row(children: [_buildInfoPlkh(nganh), _buildInfoPlkh(lop)]),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: OneColors.black, width: 1),
                ),
                child: Text(
                  arguments["infoAnimal"],
                  style: GoogleFonts.aBeeZee(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Có thể bạn quan tâm',
                style: GoogleFonts.aBeeZee(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Expanded _buildInfoPlkh(String nganh) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: OneColors.black, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                nganh,
                style: GoogleFonts.aBeeZee(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildPlkh(String title) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(title, style: GoogleFonts.aBeeZee(fontSize: 15))],
      ),
    );
  }

  Container _buildImageAnimal(
    BuildContext context,
    var arguments,
    Color colors,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      // color: colors,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(OneImages.ar_background),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Image.asset(
              // imageUrl:
              arguments["imageUrl"],
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
