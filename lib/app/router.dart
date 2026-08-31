import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) {
            return const StatisticsScreen();
          },
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) {
            return const TransactionsScreen();
          },
        ),
        GoRoute(
          path: '/budgets',
          builder: (context, state) {
            return const BudgetsScreen();
          },
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) {
            return const CategoriesScreen();
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) {
            return const SettingsScreen();
          },
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/transactions');
            case 2:
              context.go('/budgets');
            case 3:
              context.go('/statistics');
            case 4:
              context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/transactions')) {
      return 1;
    }

    if (location.startsWith('/budgets')) {
      return 2;
    }

    if (location.startsWith('/statistics')) {
      return 3;
    }

    if (location.startsWith('/settings')) {
      return 4;
    }

    return 0;
  }
}
