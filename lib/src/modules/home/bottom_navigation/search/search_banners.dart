import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/core/values/constants.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/template/template_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchBanners extends StatefulWidget {
  const SearchBanners({super.key});

  @override
  State<SearchBanners> createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchBanners> {
  final List<String> popularCategoriestitles =
      CategoriesTitle.CategoriesTitleList;
  final List<String> exploreCardTitles = ExploreCategories.exploreCardTitle;
  final List<String> beautifyTitlesCategories1 =
      BeautifyEvents1.beautifyEventsTitles1;
  final List<String> beautifyTitlesCategories2 =
      BeautifyEvents2.beautifyEventsTitles2;

  List<String> allFilteredResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize with all categories
    allFilteredResults = [
      ...popularCategoriestitles,
      ...beautifyTitlesCategories1,
      ...beautifyTitlesCategories2,
      ...exploreCardTitles,
    ];

    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        allFilteredResults = [
          ...popularCategoriestitles,
          ...beautifyTitlesCategories1,
          ...beautifyTitlesCategories2,
          ...exploreCardTitles,
        ];
      });
      return;
    }

    setState(() {
      allFilteredResults = [
        ...popularCategoriestitles
            .where((item) => item.toLowerCase().contains(query.toLowerCase())),
        ...beautifyTitlesCategories1
            .where((item) => item.toLowerCase().contains(query.toLowerCase())),
        ...beautifyTitlesCategories2
            .where((item) => item.toLowerCase().contains(query.toLowerCase())),
        ...exploreCardTitles
            .where((item) => item.toLowerCase().contains(query.toLowerCase())),
      ];
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
              // Search Bar
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
                    onTap: () {
                      _searchController.clear(); // Clears search input
                    },
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

              // Search Results / Default Items
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
