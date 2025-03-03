import 'package:banner_app/src/core/common/my_app_bar.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/core/values/constants.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/template/template_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExploreBanner extends StatefulWidget {
  const ExploreBanner({super.key});

  @override
  State<ExploreBanner> createState() => _ExploreBannerState();
}

class _ExploreBannerState extends State<ExploreBanner> {
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
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        allFilteredResults = [];
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
    return Scaffold(
      appBar: const MyAppBar(
        title: "Banner Maker",
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                  hintText: "Search categories . . . . . .",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColor.darkGreen,
                  ),
                  suffix: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.close, color: AppColor.darkGreen),
                    ),
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

              //  Show only search results if user types something
              if (_searchController.text.isNotEmpty)
                SizedBox(
                  height: 600,
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
                          child: Text("No search results",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ),
                )
              else // here show UI when search not search take place
                const SizedBox(
                  height: 5,
                ),
              //############################################################################
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Popular Categories",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 170,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: PopularCategories.PopularImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplatesScreen(
                              selectedCategory:
                                  CategoriesTitle.CategoriesTitleList[index],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 220,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              image: DecorationImage(
                                  image: AssetImage(
                                    PopularCategories.PopularImages[index],
                                  ),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Container(
                            width: 220,
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColor.darkGreen,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(10)),
                            ),
                            child: Center(
                              child: Text(
                                " ${CategoriesTitle.CategoriesTitleList[index]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              //###########################################################################
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Beautify Your Life Event",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 270, // Adjust height to fit text
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: PopularCategories.PopularImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplatesScreen(
                              selectedCategory:
                                  BeautifyEvents1.beautifyEventsTitles1[index],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // First Image inside a Container
                            Container(
                              width: 100,
                              height: 123, // Increased height to fit text
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                    offset: const Offset(3, 3),
                                  ),
                                ],
                                color: AppColor.darkGreen, // Background color
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100, // Image height
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: AssetImage(PopularCategories
                                            .PopularImages[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  // Space between image and text
                                  Text(
                                    BeautifyEvents1
                                        .beautifyEventsTitles1[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Second Image inside a Container
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TemplatesScreen(
                                      selectedCategory: BeautifyEvents2
                                          .beautifyEventsTitles2[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 123, // Increased height to fit text
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      offset: const Offset(3, 3),
                                    ),
                                  ],
                                  color: AppColor.darkGreen, // Background color
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100, // Image height
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              PopularCategories.PopularImages[
                                                  (index + 1) %
                                                      PopularCategories
                                                          .PopularImages
                                                          .length]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      BeautifyEvents2
                                          .beautifyEventsTitles2[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              //##########################################################################
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Explore More Categories",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // Display search results from ExploreCategories
              SizedBox(
                height: 720,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ExploreCategories.exploreCardTitle.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemplatesScreen(
                                selectedCategory:
                                    ExploreCategories.exploreCardTitle[index],
                              ),
                            ),
                          );
                        },
                        leading: const Icon(Icons.star,
                            size: 30, color: Colors.blue), // Prefix icon
                        title: Text(ExploreCategories.exploreCardTitle[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
