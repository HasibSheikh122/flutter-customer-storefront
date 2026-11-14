// lib/core/config/store_env_config.dart
import 'package:flutter/material.dart';

class StoreEnvConfig {
  static const String storeDomain = String.fromEnvironment(
    'STORE_DOMAIN',
    defaultValue: 'bestbdbazar.shop.xylotechsolution.com',
  );

  static const String tenantSubdomain = String.fromEnvironment(
    'TENANT_SUBDOMAIN',
    defaultValue: 'bestbdbazar',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: "BestBdBazar",
  );

  static const String appSlogan = String.fromEnvironment(
    'APP_SLOGAN',
    defaultValue: "Authentic Online Shopping",
  );

  static const String appIconUrl = String.fromEnvironment(
    'APP_ICON_URL',
    defaultValue: 'https://bestbdbazar.shop.xylotechsolution.com/media/stores/apps/icons/footerlogo_1hq658A.png',
  );

  static const String primaryColorHex = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '#015b01',
  );

  static const String secondaryColorHex = String.fromEnvironment(
    'SECONDARY_COLOR',
    defaultValue: '#940000',
  );

  static const String bundleId = String.fromEnvironment(
    'BUNDLE_ID',
    defaultValue: 'com.xylosaas.bestbdbazar.store',
  );

  static const String compileTimeStoreDomain = storeDomain;
  static const String compileTimeSubdomain = tenantSubdomain;
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
    return 'bestbdbazar';
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
