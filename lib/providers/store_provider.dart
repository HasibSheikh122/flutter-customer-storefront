// lib/providers/store_provider.dart
import 'package:flutter/material.dart';
import '../core/config/store_env_config.dart';
import '../core/services/storefront_api_service.dart';
import '../models/store_models.dart';

class StoreProvider extends ChangeNotifier {
  bool isLoading = false;
  String storeName = StoreEnvConfig.compileTimeAppName;
  String announcementText = 'Sign up and GET 20% OFF on your first order!';
  Color primaryColor =
      StoreEnvConfig.parseHex(StoreEnvConfig.compileTimePrimaryColor);
  Color secondaryColor =
      StoreEnvConfig.parseHex(StoreEnvConfig.compileTimeSecondaryColor);

  List<StoreBanner> heroBanners = [];
  List<StoreCategory> categories = [];
  List<StoreProduct> products = [];
  String? selectedCategorySlug;

  List<CartItem> cart = [];
  List<CartItem> get cartItems => cart;
  set cartItems(List<CartItem> items) => cart = items;

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      cart.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  Future<void> initializeStore() async {
    isLoading = true;
    notifyListeners();
    try {
      final homeData = await StorefrontApiService.fetchHomeData();
      if (homeData.isNotEmpty) {
        if (homeData['store_name'] != null) {
          storeName = homeData['store_name'];
        }
        if (homeData['primary_color'] != null) {
          primaryColor = StoreEnvConfig.parseHex(homeData['primary_color'],
              fallback: primaryColor);
        }
        if (homeData['secondary_color'] != null) {
          secondaryColor = StoreEnvConfig.parseHex(homeData['secondary_color'],
              fallback: secondaryColor);
        }
        if (homeData['announcement'] != null) {
          announcementText = homeData['announcement'];
        }
        if (homeData['categories'] is List) {
          categories = (homeData['categories'] as List)
              .map((e) => StoreCategory.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        // 🌟 Backend theke hero banner load kora
        if (homeData['banners'] is Map && homeData['banners']['hero'] is List) {
          heroBanners = (homeData['banners']['hero'] as List)
              .map((e) => StoreBanner.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      products = await StorefrontApiService.fetchProducts();
    } catch (e) {
      debugPrint('Initialize store error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String? slug) async {
    selectedCategorySlug = slug;
    isLoading = true;
    notifyListeners();
    try {
      products = await StorefrontApiService.fetchProducts(categorySlug: slug);
    } catch (e) {
      debugPrint('Filter error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    selectedCategorySlug = null;
    isLoading = true;
    notifyListeners();
    try {
      products = await StorefrontApiService.fetchProducts(search: query);
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(StoreProduct product) {
    final index = cart.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      cart[index].quantity += 1;
    } else {
      cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void updateQuantity(dynamic productId, int delta) {
    final index = cart.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final newQty = cart[index].quantity + delta;
      if (newQty <= 0) {
        cart.removeAt(index);
      } else {
        cart[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  void removeFromCart(StoreProduct product) {
    cart.removeWhere((i) => i.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }
}
