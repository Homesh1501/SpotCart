class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final bool isTodaySpecial;
  final String vendorId;
  final String? description;
  final String category;
  final bool isSoldOut;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.isTodaySpecial = false,
    required this.vendorId,
    this.description,
    this.category = 'Meals',
    this.isSoldOut = false,
  });

  MenuItemModel copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    bool? isTodaySpecial,
    String? vendorId,
    String? description,
    String? category,
    bool? isSoldOut,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isTodaySpecial: isTodaySpecial ?? this.isTodaySpecial,
      vendorId: vendorId ?? this.vendorId,
      description: description ?? this.description,
      category: category ?? this.category,
      isSoldOut: isSoldOut ?? this.isSoldOut,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'isTodaySpecial': isTodaySpecial,
      'vendorId': vendorId,
      'description': description,
      'category': category,
      'isSoldOut': isSoldOut,
    };
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MenuItemModel(
      id: documentId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      isTodaySpecial: map['isTodaySpecial'] ?? false,
      vendorId: map['vendorId'] ?? '',
      description: map['description'],
      category: map['category'] ?? 'Meals',
      isSoldOut: map['isSoldOut'] ?? false,
    );
  }
}
