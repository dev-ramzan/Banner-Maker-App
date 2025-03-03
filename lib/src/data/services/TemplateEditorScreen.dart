import 'dart:convert';
import 'dart:io';

import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/text/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TemplateEditorScreen extends StatefulWidget {
  final Color? backgroundColor;
  final String? jsonImage;
  const TemplateEditorScreen(
      {super.key, required this.backgroundColor, required this.jsonImage});
  @override
  TemplateEditorScreenState createState() => TemplateEditorScreenState();
}

class TemplateEditorScreenState extends State<TemplateEditorScreen> {
  List<Map<String, dynamic>> elements = [];
  String? selectedElementId;
  String? profilePicture;
  TextEditingController textController = TextEditingController();
  bool isEditingText = false;
  String? backgroundImagePath;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

// add new custom image code ###################################################
  void addNewImage(String imagePath) {
    final newId1 = 'image_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      elements.add({
        'id': newId1,
        'type': 'image',
        'x': 100.0,
        'y': 150.0,
        'src': imagePath,
        'width': 100.0,
        'height': 150.0,
        'isDeleted': false,
      });

      selectedElementId = newId1;
    });
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageForElement(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      addNewImage(image.path);
    }
  }

  // show Dialogue for custom image from gallery or camera.............
  void showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Add Image")),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  LucideIcons.camera,
                ),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageForElement(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageForElement(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

// add new Custom text........##########################################################
  void addNewText(String text, String fontFamily) {
    final newId = 'text_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      elements.add({
        'id': newId,
        'type': 'text',
        'x': 100.0,
        'y': 150.0,
        'value': text,
        'fontSize': 24.0,
        'color': "#000000",
        'fontWeight': 'normal',
        'fontFamily': fontFamily,
      });

      selectedElementId = newId;
    });
  }

  void _loadTemplate() async {
    try {
      String jsonString =
          await rootBundle.loadString("assets/templates/banner2.json");
      final Map<String, dynamic> parsedData = json.decode(jsonString);

      setState(() {
        if (widget.jsonImage == null) {
          backgroundImagePath = parsedData['background'];
        }
        elements = List<Map<String, dynamic>>.from(parsedData['elements']);
      });
    } catch (e) {
      throw ("Error loading template: $e");
    }
  }

//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  void _selectElement(String id) {
    setState(() {
      if (selectedElementId == id) {
        final selectedElement = elements
            .firstWhere((element) => element['id'] == id, orElse: () => {});
        if (selectedElement.isEmpty) return;

        if (selectedElement['type'] == 'text') {
          textController.text = selectedElement['value'];

          // Navigate to TextEditor
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TextEditorScreen(
                initialText: selectedElement['value'],
                onTextUpdated: (newText, newFont) {
                  _updateText(newText, newFont);
                },
              ),
            ),
          );
        }
      } else {
        selectedElementId = id;
        isEditingText = false;
        textController.clear();
      }
    });
  }

  void _updateText(String newValue, String newFont) {
    setState(() {
      final index =
          elements.indexWhere((element) => element['id'] == selectedElementId);
      if (index != -1) {
        elements[index]['value'] = newValue;
        elements[index]['fontFamily'] = newFont;
      }
    });
  }

  void _deleteSelectedElement() {
    setState(() {
      elements = List.from(elements)
        ..removeWhere((el) => el['id'] == selectedElementId);
      selectedElementId = null;
    });
  }

  Widget _buildElement(Map<String, dynamic> element) {
    bool isSelected = selectedElementId == element['id'];

    switch (element['type']) {
      case 'text':
        return Positioned(
          left: element['x'].toDouble(),
          top: element['y'].toDouble(),
          child: GestureDetector(
            onTap: () {
              _selectElement(element['id']);
            },
            child: Stack(
              clipBehavior: Clip.none, // Allow delete button to overflow
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: isSelected
                      ? BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                        )
                      : null,
                  child: isSelected && isEditingText
                      ? SizedBox(
                          width: 200, // Adjust width if needed
                          child: TextField(
                            controller: textController,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: element['fontSize'].toDouble(),
                              color: Color(int.parse(
                                      element['color'].substring(1, 7),
                                      radix: 16) +
                                  0xFF000000),
                              fontWeight: element['fontWeight'] == 'bold'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (newValue) {
                              _updateText(newValue, newValue);
                              setState(() {
                                isEditingText = false;
                              });
                            },
                          ),
                        )
                      : Text(
                          element['value'],
                          style: GoogleFonts.getFont(
                            element['fontFamily'] ?? 'Roboto',
                            fontSize: element['fontSize'].toDouble(),
                            color: Color(int.parse(
                                    element['color'].substring(1, 7),
                                    radix: 16) +
                                0xFF000000),
                            fontWeight: element['fontWeight'] == 'bold'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                ),

                // Delete button (only when selected)
                if (isSelected)
                  Positioned(
                    top: -15,
                    right: -15,
                    child: InkWell(
                      onTap: () {
                        print(
                            "calledddddd=======================================");
                        _deleteSelectedElement();
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

      case 'image':
        String? src = element['src'];
        bool isSvg = src != null && src.endsWith('.svg');
        bool isDeleted = element['isDeleted'] ?? false;
        bool isFileImage =
            src != null && (src.startsWith("/") || src.contains(":\\"));

        return Positioned(
          left: element['x'].toDouble(),
          top: element['y'].toDouble(),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _selectElement(element['id']);
                },
                child: isDeleted
                    ? const SizedBox()
                    : isSvg
                        ? SvgPicture.asset(
                            element['src'],
                            width: element['width'].toDouble(),
                            height: element['height'].toDouble(),
                            fit: BoxFit.cover,
                          )
                        : isFileImage
                            ? Image.file(
                                File(src),
                                width: element['width'].toDouble(),
                                height: element['height'].toDouble(),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                element['src'],
                                width: element['width'].toDouble(),
                                height: element['height'].toDouble(),
                                fit: BoxFit.cover,
                              ),
              ),

              // Show Delete Icon when the image is selected
              if (isSelected && !isDeleted)
                Positioned(
                  top: 5,
                  left: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        element['isDeleted'] = true;
                        element['src'] = null;
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        );

      case 'shape':
        return Positioned(
          left: element['x'].toDouble(),
          top: element['y'].toDouble(),
          child: GestureDetector(
            onTap: () => _selectElement(element['id']),
            child: Container(
              width: element['width'].toDouble(),
              height: element['height'].toDouble(),
              decoration: BoxDecoration(
                color: Color(
                    int.parse(element['color'].substring(1, 7), radix: 16) +
                        0xFF000000),
                borderRadius:
                    BorderRadius.circular(element['borderRadius'].toDouble()),
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
              ),
            ),
          ),
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // for background color

          if (widget.backgroundColor != null)
            Positioned.fill(
              child: Container(color: widget.backgroundColor),
            ),

          // for  defaulf background
          if (backgroundImagePath != null &&
              widget.backgroundColor == null &&
              (widget.jsonImage == null || widget.jsonImage!.isEmpty))
            Positioned.fill(
              child: Image.asset(backgroundImagePath!, fit: BoxFit.cover),
            ),

          // Background Image which is user select fr
          if (widget.jsonImage != null &&
              widget.jsonImage!.isNotEmpty &&
              widget.backgroundColor == null)
            Positioned.fill(
              child: Image.file(
                File(widget.jsonImage!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey.shade200);
                },
              ),
            ),

          ...elements.map((e) => _buildElement(e)),
        ],
      ),
    );
  }
}
// fixed code here
