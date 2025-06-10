import 'package:banner_app/src/core/common/my_app_bar.dart';
import 'package:banner_app/src/core/controller/category_controller.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/data/models/category_model.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_screen/edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class TemplatesScreen extends StatefulWidget {
  final String? selectedCategory;
  const TemplatesScreen({super.key, this.selectedCategory});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final CategoryController _categoryController = Get.find();
  String? selectedChip;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Ensure categories are loaded before checking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = getDirectCategories();

      if (widget.selectedCategory != null &&
          categories
              .any((category) => category.title == widget.selectedCategory)) {
        selectedChip = widget.selectedCategory;
      } else if (categories.isNotEmpty) {
        selectedChip = categories.first.title; // Default to first category
      }

      setState(() {}); // Ensure UI updates after setting selectedChip
      scrollToSelectedChip();
    });
  }

  void scrollToSelectedChip() {
    if (selectedChip != null) {
      final index = getDirectCategories()
          .indexWhere((category) => category.title == selectedChip);
      if (index != -1) {
        _scrollController.animateTo(
          index * 100.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Get direct categories  without subcategories logic is blow
  List<Category> getDirectCategories() {
    return _categoryController.categories
        .where((category) => category.subCategories.isEmpty)
        .toList();
  }

  RxList<Template> getTemplatesForSelectedCategory() {
    final allCategories = _categoryController.categories;

    final selectedTemplates = <Template>[].obs;

    if (selectedChip == null) return selectedTemplates;

    // matching title to select categories
    final selectedCategory = allCategories.firstWhere(
      (category) => category.title == selectedChip,
      orElse: () => allCategories.isNotEmpty
          ? allCategories.first
          : Category(title: '', id: '', subCategories: [], templates: []),
    );

    if (selectedCategory.subCategories.isEmpty) {
      selectedTemplates.addAll(selectedCategory.templates);
    }

    return selectedTemplates;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const MyAppBar(
          title: "Templates",
          showBackButon: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //############### Chips for Categories ###############
              Obx(() {
                final directCategories = getDirectCategories();
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    children: directCategories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          checkmarkColor: Colors.white,
                          selectedColor: AppColor.darkGreen,
                          label: Text(
                            category.title,
                            style: TextStyle(
                              color: selectedChip == category.title
                                  ? Colors.white
                                  : AppColor.darkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: selectedChip == category.title,
                          onSelected: (_) => setState(() {
                            selectedChip = category.title;
                          }),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 10),

              //############### Templates Grid ###############

              Expanded(
                child: Obx(() {
                  final selectedTemplates = getTemplatesForSelectedCategory();

                  if (selectedTemplates.isEmpty) {
                    return const Center(
                      child: Text(
                        "No templates found for this category.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: MasonryGridView.builder(
                      gridDelegate:
                          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                      ),
                      itemCount: selectedTemplates.length,
                      itemBuilder: (context, index) {
                        final template = selectedTemplates[index];

                        return GestureDetector(
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
                            margin: const EdgeInsets.only(
                                bottom: 16, top: 5, left: 5, right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                template.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
