import 'dart:io';
import 'package:banner_app/src/core/controller/template_editor_controller.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/text/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget buildElement(BuildContext context, Map<String, dynamic> element,
    TemplateEditorController controller) {
  bool isSelected = controller.selectedElementId.value == element['id'];
  element['rotation'] ??= 0.0;

  Widget child;

  switch (element['type']) {
    case 'text':
      child = _buildTextElement(element, controller, isSelected);
      break;
    case 'image':
      child = _buildImageElement(
        element,
        context,
        controller,
        isSelected,
      );
      break;
    case 'shape':
      child = _buildShapeElement(element, controller, isSelected);
      break;
    default:
      child = Container();
  }

  // Apply rotation if needed
  if (element['rotation'] != 0.0) {
    child = Transform.rotate(
      angle: element['rotation'],
      child: child,
    );
  }

  return Positioned(
    left: element['x'].toDouble(),
    top: element['y'].toDouble(),
    child: GestureDetector(
      onTap: () {
        _handleElementTap(context, element, controller);
        // Prevents double tap from triggering onPanUpdate
      },
      onPanUpdate: (details) =>
          _handleElementMove(element, controller, details),
      behavior: HitTestBehavior.opaque,
      child: child,
    ),
  );
}

void _handleElementTap(BuildContext context, Map<String, dynamic> element,
    TemplateEditorController controller) {
  controller.selectElement(element['id']);

  if (controller.isEditingText.value && element['type'] == 'text') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextEditorScreen(
          initialText: element['value'],
          onTextUpdated: (newText, newFont) {
            controller.updateText(newText, newFont);
          },
        ),
      ),
    ).then((_) {
      controller.isEditingText.value = false;
    });
  }
}

void _handleElementMove(Map<String, dynamic> element,
    TemplateEditorController controller, DragUpdateDetails details) {
  if (controller.selectedElementId.value == element['id']) {
    controller.moveElement(element['id'], details.delta);
  }
}

Widget _buildTextElement(Map<String, dynamic> element,
    TemplateEditorController controller, bool isSelected) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              )
            : null,
        child: isSelected && controller.isEditingText.value
            ? SizedBox(
                width: 200,
                child: TextField(
                  controller: controller.textController,
                  autofocus: true,
                  style: _getTextStyle(element),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (newValue) {
                    controller.updateText(newValue, element['fontfamily']);
                    controller.isEditingText.value = false;
                  },
                ),
              )
            : buildTextWidget(element, controller),
      ),
      ..._buildElementControls(element, controller, isSelected),
    ],
  );
}

Widget _buildImageElement(Map<String, dynamic> element, BuildContext context,
    TemplateEditorController controller, bool isSelected) {
  final isDeleted = element['isDeleted'] ?? false;

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              )
            : null,
        child: isDeleted ? const SizedBox() : _buildImageContent(element),
      ),
      if (isSelected) ...[
        // Delete/Restore button
        Positioned(
          top: -20,
          right: -20,
          child: GestureDetector(
            onTap: () => controller.toggleImageDeleted(element['id']),
            child: _buildControlButton(
              icon: LucideIcons.x,
            ),
          ),
        ),
        // Replace image button
        if (!isDeleted)
          Positioned(
            top: -20,
            left: -20,
            child: GestureDetector(
              onTap: () =>
                  _showImageReplaceDialog(context, element, controller),
              child: _buildControlButton(
                icon: LucideIcons.image,
                tooltip: 'Replace',
              ),
            ),
          ),
        // Resize handle
        Positioned(
          right: -20,
          bottom: -20,
          child: GestureDetector(
            onPanUpdate: (details) {
              switch (element['type']) {
                case 'text':
                  _handleTextResize(element, details, controller);
                  break;
                case 'image':
                  _handleImageResize(element, details, controller);
                  break;
                case 'shape':
                  _handleShapeResize(element, details, controller);
                  break;
              }
            },
            child: _buildControlButton(
              icon: LucideIcons.moveDiagonal2,
              tooltip: 'Resize',
            ),
          ),
        ),
      ],
    ],
  );
}

Color _parseColor(String colorHex) {
  try {
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
  } catch (e) {
    return Colors.black;
  }
}

Widget _buildShapeElement(Map<String, dynamic> element,
    TemplateEditorController controller, bool isSelected) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: element['width']?.toDouble(),
        height: element['height']?.toDouble(),
        decoration: BoxDecoration(
          color: _parseColor(element['color']),
          borderRadius:
              BorderRadius.circular(element['borderRadius']?.toDouble() ?? 0),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
      ),
      ..._buildElementControls(element, controller, isSelected),
    ],
  );
}

Widget _buildImageContent(Map<String, dynamic> element) {
  final src = element['src']?.toString().trim(); // Trim whitespace
  if (src == null || src.isEmpty) {
    return Container(
      width: element['width']?.toDouble(),
      height: element['height']?.toDouble(),
      color: Colors.grey[200], // Fallback color
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  final width = element['width']?.toDouble();
  final height = element['height']?.toDouble();

  if (src.endsWith('.svg')) {
    return SvgPicture.asset(
      src,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  } else if (src.startsWith("/") || src.contains(":\\")) {
    return Image.file(
      File(src),
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  } else {
    return Image.asset(
      src,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

void _showImageReplaceDialog(BuildContext context, Map<String, dynamic> element,
    TemplateEditorController controller) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Replace Image"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, element, controller);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, element, controller);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _pickImage(ImageSource source, Map<String, dynamic> element,
    TemplateEditorController controller) async {
  final image = await ImagePicker().pickImage(source: source);
  if (image != null) {
    controller.updateImageElement(element['id'], image.path);
  }
}

Widget _buildControlButton({
  required IconData icon,
  String? tooltip,
}) {
  final button = Container(
    width: 50,
    height: 50,
    alignment: Alignment.center,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: Colors.grey, size: 23),
    ),
  );

  return tooltip != null ? Tooltip(message: tooltip, child: button) : button;
}

TextStyle _getTextStyle(Map<String, dynamic> element) {
  return TextStyle(
    fontSize: element['fontSize']?.toDouble() ?? 24.0,
    fontFamily: element['fontfamily'] ?? 'Roboto',
    fontWeight:
        element['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
    color: _parseColor(element['color'] ?? "#FF000000"),
  );
}

// 2. _buildElementControls - Builds control buttons for elements
List<Widget> _buildElementControls(Map<String, dynamic> element,
    TemplateEditorController controller, bool isSelected) {
  if (!isSelected) return [];

  return [
    // Delete button
    Positioned(
      left: -20,
      bottom: -20,
      child: GestureDetector(
        onTap: controller.deleteSelectedElement,
        child: _buildControlButton(
          icon: LucideIcons.x,
        ),
      ),
    ),

    // Resize handle
    Positioned(
      right: -20,
      bottom: -20,
      child: GestureDetector(
        onPanStart: (_) {
          _initialFontSize = element['fontSize']?.toDouble() ?? 24.0;
        },
        onPanUpdate: (details) {
          switch (element['type']) {
            case 'text':
              _handleTextResize(element, details, controller);
              break;
            case 'image':
              _handleImageResize(element, details, controller);
              break;
            case 'shape':
              _handleShapeResize(element, details, controller);
              break;
          }
        },
        child: _buildControlButton(
          icon: LucideIcons.moveDiagonal2,
          tooltip: 'Resize',
        ),
      ),
    ),

    // Positioned(
    // left: -20,
    // bottom: -20,
    //   child: GestureDetector(
    //     onPanUpdate: (details) {
    //       // Implement rotation logic here
    //       // controller.rotateElement(element['id'], newRotationValue);
    //     },
    //     child: _buildControlButton(
    //       icon: LucideIcons.rotateCw,
    //     ),
    //   ),
    // ),
  ];
}

void _handleTextResize(Map<String, dynamic> element, DragUpdateDetails details,
    TemplateEditorController controller) {
  if (_initialFontSize == null) return;
  double dy = details.localPosition.dy; // Use localPosition for total drag
  double scaleFactor = 1.0 + (dy * 0.005);
  double newSize = _initialFontSize! * scaleFactor;

  // Apply constraints
  if (newSize >= 8.0 && newSize <= 121.0) {
    controller.updateSelectedTextSize(newSize);
  }
}

double? _initialFontSize;

void _handleImageResize(Map<String, dynamic> element, DragUpdateDetails details,
    TemplateEditorController controller) {
  // Get current dimensions
  double currentWidth = element['width']?.toDouble() ?? 100.0;
  double currentHeight = element['height']?.toDouble() ?? 100.0;

  // Calculate scale based on drag
  double dx = details.delta.dx;
  double scaleFactor = 1.0 + (dx * 0.04); // Reduced sensitivity

  // Calculate new dimensions
  double newWidth = currentWidth * scaleFactor;
  double newHeight = currentHeight * scaleFactor;

  // Add minimum size constraint
  if (newWidth >= 20.0 && newHeight >= 20.0) {
    controller.updateElementSize(
      element['id'],
      newWidth,
      newHeight,
    );
  }
}

void _handleShapeResize(Map<String, dynamic> element, DragUpdateDetails details,
    TemplateEditorController controller) {
  // Get current dimensions
  double currentWidth = element['width']?.toDouble() ?? 100.0;
  double currentHeight = element['height']?.toDouble() ?? 100.0;

  // Calculate scale based on drag
  double dx = details.delta.dx;
  double scaleFactor = 1.0 + (dx * 0.04); // Reduced sensitivity

  // Calculate new dimensions
  double newWidth = currentWidth * scaleFactor;
  double newHeight = currentHeight * scaleFactor;

  // Add minimum size constraint
  if (newWidth >= 20.0 && newHeight >= 20.0) {
    controller.updateElementSize(
      element['id'],
      newWidth,
      newHeight,
    );
  }
}

Widget buildTextWidget(
    Map<String, dynamic> element, TemplateEditorController controller) {
  return Obx(
    () {
      final currentElement = controller.elements.firstWhere(
        (e) => e['id'] == element['id'],
        orElse: () => element,
      );

      final text = currentElement['value'] ?? '';
      final fontSize = currentElement['fontSize']?.toDouble() ?? 24.0;
      final fontFamily = currentElement['fontfamily'] ?? 'Roboto';
      final fontWeight = currentElement['fontWeight'] == 'bold'
          ? FontWeight.bold
          : FontWeight.normal;

      // Handle color and gradient
      final colorHex = currentElement['color'];
      final gradient = currentElement['gradient'];

      if (gradient != null && gradient is LinearGradient) {
        return ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: Text(
            text,
            style: GoogleFonts.getFont(
              fontFamily,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.white,
            ),
          ),
        );
      }

      Color textColor = Colors.black;
      if (colorHex != null && colorHex is String) {
        try {
          textColor =
              Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
        } catch (e) {
          debugPrint('Color parse error: $e');
        }
      }

      return Text(
        text,
        style: GoogleFonts.getFont(
          fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      );
    },
  );
}
