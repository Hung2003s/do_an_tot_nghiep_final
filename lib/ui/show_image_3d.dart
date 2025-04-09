import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ShowImage3DScreen extends StatefulWidget {
  const ShowImage3DScreen({super.key, required this.image3d});

  final String image3d;

  @override
  State<ShowImage3DScreen> createState() => _ShowImage3DScreenState();
}

class _ShowImage3DScreenState extends State<ShowImage3DScreen> {
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Flutter3DViewer(
            enableTouch: true,
            src: 'assets/image_3d/swimming_shark.glb',
            controller: controller,
          ),
        ),
      ),
    );
  }

  Future<String?> showPickerDialog(List<String> inputList, [String? chosenItem]) async {
    return await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) {
          return SizedBox(
            height: 250,
            child: ListView.separated(
              itemCount: inputList.length,
              padding: const EdgeInsets.only(top: 16),
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, inputList[index]);
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('${index + 1}'), Text(inputList[index]), Icon(chosenItem == inputList[index] ? Icons.check_box : Icons.check_box_outline_blank)],
                    ),
                  ),
                );
              },
              separatorBuilder: (ctx, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 0.6,
                  indent: 10,
                  endIndent: 10,
                );
              },
            ),
          );
        });
  }
}

