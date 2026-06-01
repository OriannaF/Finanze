import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/transaction.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/dashboard_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/amount_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/account_settings_screen.dart';
import '../screens/account_detail_screen.dart';
import '../screens/goal_detail_screen.dart';
import '../screens/budget_transactions_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({String initialRoute = '/'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          int currentIndex = 0;
          if (location.startsWith('/activity')) {
            currentIndex = 1;
          } else if (location.startsWith('/analytics')) {
            currentIndex = 2;
          } else if (location.startsWith('/goals')) {
            currentIndex = 3;
          }

          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) {
                switch (i) {
                  case 0: context.go('/');
                  case 1: context.go('/activity');
                  case 2: context.go('/analytics');
                  case 3: context.go('/goals');
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/activity',
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/add-amount',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AmountScreen(),
      ),
      GoRoute(
        path: '/add-details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final amount = double.tryParse(
            state.uri.queryParameters['amount'] ?? '',
          ) ?? 0;
          return TransactionDetailScreen(amount: amount);
        },
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/account-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/account-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(
            state.uri.queryParameters['id'] ?? '',
          ) ?? 0;
          return AccountDetailScreen(accountId: id);
        },
      ),
      GoRoute(
        path: '/goal-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(
            state.uri.queryParameters['id'] ?? '',
          ) ?? 0;
          return GoalDetailScreen(goalId: id);
        },
      ),
      GoRoute(
        path: '/budget-transactions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final categoryName = state.uri.queryParameters['category'] ?? 'other';
          final budgetId = int.tryParse(
            state.uri.queryParameters['budgetId'] ?? '',
          ) ?? 0;
          final category = TransactionCategory.values.firstWhere(
            (e) => e.name == categoryName,
            orElse: () => TransactionCategory.other,
          );
          return BudgetTransactionsScreen(budgetId: budgetId, category: category);
        },
      ),
    ],
  );
}
