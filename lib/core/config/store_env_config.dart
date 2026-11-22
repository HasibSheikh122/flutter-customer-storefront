// lib/core/config/store_env_config.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class StoreEnvConfig {
  static const String _envStoreDomain = String.fromEnvironment(
    'STORE_DOMAIN',
    defaultValue: '',
  );

  static const String _envTenantSubdomain = String.fromEnvironment(
    'TENANT_SUBDOMAIN',
    defaultValue: '',
  );

  static const String _envAppName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: '',
  );

  static const String _envAppSlogan = String.fromEnvironment(
    'APP_SLOGAN',
    defaultValue: '',
  );

  static const String _envAppIconUrl = String.fromEnvironment(
    'APP_ICON_URL',
    defaultValue: '',
  );

  static const String _envPrimaryColorHex = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '',
  );

  static const String _envSecondaryColorHex = String.fromEnvironment(
    'SECONDARY_COLOR',
    defaultValue: '',
  );

  static const String _envBundleId = String.fromEnvironment(
    'BUNDLE_ID',
    defaultValue: '',
  );

  static Map<String, dynamic> _embedded = {};

  /// Loads assets/tenant_config.json injected by GitHub Actions at build time.
  static Future<void> loadEmbeddedConfig() async {
    for (final path in ['assets/tenant_config.json', 'tenant_config.json']) {
      try {
        final raw = await rootBundle.loadString(path);
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _embedded = Map<String, dynamic>.from(decoded);
          return;
        }
      } catch (_) {}
    }
  }

  static String _pick(String envVal, String jsonKey, String fallback) {
    if (envVal.trim().isNotEmpty) return envVal.trim();
    final jv = (_embedded[jsonKey] ?? '').toString().trim();
    if (jv.isNotEmpty) return jv;
    return fallback;
  }

  static String get storeDomain => _pick(_envStoreDomain, 'store_domain', 'shop.xylotechsolution.com');
  static String get tenantSubdomain => _pick(_envTenantSubdomain, 'subdomain', '');
  static String get appName => _pick(_envAppName, 'app_name', 'Online Store');
  static String get appSlogan => _pick(_envAppSlogan, 'app_slogan', 'Authentic Online Shopping');
  static String get appIconUrl => _pick(_envAppIconUrl, 'app_icon_url', '');
  static String get appIconBase64 => (_embedded['app_icon_base64'] ?? '').toString().trim();
  static String get primaryColorHex => _pick(_envPrimaryColorHex, 'primary_color', '#059669');
  static String get secondaryColorHex => _pick(_envSecondaryColorHex, 'secondary_color', '#047857');
  static String get bundleId => _pick(_envBundleId, 'bundle_id', 'com.xylosaas.store');

  static String get compileTimeStoreDomain => storeDomain;
  static String get compileTimeSubdomain => tenantSubdomain;
  static String get resolvedBaseUrl => apiBaseUrl;

  static String get cleanHost {
    String h = storeDomain.trim().toLowerCase();
    h = h.replaceAll('https://', '').replaceAll('http://', '');
    if (h.contains('/')) h = h.split('/').first;
    return h;
  }

  static String get resolvedSubdomain {
    if (tenantSubdomain.trim().isNotEmpty) {
      return tenantSubdomain.trim().toLowerCase();
    }
    final host = cleanHost;
    if (host.contains('.')) {
      final first = host.split('.').first;
      if (first != 'www' && first != 'shop' && first != 'api') {
        return first;
      }
    }
    return '';
  }

  static String get apiBaseUrl {
    final h = cleanHost;
    if (h.startsWith('localhost') || h.startsWith('127.0.0.1') || h.startsWith('10.0.2.2')) {
      return 'http://$h';
    }
    return 'https://$h';
  }

  static Color hexToColor(String? hex, {Color fallback = const Color(0xFF059669)}) {
    if (hex == null || hex.trim().isEmpty) return fallback;
    String clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) clean = 'FF$clean';
    final int? val = int.tryParse(clean, radix: 16);
    return val != null ? Color(val) : fallback;
  }

  static Color get primaryColor => hexToColor(primaryColorHex);
  static Color get secondaryColor => hexToColor(secondaryColorHex, fallback: const Color(0xFF047857));
}