import 'package:banner_app/src/core/controller/customController.dart';
import 'package:banner_app/src/core/controller/template_editor_controller.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/edit_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CreateBannerScreen extends StatelessWidget {
  final CustomController _controller = Get.put(CustomController());
  final TemplateEditorController editorController =
      Get.put(TemplateEditorController());

  CreateBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Template Size',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 1, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MasonryGridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 12,
                itemCount: _controller.aspectRatios.length,
                itemBuilder: (context, index) {
                  final ratio = _controller.aspectRatios[index];
                  return _TemplateSizeCard(
                    ratio: ratio,
                    onTap: () => _handleSizeSelection(ratio),
                  );
                },
              ),
            ),
            Obx(() {
              if (!_controller.showCustomFields.value) {
                return const SizedBox.shrink();
              }
              return _CustomSizeControls();
            }),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _handleSizeSelection(Map<String, dynamic> ratio) {
    if (ratio['name'] == 'Custom Size') {
      _controller.showCustomFields.value = true;
    } else {
      _controller.showCustomFields.value = false;
      editorController.isNewCustomCanvas.value = true;
      _controller.selectRatio(ratio);
      _navigateToEditor();
    }
    editorController.isNewCustomCanvas.value = false;
  }

  void _navigateToEditor() {
    editorController.resetState();
    editorController.prepareForEditing();

    Get.to(() => EditingDetailsScreen(), transition: Transition.rightToLeft);
  }
}

class _TemplateSizeCard extends GetView<CustomController> {
  final Map<String, dynamic> ratio;
  final VoidCallback onTap;

  const _TemplateSizeCard({required this.ratio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Image container
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2 - 24,
                ),
                child: ratio['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          ratio['image'],
                          fit: BoxFit.contain,
                        ),
                      )
                    : Container(
                        height: (ratio['height'] / ratio['width']) *
                            (MediaQuery.of(context).size.width / 2 - 24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                      ),
              ),

              // Template Name Position
              Obx(() {
                final namePos = ratio['namePosition'] as Map<String, dynamic>;
                return Positioned(
                  left: (namePos['x'] as RxDouble).value,
                  top: (namePos['y'] as RxDouble).value,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      controller.updatePosition(
                        ratio['name'],
                        true,
                        (namePos['x'] as RxDouble).value + details.delta.dx,
                        (namePos['y'] as RxDouble).value + details.delta.dy,
                      );
                    },
                    child: Text(
                      ratio['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Ratio Position
              Obx(() {
                final ratioPos = ratio['ratioPosition'] as Map<String, dynamic>;
                return Positioned(
                  left: (ratioPos['x'] as RxDouble).value,
                  top: (ratioPos['y'] as RxDouble).value,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      controller.updatePosition(
                        ratio['name'],
                        false,
                        (ratioPos['x'] as RxDouble).value + details.delta.dx,
                        (ratioPos['y'] as RxDouble).value + details.delta.dy,
                      );
                    },
                    child: Text(
                      '${ratio['width']}:${ratio['height']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CustomSizeControls extends GetView<CustomController> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  _CustomSizeControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showCustomFields.value) return const SizedBox.shrink();

      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: MediaQuery.of(context).size.width * .91,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Custom Dimensions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          controller.showCustomFields.value = false,
                      icon: const Icon(Icons.close, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Width (px)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.width_normal_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Height (px)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.height_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            controller.showCustomFields.value = false,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColor.darkGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final width =
                              double.tryParse(_widthController.text) ?? 0;
                          final height =
                              double.tryParse(_heightController.text) ?? 0;

                          if (width > 0 && height > 0) {
                            controller.updateCustomSize(width, height);
                            controller.showCustomFields.value = true;
                            Get.to(() => EditingDetailsScreen(),
                                transition: Transition.rightToLeft);
                          }
                        },
                        child: const Text(
                          'Create Design',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    });
  }
}
