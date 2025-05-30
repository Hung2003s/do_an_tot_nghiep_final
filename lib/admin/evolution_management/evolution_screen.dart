import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/evolution_news_model.dart';
import 'add_evolution_screen.dart';
import 'edit_evolution_screen.dart';

// Widget chính để hiển thị và quản lý danh sách các evolution news
class EvolutionScreenAdmin extends StatefulWidget {
  const EvolutionScreenAdmin({Key? key}) : super(key: key);

  @override
  State<EvolutionScreenAdmin> createState() => _EvolutionScreenAdminState();
}

class _EvolutionScreenAdminState extends State<EvolutionScreenAdmin> {
  // Map lưu trữ vị trí vuốt của từng news (dùng cho animation)
  Map<String, double> _swipeOffsets = <String, double>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tiến hóa'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('evolutionNews').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có thông tin tiến hóa nào'));
          }
          final newsList = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            itemCount: newsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final doc = newsList[index];
              final newsData = doc.data() as Map<String, dynamic>;
              double offset = _swipeOffsets[doc.id] ?? 0;
              return Stack(
                children: [
                  // Nút xóa luôn nằm bên phải, chỉ hiện khi news đã kéo sang trái
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
                                      'Bạn có chắc chắn muốn xóa thông tin tiến hóa này?'),
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
                                  .collection('evolutionNews')
                                  .doc(doc.id)
                                  .delete();
                            }
                          },
                        ),
                      ),
                    ),
                  // News widget có thể trượt sang trái/phải
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
                              builder: (context) => EditEvolutionScreen(
                                newsData: newsData,
                                newsId: doc.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              FutureBuilder<String>(
                                future: getAnimalName(newsData['animal_id']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    );
                                  }
                                  return Text(
                                    snapshot.data ?? '',
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.aBeeZee(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: CachedNetworkImage(
                                  imageUrl: newsData["image"],
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                newsData["news"],
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.aBeeZee(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEvolutionScreen()),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Future<String> getAnimalName(dynamic animalId) async {
    int id;
    if (animalId is int) {
      id = animalId;
    } else {
      id = int.tryParse(animalId.toString()) ?? -1;
    }
    final doc = await FirebaseFirestore.instance
        .collection('animalDB')
        .where('AnimalID', isEqualTo: id)
        .limit(1)
        .get();
    if (doc.docs.isNotEmpty) {
      return doc.docs.first['nameAnimal'] ?? '';
    }
    return '';
  }
}
