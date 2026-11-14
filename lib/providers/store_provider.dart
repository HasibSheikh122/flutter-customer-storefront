// lib/providers/store_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/store_env_config.dart';
import '../core/services/storefront_api_service.dart';
import '../models/store_models.dart';

class StoreProvider extends ChangeNotifier {
  final StorefrontApiService _api = StorefrontApiService();

  bool isLoading = true;
  String storeName = StoreEnvConfig.appName;
  String announcementText = StoreEnvConfig.appSlogan;
  String storeLogoUrl = StoreEnvConfig.appIconUrl;
  Color primaryColor = StoreEnvConfig.primaryColor;
  Color secondaryColor = StoreEnvConfig.secondaryColor;

  List<StoreCategory> categories = [];
  List<StoreProduct> products = [];
  List<StoreBanner> heroBanners = [];
  List<CartItem> cart = [];

  String? selectedCategorySlug;
  String searchQuery = '';

  StoreProvider() {
    initializeStore();
  }

  Future<void> initializeStore() async {
    isLoading = true;
    notifyListeners();

    await _loadSavedCart();

    try {
      final homeData = await _api.fetchHomeData();
      if (homeData.isNotEmpty) {
        final Map settingsMap = (homeData['settings'] is Map)
            ? Map.from(homeData['settings'] as Map)
            : {};
        final Map appDistMap = (homeData['app_distribution'] is Map)
            ? Map.from(homeData['app_distribution'] as Map)
            : {};

        final String resolvedName = (appDistMap['app_name'] ??
                settingsMap['store_name'] ??
                homeData['store_name'] ??
                '')
            .toString()
            .trim();
        if (resolvedName.isNotEmpty) {
          storeName = resolvedName;
        }

        final String resolvedAnnouncement = (settingsMap['announcement_text'] ??
                appDistMap['app_slogan'] ??
                homeData['announcement_text'] ??
                '')
            .toString()
            .trim();
        if (resolvedAnnouncement.isNotEmpty) {
          announcementText = resolvedAnnouncement;
        }

        final String resolvedIcon = (appDistMap['app_icon_url'] ??
                settingsMap['store_logo'] ??
                settingsMap['logo'] ??
                homeData['store_logo'] ??
                '')
            .toString()
            .trim();
        if (resolvedIcon.isNotEmpty) {
          storeLogoUrl = resolvedIcon;
        }

        final String resolvedPrimary = (appDistMap['primary_color'] ??
                settingsMap['primary_color'] ??
                homeData['primary_color'] ??
                '')
            .toString()
            .trim();
        if (resolvedPrimary.isNotEmpty) {
          primaryColor = StoreEnvConfig.hexToColor(
            resolvedPrimary,
            fallback: primaryColor,
          );
        }

        final String resolvedSecondary = (appDistMap['secondary_color'] ??
                settingsMap['secondary_color'] ??
                homeData['secondary_color'] ??
                '')
            .toString()
            .trim();
        if (resolvedSecondary.isNotEmpty) {
          secondaryColor = StoreEnvConfig.hexToColor(
            resolvedSecondary,
            fallback: secondaryColor,
          );
        }

        if (homeData['categories'] is List) {
          categories = (homeData['categories'] as List)
              .where((e) => e is Map)
              .map((e) => StoreCategory.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }

        final rawBanners = homeData['hero_banners'] ??
            (homeData['banners'] is Map
                ? homeData['banners']['hero']
                : homeData['banners']);
        if (rawBanners is List) {
          heroBanners = rawBanners
              .where((e) => e is Map)
              .map((e) => StoreBanner.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }

      if (categories.isEmpty) {
        final rawCats = await _api.fetchCategories();
        categories = rawCats
            .map((e) => StoreCategory.fromJson(e))
            .toList();
      }

      await loadProducts();
    } catch (_) {}

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    final rawProducts = await _api.fetchProducts(
      categorySlug: selectedCategorySlug,
      search: searchQuery,
    );
    products = rawProducts
        .map((e) => StoreProduct.fromJson(e))
        .toList();
    notifyListeners();
  }

  void filterByCategory(String? slug) {
    selectedCategorySlug = slug;
    loadProducts();
  }

  void searchProducts(String query) {
    searchQuery = query;
    loadProducts();
  }

  void addToCart(StoreProduct product) {
    final idx = cart.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      cart[idx].quantity += 1;
    } else {
      cart.add(CartItem(product: product, quantity: 1));
    }
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(dynamic productId, int deltaOrQty) {
    final idx = cart.indexWhere((c) => c.product.id == productId);
    if (idx >= 0) {
      final int nextQty = (deltaOrQty == 1 || deltaOrQty == -1)
          ? (cart[idx].quantity + deltaOrQty)
          : deltaOrQty;
      if (nextQty <= 0) {
        cart.removeAt(idx);
      } else {
        cart[idx].quantity = nextQty;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    _saveCart();
    notifyListeners();
  }

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartSubtotal => cart.fold(0.0, (sum, item) => sum + item.total);
  double get cartTotal => cartSubtotal;

  Future<void> _loadSavedCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cart_${StoreEnvConfig.resolvedSubdomain}');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        cart = decoded
            .where((item) => item is Map)
            .map((item) => CartItem(
                  product: StoreProduct.fromJson(
                      Map<String, dynamic>.from((item as Map)['product'] as Map)),
                  quantity: (item['quantity'] is int)
                      ? item['quantity'] as int
                      : int.tryParse(item['quantity'].toString()) ?? 1,
                ))
            .toList();
      } catch (_) {}
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(cart
        .map((c) => {
              'quantity': c.quantity,
              'product': {
                'id': c.product.id,
                'name': c.product.name,
                'slug': c.product.slug,
                'price': c.product.price,
                'regular_price': c.product.regularPrice,
                'primary_image': c.product.imageUrl,
                'category_name': c.product.categoryName,
                'stock_quantity': c.product.stockQuantity,
                'unit': c.product.unit,
              }
            })
        .toList());
    await prefs.setString('cart_${StoreEnvConfig.resolvedSubdomain}', encoded);
  }

  Future<Map<String, dynamic>> checkoutOrder({
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required String city,
    String paymentMethod = 'cod',
  }) async {
    final payload = <String, dynamic>{
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'shipping_address': {
        'fullName': customerName,
        'phone': customerPhone,
        'address': shippingAddress,
        'city': city,
      },
      'payment_method': paymentMethod,
      'total': cartSubtotal,
      'items': cart
          .map((c) => {
                'product_id': c.product.id,
                'product_name': c.product.name,
                'quantity': c.quantity,
                'price': c.product.price,
              })
          .toList(),
    };

    final result = await _api.submitOrder(payload);
    if (result['success'] == true) {
      clearCart();
    }
    return result;
  }
}
