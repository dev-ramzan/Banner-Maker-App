import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:banner_app/src/data/models/category_model.dart';

class CategoryController extends GetxController {
  var categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      String jsonString =
          await rootBundle.loadString("assets/json/banner.json");

      final Map<String, dynamic> parsedData = json.decode(jsonString);

      if (parsedData.containsKey('categories')) {
        categories.value =
            (parsedData['categories'] as List).map((categoryJson) {
          return Category.fromJson(categoryJson);
        }).toList();
      }
    } catch (e) {
      throw ("Error loading JSON file: $e");
    }
  }

  //
  Template? getTemplateById(String templateId) {
    for (var category in categories) {
      for (var template in category.templates) {
        if (template.id == templateId) {
          return template;
        }
      }
    }
    return null;
  }
}
