import 'package:banner_app/src/core/controller/category_controller.dart';
import 'package:banner_app/src/core/values/app_color.dart';

import 'package:banner_app/src/modules/home/bottom_navigation/explore/template/template_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchItems extends StatefulWidget {
  final VoidCallback onPressed;
  const SearchItems({super.key, required this.onPressed});

  @override
  State<SearchItems> createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> {
  final CategoryController _categoryController = Get.find();

  List<String> allFilteredResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the list with all items when the screen loads
    _initializeAllFilteredResults();
    _searchController.addListener(_filterItems); // Listen for search input
  }

  void _initializeAllFilteredResults() {
    // Populate allFilteredResults with all main category titles
    setState(() {
      allFilteredResults = _categoryController.categories
          .where((category) => category.subCategories.isEmpty)
          .map((category) => category.title)
          .toList();
    });
  }

  void _filterItems() {
    String query = _searchController.text.trim().toLowerCase();

    // If the search query is empty, show all items
    if (query.isEmpty) {
      _initializeAllFilteredResults(); // Reset to show all items
      return;
    }

    // Filter items based on the search query
    var results = _categoryController.categories
        .where((category) =>
            category.subCategories.isEmpty &&
            category.title.toLowerCase().contains(query))
        .map((category) => category.title)
        .toList();

    setState(() {
      allFilteredResults = results;
    });
  }

  void _navigateToTemplateScreen(String selectedTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplatesScreen(selectedCategory: selectedTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Static Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColor.darkGreen),
                  ),
                  hintText: "Search Templates . . . . . .",
                  prefixIcon:
                      const Icon(Icons.search, color: AppColor.darkGreen),
                  suffixIcon: GestureDetector(
                    onTap: widget.onPressed,
                    child: const Icon(Icons.close, color: AppColor.darkGreen),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColor.darkGreen)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                  child: allFilteredResults.isNotEmpty
                      ? ListView.builder(
                          itemCount: allFilteredResults.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 0,
                              borderOnForeground: false,
                              child: ListTile(
                                leading: const Icon(LucideIcons.circle),
                                title: Text(allFilteredResults[index]),
                                onTap: () => _navigateToTemplateScreen(
                                    allFilteredResults[index]),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No search results",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
