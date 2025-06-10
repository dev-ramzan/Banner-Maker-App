import 'package:banner_app/src/core/controller/template_editor_controller.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class TextEditorScreen extends StatefulWidget {
  final String initialText;
  final Function(String, String) onTextUpdated;
  final VoidCallback? onScreenClosed;
  const TextEditorScreen(
      {super.key,
      required this.initialText,
      required this.onTextUpdated,
      this.onScreenClosed});

  @override
  TextEditorScreenState createState() => TextEditorScreenState();
}

class TextEditorScreenState extends State<TextEditorScreen> {
  late TextEditingController _textController;
  String selectedFont = 'Roboto';
  final FocusNode _focusNode = FocusNode();
  final List<String> fonts = [
    'Roboto',
    'Lobster',
    'Pacifico',
    'Poppins',
    'Montserrat',
    'Oswald',
    'Dancing Script',
    'Raleway',
    'Merriweather',
    'Open Sans',
    'Bebas Neue'
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    final controller = Get.find<TemplateEditorController>();
    controller.shouldResetOnExit.value = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(child: Text("Edit Text")),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onTextUpdated(_textController.text, selectedFont);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.topLeft,
              child: TextField(
                autofocus: true,
                focusNode: _focusNode,
                controller: _textController,
                textAlign: TextAlign.center,
                maxLines: null,
                style: GoogleFonts.getFont(selectedFont, fontSize: 32),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: fonts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFont = fonts[index];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedFont == fonts[index]
                          ? AppColor.darkGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fonts[index],
                      style: GoogleFonts.getFont(fonts[index],
                          fontSize: 20,
                          color: selectedFont == fonts[index]
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
