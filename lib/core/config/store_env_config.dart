// lib/core/config/store_env_config.dart
import 'package:flutter/material.dart';

class StoreEnvConfig {
  static const String compileTimeStoreDomain = String.fromEnvironment(
    'STORE_DOMAIN',
    defaultValue: 'nextlook.shop.xylotechsolution.com',
  );

  // 🌟 অটোমেটিক ডোমেইন থেকে সাবডোমেন আলাদা করবে (যেমন: bestbdbazar.shop... -> bestbdbazar)
  static String get compileTimeSubdomain {
    const explicit = String.fromEnvironment('TENANT_SUBDOMAIN');
    if (explicit.isNotEmpty) return explicit;

    final domainWithoutPort = compileTimeStoreDomain.split(':').first.trim();
    final parts = domainWithoutPort.split('.');
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first;
    }
    return 'nextlook';
  }

  static String get compileTimeAppName {
    const explicit = String.fromEnvironment('APP_NAME');
    if (explicit.isNotEmpty) return explicit;

    // সাবডোমেন অনুযায়ী টাইটেল তৈরি করবে
    final sub = compileTimeSubdomain;
    if (sub == 'bestbdbazar') return 'Best BD Bazar';
    if (sub == 'nextlook') return 'Nextlook Store';
    return '${sub[0].toUpperCase()}${sub.substring(1)} Store';
  }

  static const String compileTimePrimaryColor = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '#059669',
  );

  static const String compileTimeSecondaryColor = String.fromEnvironment(
    'SECONDARY_COLOR',
    defaultValue: '#047857',
  );

  static Color parseHex(String? hex,
      {Color fallback = const Color(0xFF059669)}) {
    if (hex == null || hex.trim().isEmpty) return fallback;
    String clean = hex.trim().replaceAll('#', '');
    if (clean.length == 6) clean = 'FF$clean';
    final int? val = int.tryParse(clean, radix: 16);
    return val != null ? Color(val) : fallback;
  }

  static String get resolvedBaseUrl {
    String raw = compileTimeStoreDomain.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      final bool isLocal = raw.contains('localhost') ||
          raw.startsWith('127.0.0.1') ||
          raw.startsWith('10.0.2.2');
      raw = '${isLocal ? "http" : "https"}://$raw';
    }
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }
}
