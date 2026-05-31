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
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  Intl.defaultLocale = 'es';

  final db = DatabaseHelper();
  await db.insertMockData();

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: FinanzeApp(initialRoute: onboardingCompleted ? '/' : '/onboarding'),
      ),
    ),
  );
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
