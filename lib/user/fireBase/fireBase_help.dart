import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getTipsData() async {
  CollectionReference modeldata =
      FirebaseFirestore.instance.collection("tipsDB");
  List<DocumentSnapshot> items = [];
  List<Map<String, dynamic>> dataList = [];

  QuerySnapshot snapshot = await modeldata.get();
  for (var element in snapshot.docs) {
    var mapData = element.data() as Map<String, dynamic>;
    dataList.add(mapData);
  }
  return dataList;
}

Future<List<Map<String, dynamic>>> getEvolutionData() async {
  CollectionReference modeldata =
      FirebaseFirestore.instance.collection("evolutionNews");
  List<DocumentSnapshot> items = [];
  List<Map<String, dynamic>> dataListEvo = [];

  QuerySnapshot snapshot = await modeldata.get();
  for (var element in snapshot.docs) {
    var mapData = element.data() as Map<String, dynamic>;
    dataListEvo.add(mapData);
  }
  return dataListEvo;
}

Future<List<Map<String, dynamic>>> getTrackingImageData() async {
  CollectionReference modeldata =
      FirebaseFirestore.instance.collection("trackingImageDB");
  List<DocumentSnapshot> items = [];
  List<Map<String, dynamic>> dataListImage = [];

  QuerySnapshot snapshot = await modeldata.get();
  for (var element in snapshot.docs) {
    var mapData = element.data() as Map<String, dynamic>;
    dataListImage.add(mapData);
  }
  return dataListImage;
}

Future<List<Map<String, dynamic>>> getAnimalData() async {
  CollectionReference modeldata =
      FirebaseFirestore.instance.collection("animalDB");
  List<DocumentSnapshot> items = [];
  List<Map<String, dynamic>> dataListImage = [];

  QuerySnapshot snapshot = await modeldata.get();
  for (var element in snapshot.docs) {
    var mapData = element.data() as Map<String, dynamic>;
    dataListImage.add(mapData);
  }
  return dataListImage;
}

Future<void> deleteTip(String tipId) async {
  try {
    await FirebaseFirestore.instance.collection("tipsDB").doc(tipId).delete();
  } catch (e) {
    print('Error deleting tip: $e');
    rethrow;
  }
}
