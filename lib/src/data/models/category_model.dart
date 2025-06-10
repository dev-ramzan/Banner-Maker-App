class Category {
  final String title;
  final String id;
  final List<SubCategory> subCategories;
  final List<Template> templates;

  Category({
    required this.title,
    required this.id,
    required this.subCategories,
    required this.templates,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'] ?? '',
      id: json['id'] ?? '',
      subCategories: (json['subCategories'] is List)
          ? (json['subCategories'] as List)
              .map((subCategoryJson) => SubCategory.fromJson(subCategoryJson))
              .toList()
          : [],
      templates: (json['templates'] is List)
          ? (json['templates'] as List)
              .map((templateJson) => Template.fromJson(templateJson))
              .toList()
          : [],
    );
  }
}

class SubCategory {
  final String title;
  final String thumbnail;

  SubCategory({
    required this.title,
    required this.thumbnail,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

class Template {
  final String id;
  final String thumbnail;
  final String background;
  final List<Map<String, dynamic>> elements;

  Template({
    required this.id,
    required this.thumbnail,
    required this.background,
    required this.elements,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      background: json['background'] ?? '',
      elements: (json['elements'] is List)
          ? (json['elements'] as List)
              .map((element) => Map<String, dynamic>.from(element))
              .toList()
          : [],
    );
  }
}
