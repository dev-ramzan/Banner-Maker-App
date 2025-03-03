import 'package:banner_app/src/core/values/app_color.dart';
import 'package:flutter/material.dart';

class BackgroundEditor extends StatefulWidget {
  final Function(Color) onColorSelected; // Callback function to update color
  final Color initialColor;

  const BackgroundEditor(
      {super.key,
      required this.onColorSelected,
      required this.initialColor,
      required availableColors});

  @override
  _BackgroundEditorState createState() => _BackgroundEditorState();
}

class _BackgroundEditorState extends State<BackgroundEditor> {
  Color _selectedColor = Colors.white; // Default color

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor; // Use initial color from parent
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.black,
      Colors.white
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      height: 60,
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = colors[index];
              });
              widget.onColorSelected(colors[index]); // Update parent screen
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
                border: Border.all(
                    width: 2,
                    color: _selectedColor == colors[index]
                        ? AppColor.darkGreen
                        : Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
