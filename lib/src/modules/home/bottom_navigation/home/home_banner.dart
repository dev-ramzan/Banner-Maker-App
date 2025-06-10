import 'package:banner_app/src/core/common/my_app_bar.dart';
import 'package:banner_app/src/core/controller/category_controller.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/data/models/category_model.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_screen/edit_screen.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/template/template_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final CategoryController _categoryController = Get.find();
  List<Category> getCategoriesWithoutSubcategories() {
    return _categoryController.categories
        .where((category) => category.subCategories.isEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesWithoutSubcategories = getCategoriesWithoutSubcategories();
    return SafeArea(
      child: Scaffold(
        appBar: const MyAppBar(title: 'Banner Maker'),
        body: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                // Dynamically Render Categories and Their Template Thumbnails
                ...categoriesWithoutSubcategories.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColor.darkGreen,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TemplatesScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "See More",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w100,
                                color: Colors.cyan,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // handle all  Horizontal List of Template Thumbnails,,
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: category.templates.length + 1,
                          itemBuilder: (context, index) {
                            if (index == category.templates.length) {
                              // extra container after thumbnails
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TemplatesScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 150,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 21, 101, 166),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.cyanAccent),
                                          child: const Icon(
                                            LucideIcons.layers,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        const Text(
                                          "See More",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w200,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Normal template thumbnails
                            final template = category.templates[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditScreen(
                                        imagePath: template.thumbnail,
                                        templateId: template.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        template.thumbnail,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                          height:
                              20), // Spacing between all caregpries categories
                    ],
                  );
                }).toList(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
