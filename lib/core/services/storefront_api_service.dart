// lib/core/services/storefront_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/store_env_config.dart';
import '../../models/store_models.dart';

class StorefrontApiService {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tenant-Domain': StoreEnvConfig.compileTimeStoreDomain,
        'X-Tenant-Subdomain': StoreEnvConfig.compileTimeSubdomain,
      };

  static Future<Map<String, dynamic>> fetchHomeData() async {
    final String base = StoreEnvConfig.resolvedBaseUrl;
    final String sub = StoreEnvConfig.compileTimeSubdomain;
    final Uri uri = Uri.parse('$base/api/v1/stores/home-data/?subdomain=$sub');
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  static Future<List<StoreProduct>> fetchProducts({String? categorySlug, String? search}) async {
    final String base = StoreEnvConfig.resolvedBaseUrl;
    final String sub = StoreEnvConfig.compileTimeSubdomain;
    final Map<String, String> query = {'subdomain': sub};
    if (categorySlug != null && categorySlug.isNotEmpty) query['category'] = categorySlug;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final Uri uri = Uri.parse('$base/api/v1/products/').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      List<dynamic> list = [];
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['results'] is List) {
        list = decoded['results'] as List<dynamic>;
      }
      return list.map((e) => StoreProduct.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> placeOrder({
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
    required List<CartItem> items,
  }) async {
    final String base = StoreEnvConfig.resolvedBaseUrl;
    final String sub = StoreEnvConfig.compileTimeSubdomain;
    final Uri uri = Uri.parse('$base/api/v1/orders/?subdomain=$sub');

    final double total = items.fold(0, (sum, i) => sum + (i.product.price * i.quantity));
    final payload = {
      'subdomain': sub,
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

    final res = await http.post(uri, headers: _headers, body: jsonEncode(payload));
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('অর্ডার সম্পন্ন করা যায়নি (Status ${res.statusCode})');
  }
}
