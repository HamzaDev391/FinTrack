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
      bottomNavigationBar: _BottomNavigationBar(
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

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              _BottomNavigationItem(
                flex: 2,
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                isSelected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              _BottomNavigationItem(
                flex: 5,
                label: 'Transactions',
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                isSelected: selectedIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
              _BottomNavigationItem(
                flex: 3,
                label: 'Budgets',
                icon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet,
                isSelected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
              _BottomNavigationItem(
                flex: 4,
                label: 'Statistics',
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                isSelected: selectedIndex == 3,
                onTap: () => onDestinationSelected(3),
              ),
              _BottomNavigationItem(
                flex: 3,
                label: 'Settings',
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                isSelected: selectedIndex == 4,
                onTap: () => onDestinationSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    required this.flex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final int flex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Expanded(
      flex: flex,
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  NavigationIndicator(
                    animation: AlwaysStoppedAnimation(isSelected ? 1 : 0),
                    color: colorScheme.secondaryContainer,
                  ),
                  Icon(
                    isSelected ? selectedIcon : icon,
                    color: foregroundColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: foregroundColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
