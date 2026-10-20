// lib/providers/store_provider.dart
import 'package:flutter/material.dart';
import '../core/config/store_env_config.dart';
import '../core/services/storefront_api_service.dart';
import '../models/store_models.dart';

class StoreProvider extends ChangeNotifier {
  bool isLoading = true;
  String storeName = StoreEnvConfig.compileTimeAppName;
  String announcementText = 'Sign up and GET 20% OFF on your first order!';
  Color primaryColor = StoreEnvConfig.parseHex(StoreEnvConfig.compileTimePrimaryColor);
  Color secondaryColor = StoreEnvConfig.parseHex(
    StoreEnvConfig.compileTimeSecondaryColor,
    fallback: const Color(0xFF047857),
  );

  List<StoreCategoryItem> categories = [];
  List<StoreProduct> products = [];
  final List<CartItem> cart = [];
  String? selectedCategorySlug;

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => cart.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  Future<void> initializeStore() async {
    isLoading = true;
    notifyListeners();
    try {
      final homeData = await StorefrontApiService.fetchHomeData();
      final settings = homeData['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        storeName = (settings['store_name'] ?? storeName).toString();
        announcementText = (settings['announcement_text'] ?? announcementText).toString();
        primaryColor = StoreEnvConfig.parseHex(settings['primary_color']?.toString(), fallback: primaryColor);
        secondaryColor = StoreEnvConfig.parseHex(settings['secondary_color']?.toString(), fallback: secondaryColor);
      }

      if (homeData['categories'] is List) {
        categories = (homeData['categories'] as List)
            .map((c) => StoreCategoryItem.fromJson(c as Map<String, dynamic>))
            .toList();
      }

      products = await StorefrontApiService.fetchProducts();
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> filterByCategory(String? slug) async {
    selectedCategorySlug = slug;
    isLoading = true;
    notifyListeners();
    try {
      products = await StorefrontApiService.fetchProducts(categorySlug: slug);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(StoreProduct product, {int qty = 1}) {
    final idx = cart.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      cart[idx].quantity += qty;
    } else {
      cart.add(CartItem(product: product, quantity: qty));
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int delta) {
    final idx = cart.indexWhere((c) => c.product.id == productId);
    if (idx >= 0) {
      cart[idx].quantity += delta;
      if (cart[idx].quantity <= 0) {
        cart.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }
}
