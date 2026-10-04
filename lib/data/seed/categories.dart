class Category {
  final String id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

class AppCategories {
  static final List<Category> categories = [
    Category(id: '1', name: 'Jackets', image: 'assets/aw.jpeg'),
    Category(id: '2', name: 'T-Shirts', image: 'assets/aw.jpeg'),
    Category(id: '3', name: 'Pants', image: 'assets/aw.jpeg'),
    Category(id: '4', name: 'Accessories', image: 'assets/aw.jpeg'),
  ];
}
