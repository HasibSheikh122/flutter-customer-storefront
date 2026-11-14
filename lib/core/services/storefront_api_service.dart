// lib/core/services/storefront_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/store_env_config.dart';
import '../../models/store_models.dart';

class StorefrontApiService {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tenant-Domain': StoreEnvConfig.storeDomain,
        'X-Tenant-Subdomain': StoreEnvConfig.resolvedSubdomain,
        'X-Subdomain': StoreEnvConfig.resolvedSubdomain,
      };

  Future<Map<String, dynamic>> fetchHomeData() async {
    final String base = StoreEnvConfig.apiBaseUrl;
    final String sub = StoreEnvConfig.resolvedSubdomain;
    final Uri uri = Uri.parse('$base/api/v1/stores/home-data/?subdomain=$sub');

    final res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 12));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final String base = StoreEnvConfig.apiBaseUrl;
    final String sub = StoreEnvConfig.resolvedSubdomain;
    final Uri uri = Uri.parse('$base/api/v1/products/categories/?subdomain=$sub');

    try {
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['results'] is List) {
          list = decoded['results'] as List;
        }
        return list
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchProducts({
    String? categorySlug,
    String? search,
  }) async {
    final String base = StoreEnvConfig.apiBaseUrl;
    final String sub = StoreEnvConfig.resolvedSubdomain;
    final query = <String, String>{'subdomain': sub};
    if (categorySlug != null && categorySlug.isNotEmpty) {
      query['category'] = categorySlug;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final Uri uri =
        Uri.parse('$base/api/v1/products/').replace(queryParameters: query);
    try {
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['results'] is List) {
          list = decoded['results'] as List;
        }
        return list
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> payload) async {
    final String base = StoreEnvConfig.apiBaseUrl;
    final String sub = StoreEnvConfig.resolvedSubdomain;
    final Uri uri = Uri.parse('$base/api/v1/orders/?subdomain=$sub');

    final bodyPayload = <String, dynamic>{
      'subdomain': sub,
      ...payload,
    };

    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(bodyPayload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map) {
        return {'success': true, ...Map<String, dynamic>.from(decoded)};
      }
      return {'success': true};
    }
    throw Exception('অর্ডার সম্পন্ন করা যায়নি (Status ${res.statusCode})');
  }

  static Future<Map<String, dynamic>> placeOrder({
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
    required List<CartItem> items,
  }) async {
    final double total =
        items.fold(0.0, (sum, i) => sum + (i.product.price * i.quantity));
    final payload = <String, dynamic>{
      'customer_name': customerName.trim(),
      'customer_phone': customerPhone.trim(),
      'payment_method': paymentMethod,
      'total': total,
      'shipping_address': {
        'name': customerName.trim(),
        'phone': customerPhone.trim(),
        'address': shippingAddress.trim(),
      },
      'items': items
          .map((i) => {
                'product_id': i.product.id,
                'product_name': i.product.name,
                'quantity': i.quantity,
                'price': i.product.price,
              })
          .toList(),
    };
    return StorefrontApiService().submitOrder(payload);
  }
}
