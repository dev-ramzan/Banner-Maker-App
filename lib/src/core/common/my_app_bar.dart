import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/search_items/search_items.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/search/search_banners.dart';
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
      iconTheme: const IconThemeData(color: Colors.white),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchItems(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
