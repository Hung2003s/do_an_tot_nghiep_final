import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../user/const/ar_list_color.dart';
import '../../user/fireBase/fireBase_help.dart';
import 'add_tip_screen.dart';
import 'edit_tip_screen.dart';

class Tip {
  final String tipId;
  final String animalId;
  final String imageUrl;
  final String content;

  Tip(
      {required this.tipId,
      required this.animalId,
      required this.imageUrl,
      required this.content});
}

class TipScreen extends StatefulWidget {
  const TipScreen({Key? key}) : super(key: key);

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  List<Map<String, dynamic>> _tipsDataList = [];
  @override
  void initState() {
    super.initState();
    getTipsData().then((tipsData) {
      setState(() {
        _tipsDataList = tipsData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tip'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemCount: _tipsDataList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          Random random = Random();
          var indexRandom = random.nextInt(ColorRamdom.animalColor.length);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTipScreen(
                    tipData: _tipsDataList[index],
                    tipId: '',
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: ColorRamdom.animalColor[indexRandom],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                height: 110,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        _tipsDataList[index]["imageUrl"],
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _tipsDataList[index]["tip"],
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.aBeeZee(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          //   Card(
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          //   elevation: 2,
          //   child: ListTile(
          //     contentPadding: const EdgeInsets.all(12),
          //     leading: Container(
          //       decoration: BoxDecoration(
          //         image: DecorationImage(image: AssetImage(_tipsDataList[index]["imageUrl"])),
          //       ),
          //     ),
          //     title: Text(
          //       'TipID: tipId',
          //       style: const TextStyle(fontWeight: FontWeight.bold),
          //     ),
          //     subtitle: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text('AnimalID: animalId'),
          //         const SizedBox(height: 4),
          //         Text(
          //           _tipsDataList[index]["tip"],
          //           style: const TextStyle(color: Colors.black87),
          //         ),
          //       ],
          //     ),
          //     trailing: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.orange,
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8)),
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //       ),
          //       onPressed: () {},
          //       child: const Text('XÓA', style: TextStyle(color: Colors.white)),
          //     ),
          //   ),
          // );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Get.to(() => const AddTipScreen());
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
