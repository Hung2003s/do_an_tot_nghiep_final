import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/ar_image.dart';
// import '../const/cache/ar_cache_image.dart';
import '../fireBase/fireBase_help.dart';

class EvolutionScreen extends StatefulWidget {
  const EvolutionScreen({super.key});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> {
  List<Map<String, dynamic>> _evoDataList = [];
  @override
  void initState() {
    super.initState();
    getEvolutionData().then((evoData) async {
      // Lấy danh sách animalDB từ Firestore
      final animalList = await getAnimalListFromFirestore();
      // Map animal_id -> nameAnimal
      final Map<dynamic, String> animalIdToName = {
        for (var animal in animalList) animal['AnimalID']: animal['nameAnimal']
      };
      // Gán tên động vật vào từng bản ghi tiến hóa
      for (var evo in evoData) {
        final animalId = evo['animal_id'];
        evo['name'] = animalIdToName[animalId] ?? 'Không rõ';
      }
      setState(() {
        _evoDataList = evoData;
      });
    });
  }

  // Hàm lấy danh sách animalDB từ Firestore
  Future<List<Map<String, dynamic>>> getAnimalListFromFirestore() async {
    final query = await FirebaseFirestore.instance.collection('animalDB').get();
    return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(OneImages.ar_background), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  _buildListEvo(),
                ]),
            _buildIconBack(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBack() {
    return Padding(
      padding: const EdgeInsets.only(top: 75, left: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildListEvo() {
    return SliverToBoxAdapter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding:
            const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 26),
        itemCount: _evoDataList.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text(
                  _evoDataList[index]["name"],
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.aBeeZee(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    imageUrl: _evoDataList[index]["image"],
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _evoDataList[index]["news"],
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.aBeeZee(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
