import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  ThemeController();

  late ThemeMode themeMode = ThemeMode.light; // Initialize with a default value

  Future<void> loadThemeSettings() async {
    update();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    update();
  }
}
