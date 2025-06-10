import 'package:banner_app/src/core/controller/category_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TemplateEditorController extends GetxController {
  RxBool isNewCustomCanvas = false.obs;
  RxDouble canvasWidth = 650.0.obs;
  RxDouble canvasHeight = 800.0.obs;
  RxString currentTemplateName = ''.obs;
  // State variables to track state
  final elements = <Map<String, dynamic>>[].obs;
  final selectedElementId = ' '.obs;
  var isEditingText = false.obs;
//
  var undoStack = <List<Map<String, dynamic>>>[].obs;
  var redoStack = <List<Map<String, dynamic>>>[].obs;

  var backgroundImagePath = RxString("");
  var selectedBackgroundImage = Rx<String?>(null);
  var selectedBackgroundColor = Rx<Color?>(null);
  var selectedBackgroundGradient = Rxn<LinearGradient>();

  RxBool isColorSelected = false.obs;
  var currentBottomSheet = RxString("");
  final TextEditingController textController = TextEditingController();
  final GlobalKey templatekey = GlobalKey();
  var isImageSaved = false.obs;

  final _originalElements = <Map<String, dynamic>>[].obs;
  final _originalBackgroundPath = RxString("");
  final _originalBackgroundColor = Rx<Color?>(null);
  final _originalBackgroundGradient = Rxn<LinearGradient>();
  final shouldResetOnExit = false.obs;
  final isLoadingDraft = false.obs;
  // Add pixel density handling
  final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;

  Map<String, dynamic> deepCopyMap(Map<String, dynamic> original) {
    final copy = <String, dynamic>{};
    original.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        copy[key] = deepCopyMap(value);
      } else if (value is List) {
        copy[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return deepCopyMap(item);
          } else if (item is Color) {
            return '#${item.value.toRadixString(16).padLeft(8, '0')}';
          }
          return item;
        }).toList();
      } else if (value is Color) {
        copy[key] = '#${value.value.toRadixString(16).padLeft(8, '0')}';
      } else if (value is Gradient) {
        if (value is LinearGradient) {
          copy[key] = {
            'type': 'linear',
            'colors': value.colors
                .map((color) =>
                    '#${color.value.toRadixString(16).padLeft(8, '0')}')
                .toList(),
            'stops': value.stops,
            'begin': {
              'x': (value.begin as Alignment).x,
              'y': (value.begin as Alignment).y,
            },
            'end': {
              'x': (value.end as Alignment).x,
              'y': (value.end as Alignment).y,
            },
          };
        }
      } else {
        copy[key] = value;
      }
    });
    return copy;
  }

  ////////////////////////////////
  ///custom sized and dwfault canvas
  final isLoading = false.obs;

  void loadBlankCanvas({
    required double width,
    required double height,
    required String name,
  }) {
    isLoading.value = true;

    try {
      // Reset state first
      resetCanvasState();

      // Then set new values
      canvasWidth.value = width;
      canvasHeight.value = height;
      currentTemplateName.value = name;
      selectedBackgroundColor.value = Colors.white;
      isNewCustomCanvas = true.obs;
      isDraftLoaded = false;
      elements.refresh();
      update();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset the state
  void resetState() {
    // if (!shouldResetOnExit.value) return;
    elements.value = _originalElements.map((e) => deepCopyMap(e)).toList();
    backgroundImagePath.value = _originalBackgroundPath.value;
    selectedBackgroundColor.value = _originalBackgroundColor.value;
    selectedBackgroundGradient.value = _originalBackgroundGradient.value;

    // Reset flags
    shouldResetOnExit.value = false;
    selectedElementId.value = ' ';
    isEditingText.value = false;
    currentBottomSheet.value = "";
    undoStack.clear();
    redoStack.clear();
    isDraftLoaded = false;
    elements.refresh();
    update();
  }

  void saveOriginalState() {
    _originalElements.value = elements.map((e) => deepCopyMap(e)).toList();
    _originalBackgroundPath.value = backgroundImagePath.value;
    _originalBackgroundColor.value = selectedBackgroundColor.value;
    _originalBackgroundGradient.value = selectedBackgroundGradient.value;
  }

  void prepareForEditing() {
    shouldResetOnExit.value = true;
    saveOriginalState();
  }

// Update the loadTemplate method
  void loadTemplate(String? templateId) {
    if (templateId == null) return;
    final categoryController = Get.find<CategoryController>();
    final template = categoryController.getTemplateById(templateId);

    if (template != null) {
      elements.clear();
      selectedBackgroundImage.value = null;
      selectedBackgroundColor.value = null;
      selectedBackgroundGradient.value = null;

      // Load template data
      elements.value = List<Map<String, dynamic>>.from(template.elements);
      backgroundImagePath.value = template.background;

      elements.refresh();
      update();
    }
  }

  void addNewText(String text, String fontFamily) {
    saveState();
    final newId = 'text_${DateTime.now().millisecondsSinceEpoch}';

    // Get current context for MediaQuery
    final context = templatekey.currentContext;
    if (context == null) return;

    // Calculate width and height using same logic as template
    final width = isDraftLoaded
        ? canvasWidth.value
        : (isNewCustomCanvas.value ? canvasWidth.value : 400.0);

    final height = isDraftLoaded
        ? MediaQuery.of(context).size.width * (600 / 400)
        : (isNewCustomCanvas.value
            ? canvasHeight.value
            : MediaQuery.of(context).size.width * (600 / 450));

    // Calculate font size based on template dimensions
    double smallerDimension = width < height ? width : height;
    double baseFontSize = smallerDimension * 0.04;
    baseFontSize = baseFontSize.clamp(16.0, 48.0);

    // Calculate center position based on actual template dimensions
    double centerX = width / 2;
    double centerY = height / 2;

    // Estimate text width and adjust center position
    double estimatedTextWidth = text.length * (baseFontSize * 0.6);
    centerX -= estimatedTextWidth / 2;
    centerY -= baseFontSize / 2;

    final newTextElement = {
      'id': newId,
      'type': 'text',
      'x': centerX,
      'y': centerY,
      'value': text,
      'fontSize': baseFontSize,
      'color': "#800000",
      'fontWeight': 'normal',
      'fontfamily': fontFamily,
      'alignCenter': true,
    };

    elements.add(newTextElement);
    selectedElementId.value = newId;

    elements.refresh();
    update();
  }

  // Update text
  void updateText(String newValue, String newFont) {
    saveState();
    final index =
        elements.indexWhere((e) => e['id'] == selectedElementId.value);
    if (index != -1) {
      final updatedElement = Map<String, dynamic>.from(elements[index]);
      updatedElement['value'] = newValue;
      updatedElement['fontfamily'] = newFont;

      final newElements = List<Map<String, dynamic>>.from(elements);
      newElements[index] = updatedElement;

      elements.value = newElements;
      selectedElementId.value = updatedElement['id'];
      isEditingText.value = false;
      elements.refresh();
      update();
    }
  }

  void showTextOptionsSheet() {
    currentBottomSheet.value = 'text';
  }

  void showBackgroundOptionsSheet() {
    currentBottomSheet.value = 'background';
  }

  void closeCurrentBottomSheet() {
    currentBottomSheet.value = " ";
  }

  /// Updates the background with a solid color
  void updateBackgroundColor(Color color) {
    selectedBackgroundColor.value = color;
    selectedBackgroundGradient.value = null;
  }

  /// Updates the background with a gradient
  void updateBackgroundGradient(LinearGradient gradient) {
    selectedBackgroundGradient.value = gradient;
    selectedBackgroundColor.value = Colors.transparent;
  }

  //  come with deafult BG then Change background image or color
  void changeBackground(
      {String? imagePath, Color? color, LinearGradient? gradient}) {
    if (imagePath != null) {
      selectedBackgroundImage.value = imagePath;
      selectedBackgroundColor.value = null;
      selectedBackgroundGradient.value = null;
      backgroundImagePath.value = ""; // Clear default background
    } else if (color != null) {
      selectedBackgroundColor.value = color;
      selectedBackgroundImage.value = null;
      selectedBackgroundGradient.value = null;
      backgroundImagePath.value = ""; // Clear default background
    } else if (gradient != null) {
      selectedBackgroundGradient.value = gradient;
      selectedBackgroundColor.value = null;
      selectedBackgroundImage.value = null;
      backgroundImagePath.value = ""; // Clear default background
    }
    update();
  }

  // Pick an image for background
  Future<void> pickBackgroundImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        changeBackground(imagePath: image.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied' || e.code == 'camera_access_denied') {
        _handlePermissionDenied();
      } else {
        Get.snackbar('Error', 'Failed to access images: ${e.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: ${e.toString()}');
    }
  }

  void _handlePermissionDenied() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Please enable photo access in Settings to select background images',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
          ),
        ],
      ),
    );
  }
  ///////////////////////////////////////////////////////////////////////////////////////

  // Duplicate selected element
  void duplicateSelectedElement() {
    final selectedElement = elements.firstWhere(
      (element) => element['id'] == selectedElementId.value,
      orElse: () => {},
    );

    if (selectedElement.isEmpty) return;

    String elementType = selectedElement['type'] ?? 'unknown';
    final newId = '${elementType}_${DateTime.now().millisecondsSinceEpoch}';

    final copiedElement = Map<String, dynamic>.from(selectedElement);
    copiedElement['id'] = newId;
    copiedElement['x'] = (copiedElement['x'] ?? 0) + 20;
    copiedElement['y'] = (copiedElement['y']) ?? 0 + 20;

    elements.add(copiedElement);
    selectedElementId.value = newId;
  }

  // Save template as image
  Future<void> saveTemplateAsImage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final context = templatekey.currentContext;
      if (context == null) throw Exception("Template key context is null");

      final RenderRepaintBoundary boundary =
          context.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception("Failed to convert image to bytes");

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final String fileName =
          'banner_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);
      await GallerySaver.saveImage(filePath);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save template: $e');
    }
    isImageSaved.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isImageSaved.value = false;
    });
  }

// save sate for redo undo
  void saveState() {
    undoStack.add(elements.map((e) => deepCopyMap(e)).toList());
    if (redoStack.isNotEmpty) {
      redoStack.clear();
    }
  }

  // Undo functionality
  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(elements.map((e) => deepCopyMap(e)).toList());
      elements.value =
          undoStack.removeLast().map((e) => deepCopyMap(e)).toList();
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(elements.map((e) => deepCopyMap(e)).toList());
      elements.value =
          redoStack.removeLast().map((e) => deepCopyMap(e)).toList();
    }
  }

////////////////////////////////////////////////

// Check if a text element is selected

  // Add getter for text selection
  bool get isTextSelected {
    return selectedElementId.value.isNotEmpty &&
        elements.any(
            (e) => e['id'] == selectedElementId.value && e['type'] == 'text');
  }

  Map<String, dynamic>? get selectedText {
    if (!isTextSelected) return null;
    return elements.firstWhere(
      (e) => e['id'] == selectedElementId.value,
      orElse: () => {},
    );
  }

  void updateSelectedTextColor(Color color) {
    saveState();
    final index =
        elements.indexWhere((e) => e['id'] == selectedElementId.value);
    if (index == -1) return;

    final element = Map<String, dynamic>.from(elements[index]);
    if (element['type'] == 'text') {
      element['color'] = _colorToHex(color);
      element['gradient'] = null;
      elements[index] = element; // Replace the whole map
      elements.refresh();
      update();
    }
  }

  String _colorToHex(Color color) {
    return "#${color.value.toRadixString(16).padLeft(8, '0')}";
  }

  // Update text gradient
  void updateSelectedTextGradient(Gradient gradient) {
    saveState();
    final index =
        elements.indexWhere((e) => e['id'] == selectedElementId.value);
    if (index == -1) return;

    final element = Map<String, dynamic>.from(elements[index]);
    if (element['type'] == 'text') {
      element['gradient'] = gradient;
      element['color'] = null;
      elements[index] = element;
      elements.refresh();
      update();
    }
  }

  // Update text size
  void updateSelectedTextSize(double newSize) {
    saveState();
    final index =
        elements.indexWhere((e) => e['id'] == selectedElementId.value);
    if (index != -1 && elements[index]['type'] == 'text') {
      final updated = Map<String, dynamic>.from(elements[index]);
      updated['fontSize'] = newSize;
      elements[index] = updated;
      elements.refresh();
      update();
    }
  }

  // Update font family
  void updateSelectedFontFamily(String newFont) {
    saveState();
    final index =
        elements.indexWhere((e) => e['id'] == selectedElementId.value);
    if (index != -1 && elements[index]['type'] == 'text') {
      final updated = Map<String, dynamic>.from(elements[index]);
      updated['fontfamily'] = newFont;
      elements[index] = updated;
      elements.refresh();
      update();
    }
  }

  // Add new image
  void addNewImage(String imagePath) {
    saveState();
    final newId = 'image_${DateTime.now().millisecondsSinceEpoch}';

    // Get current context for MediaQuery
    final context = templatekey.currentContext;
    if (context == null) return;

    // Calculate canvas dimensions using same logic as template
    final canvasWidth = isDraftLoaded
        ? 249.0
        : (isNewCustomCanvas.value ? this.canvasWidth.value : 250.0);

    final canvasHeight = isDraftLoaded
        ? MediaQuery.of(context).size.width * (250 / 250)
        : (isNewCustomCanvas.value
            ? this.canvasHeight.value
            : MediaQuery.of(context).size.width * (250 / 250));

    // Calculate image size based on canvas dimensions
    double smallerDimension =
        canvasWidth < canvasHeight ? canvasWidth : canvasHeight;
    double maxImageWidth = smallerDimension * 0.6; // 60% of smaller dimension
    double maxImageHeight =
        maxImageWidth * (3 / 4); // maintain 4:3 aspect ratio

    // Calculate center position
    double centerX = (canvasWidth - maxImageWidth) / 2;
    double centerY = (canvasHeight - maxImageHeight) / 2;

    elements.add({
      'id': newId,
      'type': 'image',
      'x': centerX,
      'y': centerY,
      'src': imagePath,
      'width': maxImageWidth,
      'height': maxImageHeight,
      'isDeleted': false,
      'aspectRatio': maxImageWidth / maxImageHeight,
    });

    selectedElementId.value = newId;
    update();
  }

  final ImagePicker picker = ImagePicker();

  // Pick image from gallery or camer

  Future<void> pickImageForElement(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        addNewImage(image.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied' || e.code == 'camera_access_denied') {
        _handlePermissionDenied();
      } else {
        Get.snackbar('Error', 'Failed to access images: ${e.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: ${e.toString()}');
    }
  }

  // show Dialogue for custom image from gallery or camera.............
  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Center(child: Text("Select Image Source")),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Get.back(); // Close the dialog
                pickImageForElement(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Get.back(); // Close the dialog
                pickImageForElement(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void deleteSelectedElement() {
    elements.removeWhere((element) => element['id'] == selectedElementId.value);
    selectedElementId.value = " ";
  }

  // Enhanced element manipulation methods
  void moveElement(String id, Offset delta) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(elements[index]);
      updated['x'] = (updated['x'] ?? 0) + delta.dx;
      updated['y'] = (updated['y'] ?? 0) + delta.dy;

      final newElements = List<Map<String, dynamic>>.from(elements);
      newElements[index] = updated;
      elements.value = newElements;

      elements.refresh();
      update();
    }
  }

  void scaleElement(String id, double scale) {
    // saveState();
    try {
      final index = elements.indexWhere((e) => e['id'] == id);
      if (index == -1) throw Exception('Element not found');

      final updated = Map<String, dynamic>.from(elements[index]);

      switch (updated['type']) {
        case 'text':
          double currentSize = (updated['fontSize'] is int)
              ? (updated['fontSize'] as int).toDouble()
              : updated['fontSize']?.toDouble() ?? 24.0;
          double newFontSize = currentSize * scale;
          double minSize = 8.0;
          double maxSize = (canvasWidth.value + canvasHeight.value) * 0.04;
          newFontSize = newFontSize.clamp(minSize, maxSize);
          if ((newFontSize - currentSize).abs() > 0.1) {
            updated['fontSize'] = newFontSize;
          }
          break;
        case 'image':
          final currentWidth = (updated['width'] is int)
              ? (updated['width'] as int).toDouble()
              : updated['width']?.toDouble() ?? 100.0;
          final currentHeight = (updated['height'] is int)
              ? (updated['height'] as int).toDouble()
              : updated['height']?.toDouble() ?? 100.0;
          final aspectRatio = currentWidth / currentHeight;
          double newWidth = currentWidth * scale;
          double newHeight = newWidth / aspectRatio;
          newWidth = newWidth.clamp(20.0, canvasWidth.value * 0.9);
          newHeight = newHeight.clamp(20.0, canvasHeight.value * 0.9);
          updated['width'] = newWidth;
          updated['height'] = newHeight;
          break;
        case 'shape':
          final currentWidth = (updated['width'] is int)
              ? (updated['width'] as int).toDouble()
              : updated['width']?.toDouble() ?? 100.0;
          final currentHeight = (updated['height'] is int)
              ? (updated['height'] as int).toDouble()
              : updated['height']?.toDouble() ?? 100.0;
          double newWidth = currentWidth * scale;
          double newHeight = currentHeight * scale;
          newWidth = newWidth.clamp(20.0, canvasWidth.value * 0.9);
          newHeight = newHeight.clamp(20.0, canvasHeight.value * 0.9);
          updated['width'] = newWidth;
          updated['height'] = newHeight;
          break;
      }

      // Replace the whole list to trigger GetX/reactivity and ensure reset works
      final newElements = List<Map<String, dynamic>>.from(elements);
      newElements[index] = updated;
      elements.value = newElements;

      elements.refresh();
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to scale element: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void rotateElement(String id, double rotation) {
    saveState();
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(elements[index]);
      updated['rotation'] = rotation;

      final newElements = List<Map<String, dynamic>>.from(elements);
      newElements[index] = updated;
      elements.value = newElements;

      elements.refresh();
      update();
    }
  }

  //  image handling
  void updateImageElement(String id, String newPath) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1 && elements[index]['type'] == 'image') {
      saveState();
      final updated = Map<String, dynamic>.from(elements[index]);
      updated['src'] = newPath;
      updated['isDeleted'] = false;

      final newElements = List<Map<String, dynamic>>.from(elements);
      newElements[index] = updated;
      elements.value = newElements;

      elements.refresh();
      update();
    }
  }

  void toggleImageDeleted(String id) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1 && elements[index]['type'] == 'image') {
      saveState();
      final updated = Map<String, dynamic>.from(elements[index]);
      updated['isDeleted'] = !(updated['isDeleted'] ?? false);

      final newElements = List<Map<String, dynamic>>.from(elements);
      newElements[index] = updated;
      elements.value = newElements;

      elements.refresh();
      update();
    }
  }

  // Enhanced element selection
  Map<String, dynamic>? get selectedElement {
    return elements.firstWhereOrNull((e) => e['id'] == selectedElementId.value);
  }

  bool get isImageSelected {
    return selectedElement != null && selectedElement!['type'] == 'image';
  }

  bool get isSelectedImageDeleted {
    return isImageSelected && (selectedElement!['isDeleted'] ?? false);
  }

  void unselectElement() {
    selectedElementId.value = ' ';
    isEditingText.value = false;
    textController.clear();
    currentBottomSheet.value = '';
    elements.refresh();
    update();
  }

  // Enhanced selectElement with rotation reset
  void selectElement(String id) {
    if (selectedElementId.value == id) {
      // Second tap: Handle editing if it's a text element
      final selectedElement = elements.firstWhere(
        (e) => e['id'] == id,
        orElse: () => {},
      );

      if (selectedElement.isEmpty) return;

      if (selectedElement['type'] == 'text') {
        textController.text = selectedElement['value'] ?? '';
        isEditingText.value = true;
      }
    } else {
      // First tap: Select the element
      selectedElementId.value = id;
      isEditingText.value = false;
      textController.clear();

      // Reset rotation handle visibility
      final selectedElement = elements.firstWhere(
        (e) => e['id'] == id,
        orElse: () => {},
      );

      if (selectedElement.isNotEmpty) {
        currentBottomSheet.value = selectedElement['type'] == 'text'
            ? 'text'
            : selectedElement['type'];
      }
      update();
    }
  }

  // Add element at specific position
  void addElementAtPosition(String type, Offset position, {String? imagePath}) {
    saveState();
    final newId = '${type}_${DateTime.now().millisecondsSinceEpoch}';
    final newElement = {
      'id': newId,
      'type': type,
      'x': position.dx,
      'y': position.dy,
      'rotation': 0.0,
    };

    switch (type) {
      case 'text':
        newElement.addAll({
          'value': 'New Text',
          'fontSize': 24.0,
          'color': "#000000",
          'fontWeight': 'normal',
          'fontfamily': 'Roboto',
        });
        break;
      case 'image':
        newElement.addAll({
          'src': imagePath ?? '',
          'width': 100.0,
          'height': 100.0,
          'isDeleted': false,
        });
        break;
      case 'shape':
        newElement.addAll({
          'width': 100.0,
          'height': 100.0,
          'color': "#FF0000FF",
          'borderRadius': 0.0,
        });
        break;
    }

    elements.add(newElement);
    selectedElementId.value = newId;
    update();
  }

// for my project screen
  bool isDraftLoaded = false;
  final drafts = <Map<String, dynamic>>[].obs;

  void loadSavedDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDrafts = prefs.getString('saved_drafts');
    if (savedDrafts != null) {
      final List<dynamic> decoded = json.decode(savedDrafts);
      drafts.value =
          decoded.map((draft) => Map<String, dynamic>.from(draft)).toList();
    }
  }

  void loadDraft(Map<String, dynamic> draft) {
    isLoadingDraft.value = true;
    try {
      // Reset state first but preserve draft flag
      resetCanvasState(keepDraftFlag: true);

      // Load elements
      if (draft['elements'] is List) {
        elements.value = (draft['elements'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        elements.clear();
      }

      const double fixedWidth = 650.0;
      const double fixedHeight = 800.0;
      canvasWidth.value = fixedWidth;
      canvasHeight.value = fixedHeight;

      // Load background image path
      backgroundImagePath.value = draft['backgroundImagePath'] as String? ?? '';

      // Convert hex string back to Color
      if (draft['selectedBackgroundColor'] != null) {
        final colorHex = draft['selectedBackgroundColor'] as String;
        if (colorHex.startsWith('#')) {
          final value = int.parse(colorHex.substring(1), radix: 16);
          selectedBackgroundColor.value = Color(value);
        }
      } else {
        selectedBackgroundColor.value = null;
      }

      // Convert gradient map back to LinearGradient
      if (draft['selectedBackgroundGradient'] != null) {
        final gradientMap =
            draft['selectedBackgroundGradient'] as Map<String, dynamic>;
        final colors = (gradientMap['colors'] as List).map((colorHex) {
          final value = int.parse((colorHex as String).substring(1), radix: 16);
          return Color(value);
        }).toList();

        final stops = (gradientMap['stops'] as List?)?.cast<double>();
        final begin = Alignment(
          gradientMap['begin']['x'] as double,
          gradientMap['begin']['y'] as double,
        );
        final end = Alignment(
          gradientMap['end']['x'] as double,
          gradientMap['end']['y'] as double,
        );

        selectedBackgroundGradient.value = LinearGradient(
          colors: colors,
          stops: stops,
          begin: begin,
          end: end,
        );
      } else {
        selectedBackgroundGradient.value = null;
      }

      currentTemplateName.value = draft['name'] as String? ?? '';

      isDraftLoaded = true;
      elements.refresh();
      update();
    } catch (e) {
      debugPrint('Error loading draft: $e');
      Get.snackbar(
        'Error',
        'Failed to load draft',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDraft.value = false;
    }
  }

  Future<void> saveDraft() async {
    try {
      // Generate thumbnail
      final boundary = templatekey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      String? thumbnailPath;

      try {
        final image = await boundary?.toImage(pixelRatio: 3.0);
        final byteData =
            await image?.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final directory = await getTemporaryDirectory();
          final fileName =
              'draft_thumb_${DateTime.now().millisecondsSinceEpoch}.png';
          thumbnailPath = '${directory.path}/$fileName';
          await File(thumbnailPath).writeAsBytes(pngBytes, flush: true);
        }
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
      }

      // Prepare serializable data
      final serializedElements = elements.map((e) => deepCopyMap(e)).toList();

      final draftData = {
        'elements': serializedElements,
        'backgroundImagePath': backgroundImagePath.value,
        'selectedBackgroundColor': selectedBackgroundColor.value != null
            ? '#${selectedBackgroundColor.value!.value.toRadixString(16).padLeft(8, '0')}'
            : null,
        'selectedBackgroundGradient': selectedBackgroundGradient.value != null
            ? {
                'colors': selectedBackgroundGradient.value!.colors
                    .map((color) =>
                        '#${color.value.toRadixString(16).padLeft(8, '0')}')
                    .toList(),
                'stops': selectedBackgroundGradient.value!.stops,
                'begin': {
                  'x': (selectedBackgroundGradient.value!.begin as Alignment).x,
                  'y': (selectedBackgroundGradient.value!.begin as Alignment).y,
                },
                'end': {
                  'x': (selectedBackgroundGradient.value!.end as Alignment).x,
                  'y': (selectedBackgroundGradient.value!.end as Alignment).y,
                },
              }
            : null,
        'name': currentTemplateName.value,
        'canvasWidth': 650.0,
        'canvasHeight': 800.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'thumbnail': thumbnailPath,
      };

      // Test serialization before adding to drafts
      json.encode(
          draftData); // This will throw an error if data isn't serializable

      // If serialization succeeds, insert at the beginning of drafts
      drafts.insert(0, draftData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_drafts', json.encode(drafts.toList()));

      Get.snackbar(
        'Success',
        'Draft saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      ('Error saving draft: $e');
      Get.snackbar(
        'Error',
        'Failed to save draft: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteDraft(int index) async {
    // Delete thumbnail file if it exists
    final thumbnailPath = drafts[index]['thumbnail'];
    if (thumbnailPath != null) {
      try {
        final file = File(thumbnailPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting thumbnail: $e');
      }
    }

    // Remove draft from list
    drafts.removeAt(index);

    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_drafts', json.encode(drafts.toList()));
  }

  @override
  void onInit() {
    super.onInit();
    loadSavedDrafts();
  }

  // Add this method to your TemplateEditorController class
  void resetCanvasState({bool keepDraftFlag = false}) {
    elements.clear();
    selectedElementId.value = ' ';
    isEditingText.value = false;
    currentBottomSheet.value = '';

    selectedBackgroundColor.value = null;
    selectedBackgroundGradient.value = null;
    selectedBackgroundImage.value = null;
    backgroundImagePath.value = '';

    canvasWidth.value = 0.0;
    canvasHeight.value = 0.0;

    undoStack.clear();
    redoStack.clear();

    // Only reset draft flag if not keeping it
    if (!keepDraftFlag) {
      isDraftLoaded = false;
    }

    isNewCustomCanvas = false.obs;
    update();
  }

  void updateElementSize(String id, double width, double height) {
    final index = elements.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      final element = Map<String, dynamic>.from(elements[index]);
      element['width'] = width;
      element['height'] = height;
      elements[index] = element;
      elements.refresh();
      update();
    }
  }
}
