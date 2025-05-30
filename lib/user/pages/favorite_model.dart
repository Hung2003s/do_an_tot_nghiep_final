import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FavoriteAnimalScreen extends StatefulWidget {
  const FavoriteAnimalScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteAnimalScreen> createState() => _FavoriteAnimalScreenState();
}

class _FavoriteAnimalScreenState extends State<FavoriteAnimalScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _parentNumberController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  String? _gender;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _parentNumberController.dispose();
    _parentEmailController.dispose();
    _dobController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveInfo() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Lấy tất cả documents và tìm document phù hợp
    final allUsers = await FirebaseFirestore.instance.collection('user').get();
    final matchingDocs = allUsers.docs
        .where((doc) =>
            doc.data()['Email']?.toString().toLowerCase() ==
            user.email?.toLowerCase())
        .toList();

    if (matchingDocs.isNotEmpty) {
      final matchingDoc = matchingDocs.first;
      // Parse date string to DateTime
      DateTime? dob;
      try {
        dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      } catch (e) {
        print('Error parsing date: $e');
      }

      await FirebaseFirestore.instance
          .collection('user')
          .doc(matchingDoc.id)
          .update({
        'FirstName': _firstNameController.text,
        'LastName': _lastNameController.text,
        'Phone_number': _parentNumberController.text,
        'Email': _parentEmailController.text,
        'Gender': _gender,
        'DateOfBirth': dob != null ? Timestamp.fromDate(dob) : null,
      });
    }
    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isLoading = true;
        });

        // Upload image to Firebase Storage
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(
                  '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

          await storageRef.putFile(_imageFile!);
          final downloadUrl = await storageRef.getDownloadURL();

          // Update avatar URL in Firestore
          final allUsers =
              await FirebaseFirestore.instance.collection('user').get();
          final matchingDocs = allUsers.docs
              .where((doc) =>
                  doc.data()['Email']?.toString().toLowerCase() ==
                  user.email?.toLowerCase())
              .toList();

          if (matchingDocs.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('user')
                .doc(matchingDocs.first.id)
                .update({'avatar': downloadUrl});

            setState(() {
              _avatarController.text = downloadUrl;
            });
          }
        }
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ảnh lên: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _getUserID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userQuery = await FirebaseFirestore.instance.collection('user').get();
    final matchingDocs = userQuery.docs
        .where((doc) =>
            doc.data()['Email']?.toString().toLowerCase() ==
            user.email?.toLowerCase())
        .toList();
    if (matchingDocs.isNotEmpty) {
      return matchingDocs.first.data()['UserID'] ?? '';
    }
    return null;
  }

  Future<bool> _getIsVipUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final userQuery = await FirebaseFirestore.instance.collection('user').get();
    final matchingDocs = userQuery.docs
        .where((doc) =>
            doc.data()['Email']?.toString().toLowerCase() ==
            user.email?.toLowerCase())
        .toList();
    if (matchingDocs.isNotEmpty) {
      return matchingDocs.first.data()['vip'] == true;
    }
    return false;
  }

  Future<List<int>> _getFavoriteAnimalIDs(String userID) async {
    final likeQuery = await FirebaseFirestore.instance
        .collection('like')
        .where('UserID', isEqualTo: userID)
        .get();
    final animalIDs =
        likeQuery.docs.map((doc) => doc['AnimalID'] as int).toList();
    return animalIDs;
  }

  Future<List<Map<String, dynamic>>> _getFavoriteAnimals(
      List<int> animalIDs) async {
    if (animalIDs.isEmpty) return [];
    // Nếu chỉ có 1 animalID, dùng isEqualTo, nếu nhiều hơn 1 dùng whereIn
    QuerySnapshot query;
    if (animalIDs.length == 1) {
      query = await FirebaseFirestore.instance
          .collection('animalDB')
          .where('AnimalID', isEqualTo: animalIDs.first)
          .get();
    } else {
      query = await FirebaseFirestore.instance
          .collection('animalDB')
          .where('AnimalID', whereIn: animalIDs)
          .get();
    }
    return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Động vật yêu thích')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: FutureBuilder<String?>(
            future: _getUserID(),
            builder: (context, userIdSnapshot) {
              if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final userID = userIdSnapshot.data;
              if (userID == null || userID.isEmpty) {
                return const Text('Không tìm thấy UserID');
              }
              return FutureBuilder<bool>(
                future: _getIsVipUser(),
                builder: (context, vipSnapshot) {
                  if (vipSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final isVipUser = vipSnapshot.data ?? false;
                  return FutureBuilder<List<int>>(
                    future: _getFavoriteAnimalIDs(userID),
                    builder: (context, animalIdSnapshot) {
                      if (animalIdSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final animalIDs = animalIdSnapshot.data ?? [];
                      if (animalIDs.isEmpty) {
                        return const Text('Không có động vật yêu thích nào');
                      }
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: _getFavoriteAnimals(animalIDs),
                        builder: (context, animalSnapshot) {
                          if (animalSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final animals = animalSnapshot.data ?? [];
                          if (animals.isEmpty) {
                            return const Text(
                                'Không tìm thấy thông tin động vật.');
                          }
                          return ListView.builder(
                            itemCount: animals.length,
                            itemBuilder: (context, index) {
                              final animal = animals[index];
                              return buildAnimalCard(animal);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: Color(0xff0e0e0e)),
              filled: true,
              fillColor: Color.fromARGB(255, 207, 241, 255),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            ),
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget buildAnimalCard(Map<String, dynamic> animal) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: animal['imageUrl'] != null
                ? CachedNetworkImage(
                    imageUrl: animal['imageUrl'],
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.pets, size: 40),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal['nameAnimal'] ?? '',
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    animal['AnimalID'].toString(),
                    style: TextStyle(fontSize: 12.0, color: Colors.orange[700]),
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.amber, size: 16),
                    const SizedBox(width: 4.0),
                    Text(
                      '${animal["favorcount"] ?? 0}',
                      style: const TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    'Miễn phí',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4.0),
                ],
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Có sẵn',
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
