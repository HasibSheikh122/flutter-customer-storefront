// lib/models/store_models.dart

class StoreBanner {
  final dynamic id;
  final String title;
  final String subtitle;
  final String badgeTitle;
  final String image;
  final String secondaryImage;
  final String bgColor;
  final String? gradientColor1;
  final String? gradientColor2;
  final String buttonText;
  final String targetUrl;

  StoreBanner({
    this.id,
    required this.title,
    this.subtitle = '',
    this.badgeTitle = '',
    this.image = '',
    this.secondaryImage = '',
    this.bgColor = '#090D16',
    this.gradientColor1,
    this.gradientColor2,
    this.buttonText = 'Explore Collection',
    this.targetUrl = '/products',
  });

  factory StoreBanner.fromJson(Map<String, dynamic> json) {
    String parseImg(dynamic val) {
      if (val == null) return '';
      return val.toString();
    }

    return StoreBanner(
      id: json['id'],
      title: json['title']?.toString() ??
          'Elevate Your Everyday Lifestyle & Fashion',
      subtitle: json['subtitle']?.toString() ??
          'Curated premium collections with express nationwide delivery and 100% authenticity guarantee.',
      badgeTitle:
          json['badge_title']?.toString() ?? 'SEASON LAUNCH • UP TO 80% OFF',
      image: parseImg(json['image']),
      secondaryImage: parseImg(json['secondary_image']),
      bgColor: json['bg_color']?.toString() ?? '#090D16',
      gradientColor1: json['gradient_color_1']?.toString(),
      gradientColor2: json['gradient_color_2']?.toString(),
      buttonText: json['button_text']?.toString() ?? 'EXPLORE COLLECTION',
      targetUrl: json['target_url']?.toString() ?? '/products',
    );
  }
}

class StoreCategory {
  final dynamic id;
  final String name;
  final String slug;
  final String icon;

  StoreCategory({
    this.id,
    required this.name,
    required this.slug,
    this.icon = '',
  });

  factory StoreCategory.fromJson(Map<String, dynamic> json) {
    return StoreCategory(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'icon': icon,
      };
}

typedef Category = StoreCategory;

class StoreProduct {
  final dynamic id;
  final String name;
  final String slug;
  final double price;
  final double? regularPrice;
  final String image;
  final String? primaryImage;
  final List<String> galleryImages;
  final String categoryName;
  final String description;
  final String unit;
  final double rating;
  final int totalReviews;
  final int stockQuantity;
  final String? videoUrl;

  StoreProduct({
    required this.id,
    required this.name,
    this.slug = '',
    required this.price,
    this.regularPrice,
    this.image = '',
    String? primaryImage,
    this.galleryImages = const [],
    this.categoryName = '',
    this.description = '',
    this.unit = '1 pc',
    this.rating = 5.0,
    this.totalReviews = 3,
    this.stockQuantity = 20,
    this.videoUrl,
  }) : primaryImage = primaryImage ?? (image.isNotEmpty ? image : null);

  String get imageUrl => primaryImage ?? image;
  String get category => categoryName;
  double get oldPrice => regularPrice ?? (price * 1.15);
  String get formattedPrice => '৳${price.toStringAsFixed(0)}';
  String get formattedOldPrice =>
      regularPrice != null ? '৳${regularPrice!.toStringAsFixed(0)}' : '';
  bool get hasDiscount => regularPrice != null && regularPrice! > price;

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val, [double fallback = 0.0]) {
      if (val == null) return fallback;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? fallback;
    }

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? fallback;
    }

    List<String> extractGallery(Map<String, dynamic> json) {
      final List<String> urls = [];
      void addUrl(dynamic u) {
        if (u != null && u.toString().trim().isNotEmpty) {
          final s = u.toString().trim();
          if (!urls.contains(s)) urls.add(s);
        }
      }

      addUrl(json['primary_image']);
      addUrl(json['primary_image_url']);
      addUrl(json['image']);
      addUrl(json['image_url']);

      if (json['product_images'] is List) {
        for (final item in (json['product_images'] as List)) {
          if (item is Map && item['image'] != null) {
            addUrl(item['image']);
          } else if (item is String) {
            addUrl(item);
          }
        }
      }

      if (json['images'] is List) {
        for (final item in (json['images'] as List)) {
          if (item is Map && item['image'] != null) {
            addUrl(item['image']);
          } else if (item is String) {
            addUrl(item);
          }
        }
      }
      return urls;
    }

    final gallery = extractGallery(json);
    final String mainImg = gallery.isNotEmpty ? gallery.first : '';
    final double parsedPrice = parseDouble(json['price'] ?? json['sale_price']);
    final double? parsedCompare = json['compare_price'] != null ||
            json['regular_price'] != null ||
            json['compare_at_price'] != null
        ? parseDouble(json['compare_price'] ??
            json['regular_price'] ??
            json['compare_at_price'])
        : null;

    return StoreProduct(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      price: parsedPrice,
      regularPrice: parsedCompare,
      image: mainImg,
      primaryImage: mainImg.isNotEmpty ? mainImg : null,
      galleryImages: gallery,
      categoryName: json['category_name']?.toString() ??
          (json['category'] is Map
              ? json['category']['name']?.toString() ?? ''
              : json['category']?.toString() ?? ''),
      description: json['description']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '1 pc',
      rating: parseDouble(json['rating'], 5.0),
      totalReviews: parseInt(json['total_reviews'], 3),
      stockQuantity: parseInt(json['stock_quantity'], 15),
      videoUrl: json['video_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'price': price,
        'regular_price': regularPrice,
        'image': image,
        'primary_image': primaryImage,
        'category_name': categoryName,
        'description': description,
        'unit': unit,
        'rating': rating,
        'total_reviews': totalReviews,
        'stock_quantity': stockQuantity,
      };
}

typedef Product = StoreProduct;

class CartItem {
  final StoreProduct product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'product_name': product.name,
        'quantity': quantity,
        'price': product.price,
      };
}
