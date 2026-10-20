// lib/core/config/store_env_config.dart
// Spec V2.4 Section 4: Zero-Knowledge Compile-Time White-Label Constants (--dart-define)
import 'package:flutter/material.dart';

class StoreEnvConfig {
  static const String compileTimeStoreDomain = String.fromEnvironment(
    'STORE_DOMAIN',
    defaultValue: 'nextlook.localhost:8000',
  );

  static const String compileTimeSubdomain = String.fromEnvironment(
    'TENANT_SUBDOMAIN',
    defaultValue: 'nextlook',
  );

  static const String compileTimeAppName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Nextlook Store',
  );

  static const String compileTimePrimaryColor = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '#059669',
  );

  static const String compileTimeSecondaryColor = String.fromEnvironment(
    'SECONDARY_COLOR',
    defaultValue: '#047857',
  );

  static const String compileTimeBundleId = String.fromEnvironment(
    'BUNDLE_ID',
    defaultValue: 'com.xylosaas.nextlook',
  );

  static Color parseHex(String? hex, {Color fallback = const Color(0xFF059669)}) {
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
