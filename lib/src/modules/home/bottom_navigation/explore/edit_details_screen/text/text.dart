import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextEditorScreen extends StatefulWidget {
  final String initialText;
  final Function(String, String) onTextUpdated;

  const TextEditorScreen({
    super.key,
    required this.initialText,
    required this.onTextUpdated,
  });

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
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          ? Colors.blueAccent.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fonts[index],
                      style: GoogleFonts.getFont(fonts[index], fontSize: 24),
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
