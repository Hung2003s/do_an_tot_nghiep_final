import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ShowImage3DScreen extends StatefulWidget {
  String image3d;
  ShowImage3DScreen({super.key,  required this.image3d});


  @override
  State<ShowImage3DScreen> createState() => _ShowImage3DScreenState();
}

class _ShowImage3DScreenState extends State<ShowImage3DScreen> {
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.onModelLoaded.addListener((){
      debugPrint('model is loaded : ${controller.onModelLoaded.value}');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d2039),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              controller.playAnimation();
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white,),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.pauseAnimation();
              //controller.stopAnimation();
            },
            icon: const Icon(Icons.pause, color: Colors.white,),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.resetAnimation();
            },
            icon: const Icon(Icons.replay, color: Colors.white,),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () async {
              List<String> availableAnimations =
              await controller.getAvailableAnimations();
              debugPrint(
                  'Animations : $availableAnimations --- Length : ${availableAnimations.length}');
              chosenAnimation = await showPickerDialog(
                  'Animations', availableAnimations, chosenAnimation);
              //Play animation with loop count
              controller.playAnimation(
                animationName: chosenAnimation,
              );
            },
            icon: const Icon(Icons.format_list_bulleted_outlined, color: Colors.white,),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () async {
              List<String> availableTextures =
              await controller.getAvailableTextures();
              debugPrint(
                  'Textures : $availableTextures --- Length : ${availableTextures.length}');
              chosenTexture = await showPickerDialog(
                  'Textures', availableTextures, chosenTexture);
              controller.setTexture(textureName: chosenTexture ?? '');
            },
            icon: const Icon(Icons.list_alt_rounded, color: Colors.white,),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.setCameraOrbit(10, 90, 0);
              //controller.setCameraTarget(0.3, 0.2, 0.4);
            },
            icon: const Icon(Icons.zoom_in, color: Colors.white,),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.resetCameraOrbit();
              //controller.resetCameraTarget();
            },
            icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white,),
          ),
          const SizedBox(
            height: 4,
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 35),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey,
          gradient: RadialGradient(
            colors: [
              Color(0xff668f8c),
              Color(0xff3b5967),
            ],
            stops: [0.1, 1.0],
            radius: 0.7,
            center: Alignment.center,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Flutter3DViewer(

                  activeGestureInterceptor: true,

                  progressBarColor: Colors.orange,

                  enableTouch: true,

                  onProgress: (double progressValue) {
                    debugPrint('model loading progress : $progressValue');
                  },

                  onLoad: (String modelAddress) {
                    debugPrint('model loaded : $modelAddress');
                    controller.playAnimation();
                    controller.getAvailableTextures().then((textures) {
                      debugPrint('Available Textures: $textures');
                      if (textures.isNotEmpty) {
                        controller.setTexture(textureName: textures.first); // Thử với texture đầu tiên trong danh sách
                      }
                    });
                    controller.setTexture(textureName: 'assets/image_3d/Main.png');

                  },

                  onError: (String error) {
                    debugPrint('model failed to load : $error');
                  },

                  controller: controller,
                  src:  widget.image3d,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> showPickerDialog(String title, List<String> inputList,
      [String? chosenItem]) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 250,
          child: inputList.isEmpty
              ? Center(
            child: Text('$title list is empty'),
          )
              : ListView.separated(
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
                    children: [
                      Text('${index + 1}'),
                      Text(inputList[index]),
                      Icon(
                        chosenItem == inputList[index]
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      )
                    ],
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
      },
    );
  }
}

