import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all data?'),
          content: const Text(
            'This will permanently delete all transactions and budgets. '
            'Your categories will be kept.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Clear data'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(databaseProvider).clearAllData();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All transactions and budgets were cleared.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to clear data: $error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Theme'),
              subtitle: Text(_themeLabel(themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preferences',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              subtitle: Text(_currencyLabel(currency)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCurrencyDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Data',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Clear all data'),
              subtitle: const Text('Delete all transactions and budgets'),
              onTap: () => _clearAllData(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemeDialog(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choose theme'),
          children: [
            _ThemeOption(
              value: 'system',
              label: 'System',
              icon: Icons.brightness_auto_outlined,
            ),
            _ThemeOption(
              value: 'light',
              label: 'Light',
              icon: Icons.light_mode_outlined,
            ),
            _ThemeOption(
              value: 'dark',
              label: 'Dark',
              icon: Icons.dark_mode_outlined,
            ),
          ],
        );
      },
    );

    if (selected != null) {
      await ref.read(themeModeProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _showCurrencyDialog(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choose currency'),
          children: const [
            _CurrencyOption(value: 'PKR', label: 'PKR (Rs.)'),
            _CurrencyOption(value: 'USD', label: 'USD (\$)'),
            _CurrencyOption(value: 'EUR', label: 'EUR (€)'),
            _CurrencyOption(value: 'GBP', label: 'GBP (£)'),
          ],
        );
      },
    );

    if (selected != null) {
      await ref.read(currencyProvider.notifier).setCurrency(selected);
    }
  }

  String _themeLabel(String value) {
    switch (value) {
      case 'light':
        return 'Light';

      case 'dark':
        return 'Dark';

      default:
        return 'System';
    }
  }

  String _currencyLabel(String value) {
    switch (value) {
      case 'USD':
        return 'USD (\$)';

      case 'EUR':
        return 'EUR (€)';

      case 'GBP':
        return 'GBP (£)';

      default:
        return 'PKR (Rs.)';
    }
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop(value);
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(label),
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop(value);
      },
      child: Text(label),
    );
  }
}
