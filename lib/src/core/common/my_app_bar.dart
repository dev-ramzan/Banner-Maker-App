import 'package:banner_app/src/core/values/app_color.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButon;

  const MyAppBar({super.key, required this.title, this.showBackButon = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButon,
      backgroundColor: AppColor.darkGreen,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.start,
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.crown, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
