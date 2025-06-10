import 'dart:async';
import 'package:banner_app/src/core/controller/customController.dart';
import 'package:banner_app/src/core/controller/template_editor_controller.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/helper/editing_details_helper.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/text/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/helper/build_element.dart';
import 'dart:math' as math;

class EditingDetailsScreen extends StatefulWidget {
  final String? templateId;
  const EditingDetailsScreen({
    super.key,
    this.templateId,
  });

  @override
  State<EditingDetailsScreen> createState() => _EditingDetailsScreenState();
}

class _EditingDetailsScreenState extends State<EditingDetailsScreen> {
  late final TemplateEditorController controller;
  late final CustomController customController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TemplateEditorController>();
    customController = Get.find<CustomController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isLoadingDraft.value) {
        // Don't reset if loading a draft
        controller.prepareForEditing();
      } else if (controller.isDraftLoaded) {
        // Don't reset if draft is already loaded
        controller.prepareForEditing();
      } else if (widget.templateId == null) {
        // Reset and load blank canvas
        controller.resetCanvasState();
        controller.loadBlankCanvas(
          width: customController.containerWidth.value,
          height: customController.containerHeight.value,
          name: '',
        );
        controller.prepareForEditing();
      } else {
        // Loading a template
        controller.resetCanvasState();
        controller.loadTemplate(widget.templateId);
        controller.prepareForEditing();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPop(context, controller),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.copyPlus),
                onPressed: () => controller.duplicateSelectedElement(),
              ),
              IconButton(
                icon: const Icon(LucideIcons.undo),
                onPressed: () => controller.undo(),
              ),
              IconButton(
                icon: const Icon(LucideIcons.redo),
                onPressed: () => controller.redo(),
              ),
              TextButton(
                onPressed: () async {
                  await controller.saveTemplateAsImage();
                  controller.isImageSaved.value = true;
                  Future.delayed(const Duration(seconds: 2), () {
                    controller.isImageSaved.value = false;
                  });
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            elevation: 0,
            backgroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Container(color: Colors.grey.shade300, height: 2),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: Obx(() {
                          if (controller.isLoading.value ||
                              controller.isLoadingDraft.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.darkGreen),
                              ),
                            );
                          }

                          // Use loaded draft dimensions if available
                          final width = controller.isDraftLoaded
                              ? controller.canvasWidth.value
                              : (widget.templateId != null
                                  ? 650.0
                                  : controller.canvasWidth.value);

                          final height = controller.isDraftLoaded
                              ? MediaQuery.of(context).size.width * (800 / 650)
                              : (widget.templateId != null
                                  ? MediaQuery.of(context).size.width *
                                      (800 / 650)
                                  : controller.canvasHeight.value);

                          final scale =
                              _calculateScaleFactor(context, width, height);

                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: RepaintBoundary(
                                key: controller.templatekey,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.unselectElement(),
                                        child: Obx(
                                            () => _buildBackground(controller)),
                                      ),
                                    ),

                                    // Elements
                                    Obx(() => Stack(
                                          children: controller.elements
                                              .map((e) => buildElement(
                                                  context, e, controller))
                                              .toList(),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBottomOptions(controller),
                ],
              ),

              // Display the current bottom sheet
              Obx(() {
                if (controller.currentBottomSheet.value.isNotEmpty) {
                  return Positioned(
                    bottom: 71,
                    left: 0,
                    right: 0,
                    child: _buildCurrentBottomSheet(context, controller),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Image success message
              Obx(() {
                if (controller.isImageSaved.value) {
                  return Center(
                    child: AnimatedOpacity(
                      opacity: controller.isImageSaved.value ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColor.darkGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.checkCircle,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Image saved successfully!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

// bakcgrounds options
  Widget _buildBackground(TemplateEditorController controller) {
    Widget backgroundContent;

    // User selected gradient
    if (controller.selectedBackgroundGradient.value != null) {
      backgroundContent = Container(
        decoration: BoxDecoration(
          gradient: controller.selectedBackgroundGradient.value,
        ),
      );
    }
    // User selected color
    else if (controller.selectedBackgroundColor.value != null) {
      backgroundContent = Container(
        color: controller.selectedBackgroundColor.value,
      );
    }
    // User selected image
    else if (controller.selectedBackgroundImage.value != null) {
      backgroundContent = Image.file(
        File(controller.selectedBackgroundImage.value!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey.shade200);
        },
      );
    }
    // Default JSON image
    else if (controller.backgroundImagePath.value.isNotEmpty) {
      backgroundContent = Image.asset(
        controller.backgroundImagePath.value,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey.shade200);
        },
      );
    }
    // Fallback
    else {
      backgroundContent = Container(color: Colors.grey.shade200);
    }

    return SizedBox.expand(child: backgroundContent);
  }

// calculate screen size
  double _calculateScaleFactor(
      BuildContext context, double width, double height) {
    final containerHeight = MediaQuery.of(context).size.width * (800 / 650);
    final containerWidth = MediaQuery.of(context).size.width;

    if (widget.templateId != null || controller.isDraftLoaded) {
      return 1.0;
    } else {
      // For custom sizes, calculate the scale factor
      final widthRatio = containerWidth / width;
      final heightRatio = containerHeight / height;
      return math.min(widthRatio, heightRatio);
    }
  }

// all text options
  Widget _buildTextOptionsSheet(TemplateEditorController controller) {
    final isTextSelected = controller.isTextSelected;

    return Container(
      height: 55,
      width: Get.width,
      decoration: const BoxDecoration(
        color: AppColor.darkGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Add New Text
                buildTextOptionButton(
                  icon: LucideIcons.plus,
                  label: "Add",
                  onTap: () {
                    controller.shouldResetOnExit.value = false;
                    Get.to(
                        () => TextEditorScreen(
                              initialText: "Add your text",
                              onTextUpdated: (newText, fontFamily) {
                                controller.addNewText(newText, fontFamily);
                              },
                            ),
                        preventDuplicates: false);
                  },
                ),

                if (isTextSelected) ...[
                  // Edit Text
                  buildTextOptionButton(
                    icon: LucideIcons.edit,
                    label: "Edit",
                    onTap: () {
                      final selectedText = controller.selectedText;
                      if (selectedText != null) {
                        controller.shouldResetOnExit.value = false;
                        Get.to(
                          () => TextEditorScreen(
                            initialText: selectedText['value'] ?? "",
                            onTextUpdated: (newText, newFont) {
                              controller.updateText(newText, newFont);
                            },
                          ),
                          preventDuplicates: false,
                        );
                      }
                    },
                  ),

                  // Text Color Picker
                  buildTextOptionButton(
                    icon: LucideIcons.palette,
                    label: "Color",
                    onTap: () {
                      showModalBottomSheet(
                        context: Get.context!,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return TextColorPickerBottomSheet(
                            onBackgroundSelected: (
                                {Color? color, LinearGradient? gradient}) {
                              if (color != null) {
                                controller.updateSelectedTextColor(color);
                              } else if (gradient != null) {
                                controller.updateSelectedTextGradient(gradient);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),

                  // Change Font Size
                  buildTextOptionButton(
                    icon: LucideIcons.text,
                    label: "Size",
                    onTap: () {
                      showFontSizeSlider(Get.context!, controller);
                    },
                  ),

                  // Change Font Family
                  buildTextOptionButton(
                    icon: LucideIcons.type,
                    label: "Font",
                    onTap: () {
                      showFontFamilyPicker(
                        Get.context!,
                      );
                    },
                  ),

                  // Close Button
                  buildTextOptionButton(
                    icon: LucideIcons.x,
                    label: "Close",
                    onTap: () => controller.closeCurrentBottomSheet(),
                  ),
                ],
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBottomSheet(
      BuildContext context, TemplateEditorController controller) {
    switch (controller.currentBottomSheet.value) {
      case 'text':
        return _buildTextOptionsSheet(controller);
      case 'background':
        return _buildBackgroundOptionsSheet(context, controller);
      default:
        return Container();
    }
  }

//foooooooooooooooooooooffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  Widget _buildBackgroundOptionsSheet(
      BuildContext context, TemplateEditorController controller) {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: AppColor.darkGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Color Picker
              buildTextOptionButton(
                icon: LucideIcons.palette,
                label: "Color",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return BgColorPickerBottomSheet(
                        onBackgroundSelected: (
                            {Color? color, LinearGradient? gradient}) {
                          if (color != null) {
                            controller.changeBackground(color: color);
                          } else if (gradient != null) {
                            controller.changeBackground(gradient: gradient);
                          }
                        },
                      );
                    },
                  );
                },
              ),

              // Gallery Pick
              buildTextOptionButton(
                icon: LucideIcons.image,
                label: "Gallery",
                onTap: () =>
                    controller.pickBackgroundImage(ImageSource.gallery),
              ),

              // Camera Pick
              buildTextOptionButton(
                icon: LucideIcons.camera,
                label: "Camera",
                onTap: () => controller.pickBackgroundImage(ImageSource.camera),
              ),

              // Close Button
              buildTextOptionButton(
                icon: Icons.close,
                label: "Close",
                onTap: () => controller.closeCurrentBottomSheet(),
              ),
            ],
          ),
        ],
      ),
    );
  }

// bottom sheet for editing detail screeen
  Widget _buildBottomOptions(TemplateEditorController controller) {
    final List<Map<String, dynamic>> options = [
      {"icon": LucideIcons.type, "label": "Text"},
      {"icon": LucideIcons.image, "label": "Image"},
      {"icon": LucideIcons.palette, "label": "Background"},
      // {"icon": LucideIcons.brush, "label": "Graphics"},
      // {"icon": LucideIcons.square, "label": "Shapes"},
      // {"icon": LucideIcons.frame, "label": "Frames"},
      // {"icon": LucideIcons.text, "label": "Text Arts"},
      // {"icon": LucideIcons.folder, "label": "My Arts"},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300))),
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              switch (options[index]["label"]) {
                case "Text":
                  controller.showTextOptionsSheet();
                  break;
                case "Image":
                  controller.showImageSourceDialog();
                  break;
                case "Background":
                  controller.showBackgroundOptionsSheet();
                  controller.currentBottomSheet;
                  break;
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(options[index]["icon"], size: 25),
                  const SizedBox(height: 3),
                  Text(options[index]["label"],
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
