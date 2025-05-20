import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../user/const/ar_list_color.dart';
import '../../user/fireBase/fireBase_help.dart';
import 'add_tip_screen.dart';
import 'edit_tip_screen.dart';

// Class định nghĩa cấu trúc dữ liệu của một Tip
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

// Widget chính để hiển thị và quản lý danh sách các tip
class TipScreen extends StatefulWidget {
  const TipScreen({Key? key}) : super(key: key);

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  // Map lưu trữ vị trí vuốt của từng tip (dùng cho animation)
  Map<String, double> _swipeOffsets = <String, double>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar với tiêu đề và nút quay lại
      appBar: AppBar(
        title: const Text('Quản lý tip'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Danh sách các tip
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tipsDB').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có tip nào'));
          }
          final tips = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            itemCount: tips.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final doc = tips[index];
              final tipData = doc.data() as Map<String, dynamic>;
              double offset = _swipeOffsets[doc.id] ?? 0;
              return Stack(
                children: [
                  // Nút xóa luôn nằm bên phải, chỉ hiện khi tip đã kéo sang trái
                  if (offset < 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 80,
                        height: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.white, size: 28),
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: const Text(
                                      'Bạn có chắc chắn muốn xóa tip này?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Xác nhận'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection('tipsDB')
                                  .doc(doc.id)
                                  .delete();
                              // Không setState, không xóa offset, không remove khỏi UI tạm thời
                            }
                          },
                        ),
                      ),
                    ),
                  // Tip widget có thể trượt sang trái/phải
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        double newOffset =
                            (offset + details.delta.dx).clamp(-80.0, 0.0);
                        if (offset == -80.0 && details.delta.dx > 0) {
                          _swipeOffsets[doc.id] = newOffset;
                        } else if (offset > -80.0) {
                          _swipeOffsets[doc.id] = newOffset;
                        }
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      setState(() {
                        if ((_swipeOffsets[doc.id] ?? 0) < -40) {
                          _swipeOffsets[doc.id] = -80.0;
                        } else {
                          _swipeOffsets[doc.id] = 0.0;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(offset, 0, 0),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.only(right: offset < 0 ? 80 : 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTipScreen(
                                tipData: tipData,
                                tipId: tipData['TipID'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: Offset(-6, 8),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    tipData["imageUrl"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'AnimalID: ${tipData["AnimalID"]}   |   TipID: ${tipData["TipID"]}',
                                        style: GoogleFonts.aBeeZee(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tipData["tip"],
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.justify,
                                        style: GoogleFonts.aBeeZee(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      // Nút thêm tip mới
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTipScreen()),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
