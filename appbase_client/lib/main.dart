// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

// --- IMPORT YOUR UPDATED API CONFIG ---
import 'package:appbase_client/core/config/api_config.dart';
import 'package:appbase_client/core/data/adapters/date_time_adapter.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';
import 'package:appbase_client/routing/app_router.dart';
import 'package:appbase_client/core/config/app_theme.dart';

// --- THIS IS THE CORRECTED IMPORT PATH (NO SPACE) ---
import 'package:appbase_client/core/data/adapters/hive_registrar.g.dart';

Future<void> main() async {
  // Ensures that Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your API URL
  ApiConfig.initialize();

  // Initialize Hive for local caching
  await Hive.initFlutter();
  
  // Register all Hive adapters
  // This line will now work because the import above is correct.
  Hive.registerAdapters(); 
//  Hive.registerAdapter(DateTimeAdapter());

  // Run the app within a ProviderScope for state management
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ibtwil',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}