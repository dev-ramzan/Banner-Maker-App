import 'package:banner_app/src/core/common/my_app_bar.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/core/values/constants.dart';
import 'package:flutter/material.dart';

class TemplatesScreen extends StatefulWidget {
  final String? selectedCategory;
  const TemplatesScreen({super.key, this.selectedCategory});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final List<String> popularCategoriestitles =
      CategoriesTitle.CategoriesTitleList;
  final List<String> exploreCardTitles = ExploreCategories.exploreCardTitle;
  final List<String> beautifyTitlesCategories1 =
      BeautifyEvents1.beautifyEventsTitles1;
  final List<String> beautifyTitlesCategories2 =
      BeautifyEvents2.beautifyEventsTitles2;

  late List<String> allTitles;
  String? selectedChip;
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController
  @override
  void initState() {
    super.initState();
    allTitles = [
      ...popularCategoriestitles,
      ...beautifyTitlesCategories1,
      ...beautifyTitlesCategories2,
      ...exploreCardTitles,
    ];

    // Set the initially selected chip if coming from search
    selectedChip = widget.selectedCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedChip();
    });
  }

  void scrollToSelectedChip() {
    if (selectedChip != null) {
      int index = allTitles.indexOf(selectedChip!);
      if (index != -1) {
        _scrollController.animateTo(
          index * 100.0,
          duration: const Duration(milliseconds: 1),
          curve: Curves.bounceIn,
        );
      }
    }
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
              //####################################### Chips for Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Row(
                  children: allTitles.map((title) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        checkmarkColor: Colors.white,
                        selectedColor: AppColor.darkGreen,
                        label: Text(
                          title,
                          style: TextStyle(
                            color: selectedChip == title
                                ? Colors.white
                                : AppColor.darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: selectedChip == title,
                        onSelected: (_) => setState(() {
                          selectedChip = title;
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              //##################################################################################
              Expanded(
                child: selectedChip != null &&
                        categoryImages.containsKey(selectedChip!)
                    ? GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: categoryImages[selectedChip!]!.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              categoryImages[selectedChip!]![index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No Data found",
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
