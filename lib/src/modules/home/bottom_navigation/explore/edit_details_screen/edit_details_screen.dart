import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/text/text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:banner_app/src/data/services/TemplateEditorScreen.dart';
import 'background/backgroundColor.dart';

class EditingDetailsScreen extends StatefulWidget {
  final String? jsonBackgroundImage;
  final Color? initialBackgroundColor;

  const EditingDetailsScreen(
      {super.key, this.jsonBackgroundImage, this.initialBackgroundColor});

  @override
  EditingDetailsScreenState createState() => EditingDetailsScreenState();
}

class EditingDetailsScreenState extends State<EditingDetailsScreen> {
  final GlobalKey<TemplateEditorScreenState> templateEditorKey =
      GlobalKey<TemplateEditorScreenState>();

  bool showColorOptions = false;
  Color? selectedBackgroundColor;
  String? selectedBackgroundImage;
  bool isColorSelected = false;

  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    // for valid path
    if (widget.jsonBackgroundImage != null &&
        widget.jsonBackgroundImage!.isNotEmpty) {
      selectedBackgroundImage = widget.jsonBackgroundImage;
    }
  }

  void _changeBackground({String? imagePath, Color? color}) {
    setState(() {
      if (imagePath != null) {
        selectedBackgroundImage = imagePath;
        selectedBackgroundColor = null;
        isColorSelected = false;
      } else if (color != null) {
        selectedBackgroundColor = color;
        selectedBackgroundImage = null;
        isColorSelected = true;
      }
    });
  }

// image picker for background
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _changeBackground(imagePath: image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: const Icon(LucideIcons.copyPlus), onPressed: () {}),
            IconButton(icon: const Icon(LucideIcons.undo), onPressed: () {}),
            IconButton(icon: const Icon(LucideIcons.redo), onPressed: () {}),
            TextButton(
              onPressed: () {},
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
                      fontWeight: FontWeight.w600),
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
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TemplateEditorScreen(
                            key: templateEditorKey,
                            backgroundColor: selectedBackgroundColor,
                            jsonImage: selectedBackgroundImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (showColorOptions) _buildBackgroundOptions(),
            _buildBottomOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOptions() {
    final List<Map<String, dynamic>> options = [
      {"icon": LucideIcons.type, "label": "Text"},
      {"icon": LucideIcons.image, "label": "Image"},
      {"icon": LucideIcons.palette, "label": "Background"},
      {"icon": LucideIcons.brush, "label": "Graphics"},
      {"icon": LucideIcons.square, "label": "Shapes"},
      {"icon": LucideIcons.frame, "label": "Frames"},
      {"icon": LucideIcons.text, "label": "Text Arts"},
      {"icon": LucideIcons.folder, "label": "My Arts"},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (options[index]["label"] == "Background") {
                setState(() {
                  showColorOptions = !showColorOptions;
                });
              } else if (options[index]["label"] == "Text") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextEditorScreen(
                      initialText: "add your text",
                      onTextUpdated: (newText, fontFamily) {
                        context.findAncestorWidgetOfExactType<
                            TemplateEditorScreen>();

                        templateEditorKey.currentState
                            ?.addNewText(newText, fontFamily);
                      },
                    ),
                  ),
                );
              } else if (options[index]["label"] == "Image") {
                context.findAncestorWidgetOfExactType<TemplateEditorScreen>();
                templateEditorKey.currentState?.showImageSourceDialog();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(options[index]["icon"], size: 30),
                  const SizedBox(height: 5),
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

  Widget _buildBackgroundOptions() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(3),
      color: AppColor.darkGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Color Picker Button.........................
          GestureDetector(
            onTap: () => showDialog(
                context: context,
                builder: (context) {
                  Color? pickedColor =
                      selectedBackgroundColor ?? Colors.transparent;
                  return AlertDialog(
                    title: const Text("Pick a color"),
                    content: BackgroundEditor(
                      onColorSelected: (Color color) {
                        _changeBackground(color: color);
                        Navigator.pop(context);
                      },
                      initialColor: pickedColor,
                      availableColors: const [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.yellow,
                        Colors.grey,
                        Colors.black,
                      ],
                    ),
                  );
                }),
            child: const Column(
              children: [
                Icon(
                  LucideIcons.palette,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(height: 4),
                Text("Color",
                    style: TextStyle(fontSize: 10, color: Colors.white)),
              ],
            ),
          ),

          // Gallery Pick...................
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: const Column(
              children: [
                Icon(LucideIcons.image, size: 20, color: Colors.white),
                SizedBox(height: 4),
                Text("Gallery",
                    style: TextStyle(fontSize: 10, color: Colors.white)),
              ],
            ),
          ),

          // Camera Pick//...........................
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: const Column(
              children: [
                Icon(LucideIcons.camera, size: 20, color: Colors.white),
                SizedBox(height: 4),
                Text("Camera",
                    style: TextStyle(fontSize: 10, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
