import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database_helper.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/account_provider.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'utils/seed_data.dart';
import 'widgets/device_screenshot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es';

  bool onboardingCompleted = false;

  // Web fallback: sqflite_common_ffi no funciona en web
  if (!kIsWeb) {
    sqfliteFfiInit();

    try {
      final db = DatabaseHelper();
      final prefs = await SharedPreferences.getInstance();

      final seedLoaded = prefs.getBool('seedDataLoaded') ?? false;
      if (!seedLoaded) {
        await db.deleteAllData();
        await loadSeedData();
        await prefs.setBool('seedDataLoaded', true);
      }

      onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

      await db.generateRecurringTransactions();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  runApp(
    ScreenCapture(
      enabled: !kReleaseMode,
      child: DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AccountProvider()),
        ],
        child: kIsWeb
            ? const UnsupportedPlatformScreen()
            : FinanzeApp(initialRoute: onboardingCompleted ? '/' : '/onboarding'),
      ),
    ),
    ),
  );
}

class UnsupportedPlatformScreen extends StatelessWidget {
  const UnsupportedPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanze',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/zoe_icono.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  'Finanze',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'La versión web está en desarrollo.\nDescargá la app nativa para usar Finanze.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinanzeApp extends StatelessWidget {
  final String initialRoute;
  const FinanzeApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Finanze',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      routerConfig: createRouter(initialRoute: initialRoute),
    );
  }
}
