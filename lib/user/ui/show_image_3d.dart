import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ShowImage3DScreen extends StatefulWidget {
  final String image3d;
  const ShowImage3DScreen({super.key, required this.image3d});

  @override
  State<ShowImage3DScreen> createState() => _ShowImage3DScreenState();
}

class _ShowImage3DScreenState extends State<ShowImage3DScreen>
    with AutomaticKeepAliveClientMixin {
  late Flutter3DController controller;
  String? chosenAnimation;
  String? chosenTexture;
  bool _isModelLoaded = false;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = Flutter3DController();
    controller.onModelLoaded.addListener(_onModelLoaded);
  }

  void _onModelLoaded() {
    if (mounted) {
      setState(() {
        _isModelLoaded = true;
        _isLoading = false;
      });
      debugPrint('Model loaded successfully');
    }
  }

  @override
  void dispose() {
    controller.onModelLoaded.removeListener(_onModelLoaded);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xff0d2039),
      floatingActionButton: _isModelLoaded ? _buildControlButtons() : null,
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
          gradient: RadialGradient(
            colors: [
              Color(0xff668f8c),
              Color(0xff3b5967),
            ],
            stops: const [0.1, 1.0],
            radius: 0.7,
            center: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Flutter3DViewer(
                activeGestureInterceptor: true,
                progressBarColor: Colors.orange,
                enableTouch: true,
                onProgress: (double progressValue) {
                  debugPrint('Model loading progress: $progressValue');
                },
                onLoad: (String modelAddress) {
                  debugPrint('Model loaded: $modelAddress');
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  controller.playAnimation();
                  _loadInitialTextures();
                },
                onError: (String error) {
                  debugPrint('Model failed to load: $error');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi tải mô hình: $error')),
                    );
                  }
                },
                controller: controller,
                src: widget.image3d,
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(
          icon: Icons.play_arrow,
          onPressed: () => controller.playAnimation(),
        ),
        _buildControlButton(
          icon: Icons.pause,
          onPressed: () => controller.pauseAnimation(),
        ),
        _buildControlButton(
          icon: Icons.replay,
          onPressed: () => controller.resetAnimation(),
        ),
        _buildControlButton(
          icon: Icons.format_list_bulleted_outlined,
          onPressed: _showAnimationPicker,
        ),
        _buildControlButton(
          icon: Icons.list_alt_rounded,
          onPressed: _showTexturePicker,
        ),
        _buildControlButton(
          icon: Icons.zoom_in,
          onPressed: () => controller.setCameraOrbit(10, 90, 0),
        ),
        _buildControlButton(
          icon: Icons.cameraswitch_outlined,
          onPressed: () => controller.resetCameraOrbit(),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }

  Future<void> _loadInitialTextures() async {
    try {
      final textures = await controller.getAvailableTextures();
      if (textures.isNotEmpty) {
        controller.setTexture(textureName: textures.first);
      }
    } catch (e) {
      debugPrint('Error loading initial textures: $e');
    }
  }

  Future<void> _showAnimationPicker() async {
    try {
      final animations = await controller.getAvailableAnimations();
      if (!mounted) return;

      final selected =
          await showPickerDialog('Animations', animations, chosenAnimation);
      if (selected != null && mounted) {
        setState(() => chosenAnimation = selected);
        controller.playAnimation(animationName: selected);
      }
    } catch (e) {
      debugPrint('Error showing animation picker: $e');
    }
  }

  Future<void> _showTexturePicker() async {
    try {
      final textures = await controller.getAvailableTextures();
      if (!mounted) return;

      final selected =
          await showPickerDialog('Textures', textures, chosenTexture);
      if (selected != null && mounted) {
        setState(() => chosenTexture = selected);
        controller.setTexture(textureName: selected);
      }
    } catch (e) {
      debugPrint('Error showing texture picker: $e');
    }
  }

  Future<String?> showPickerDialog(String title, List<String> inputList,
      [String? chosenItem]) async {
    if (!mounted) return null;

    return await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 250,
          child: inputList.isEmpty
              ? Center(child: Text('$title list is empty'))
              : ListView.separated(
                  itemCount: inputList.length,
                  padding: const EdgeInsets.only(top: 16),
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () => Navigator.pop(context, inputList[index]),
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
