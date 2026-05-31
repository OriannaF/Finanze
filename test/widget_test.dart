import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finanze_app/main.dart';
import 'package:finanze_app/providers/theme_provider.dart';
import 'package:finanze_app/providers/transaction_provider.dart';
import 'package:finanze_app/providers/goal_provider.dart';
import 'package:finanze_app/providers/settings_provider.dart';
import 'package:finanze_app/providers/account_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AccountProvider()),
        ],
        child: const FinanzeApp(initialRoute: '/'),
      ),
    );
    expect(find.byType(FinanzeApp), findsOneWidget);
  });
}
