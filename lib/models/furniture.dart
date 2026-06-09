class FurnitureColor {
  final String name;
  final String hex;

  FurnitureColor({
    required this.name,
    required this.hex,
  });

  factory FurnitureColor.fromJson(Map<String, dynamic> json) {
    return FurnitureColor(
      name: json['name'] as String,
      hex: json['hex'] as String,
    );
  }
}

class Furniture {
  final String id;
  final String name;
  final String category; // 'tables', 'fauteuils', 'lits', 'lampes', 'decorations'
  final int widthCm;
  final int heightCm;
  final int depthCm;
  final String iconEmoji;
  final String description;
  final int price;
  final List<FurnitureColor> colors;
  final String model3DType;
  final String model3DUrl;

  Furniture({
    required this.id,
    required this.name,
    required this.category,
    required this.widthCm,
    required this.heightCm,
    required this.depthCm,
    required this.iconEmoji,
    required this.description,
    required this.price,
    required this.colors,
    required this.model3DType,
    required this.model3DUrl,
  });

  factory Furniture.fromJson(Map<String, dynamic> json) {
    var list = json['colors'] as List? ?? [];
    List<FurnitureColor> colorsList = list.map((i) => FurnitureColor.fromJson(i as Map<String, dynamic>)).toList();

    return Furniture(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      widthCm: json['widthCm'] as int,
      heightCm: json['heightCm'] as int,
      depthCm: json['depthCm'] as int,
      iconEmoji: json['image'] as String? ?? '🛋️',
      description: json['description'] as String,
      price: json['price'] as int,
      colors: colorsList,
      model3DType: json['model3DType'] as String,
      model3DUrl: json['model3DUrl'] as String? ?? '',
    );
  }
}
