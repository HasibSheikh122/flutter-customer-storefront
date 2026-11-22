// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/store_env_config.dart';
import 'providers/store_provider.dart';
import 'screens/store_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StoreEnvConfig.loadEmbeddedConfig();
  runApp(
    ChangeNotifierProvider(
      create: (_) => StoreProvider(),
      child: const XyloCustomerStorefrontApp(),
    ),
  );
}

class XyloCustomerStorefrontApp extends StatelessWidget {
  const XyloCustomerStorefrontApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return MaterialApp(
      title: store.storeName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: store.primaryColor),
      ),
      home: const StoreHomeScreen(),
    );
  }
}