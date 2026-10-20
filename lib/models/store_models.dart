// lib/models/store_models.dart
class StoreProduct {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double? comparePrice;
  final String? primaryImage;
  final String categoryName;
  final String description;
  final double rating;
  final int stockQuantity;

  StoreProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.comparePrice,
    this.primaryImage,
    required this.categoryName,
    required this.description,
    required this.rating,
    required this.stockQuantity,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['title'] ?? 'Product').toString(),
      slug: (json['slug'] ?? json['id'] ?? '').toString(),
      price: double.tryParse((json['discount_price'] ?? json['sale_price'] ?? json['price'] ?? '0').toString()) ?? 0.0,
      comparePrice: json['compare_price'] != null
          ? double.tryParse(json['compare_price'].toString())
          : null,
      primaryImage: (json['primary_image'] ?? json['image'] ?? json['thumbnail'])?.toString(),
      categoryName: (json['category_name'] ?? 'Featured').toString(),
      description: (json['description'] ?? 'Authentic quality product.').toString(),
      rating: double.tryParse((json['rating'] ?? '4.9').toString()) ?? 4.9,
      stockQuantity: int.tryParse((json['stock_quantity'] ?? json['stock'] ?? '10').toString()) ?? 10,
    );
  }
}

class StoreCategoryItem {
  final int id;
  final String name;
  final String slug;
  final String icon;
  final String? image;

  StoreCategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    this.image,
  });

  factory StoreCategoryItem.fromJson(Map<String, dynamic> json) {
    return StoreCategoryItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? 'Category').toString(),
      slug: (json['slug'] ?? '').toString(),
      icon: (json['icon'] ?? '🛍️').toString(),
      image: json['image']?.toString(),
    );
  }
}

class CartItem {
  final StoreProduct product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
