import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/statistics_data.dart';
import '../providers/statistics_providers.dart';

enum StatisticsPeriod { thisMonth, lastMonth, customMonth }

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatisticsPeriod _period = StatisticsPeriod.thisMonth;
  DateTime _customMonth = DateTime.now();

  DateTime get _selectedMonth {
    final now = DateTime.now();

    switch (_period) {
      case StatisticsPeriod.thisMonth:
        return DateTime(now.year, now.month, 1);

      case StatisticsPeriod.lastMonth:
        return DateTime(now.year, now.month - 1, 1);

      case StatisticsPeriod.customMonth:
        return DateTime(_customMonth.year, _customMonth.month, 1);
    }
  }

  Future<void> _selectCustomMonth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _customMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Select a month',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _customMonth = DateTime(picked.year, picked.month, 1);
      _period = StatisticsPeriod.customMonth;
    });
  }

  String _periodLabel() {
    switch (_period) {
      case StatisticsPeriod.thisMonth:
        return 'This month';

      case StatisticsPeriod.lastMonth:
        return 'Last month';

      case StatisticsPeriod.customMonth:
        return _monthName(_selectedMonth);
    }
  }

  String _monthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statisticsAsync = ref.watch(statisticsProvider(_selectedMonth));

    final monthlyAsync = ref.watch(recentMonthlyStatisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statisticsProvider(_selectedMonth));
          ref.invalidate(recentMonthlyStatisticsProvider);

          await ref.read(statisticsProvider(_selectedMonth).future);
          await ref.read(recentMonthlyStatisticsProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _PeriodSelector(
              selectedPeriod: _period,
              label: _periodLabel(),
              onChanged: (period) {
                if (period == StatisticsPeriod.customMonth) {
                  _selectCustomMonth();
                  return;
                }

                setState(() {
                  _period = period;
                });
              },
            ),
            const SizedBox(height: 20),
            statisticsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _StatisticsError(
                error: error,
                onRetry: () {
                  ref.invalidate(statisticsProvider(_selectedMonth));
                },
              ),
              data: (statistics) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCards(statistics: statistics),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Expense Breakdown',
                      subtitle: _monthName(statistics.month),
                    ),
                    const SizedBox(height: 12),
                    _ExpenseBreakdownCard(statistics: statistics),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Monthly Comparison',
                      subtitle: 'Last 6 months',
                    ),
                    const SizedBox(height: 12),
                    monthlyAsync.when(
                      loading: () => const _ChartLoadingCard(),
                      error: (error, _) => _StatisticsError(
                        error: error,
                        onRetry: () {
                          ref.invalidate(recentMonthlyStatisticsProvider);
                        },
                      ),
                      data: (monthlyStatistics) {
                        return _MonthlyComparisonCard(
                          statistics: monthlyStatistics,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Category Spending',
                      subtitle: _monthName(statistics.month),
                    ),
                    const SizedBox(height: 12),
                    _CategorySpendingCard(statistics: statistics),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.label,
    required this.onChanged,
  });

  final StatisticsPeriod selectedPeriod;
  final String label;
  final ValueChanged<StatisticsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<StatisticsPeriod>(
      initialValue: selectedPeriod,
      decoration: const InputDecoration(
        labelText: 'Period',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
      ),
      items: [
        const DropdownMenuItem(
          value: StatisticsPeriod.thisMonth,
          child: Text('This month'),
        ),
        const DropdownMenuItem(
          value: StatisticsPeriod.lastMonth,
          child: Text('Last month'),
        ),
        DropdownMenuItem(
          value: StatisticsPeriod.customMonth,
          child: Text(
            selectedPeriod == StatisticsPeriod.customMonth
                ? label
                : 'Custom month',
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.statistics});

  final StatisticsData statistics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Income',
            amount: statistics.totalIncome,
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Expenses',
            amount: statistics.totalExpenses,
            icon: Icons.arrow_upward,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final int amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Rs. $amount',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ExpenseBreakdownCard extends StatelessWidget {
  const _ExpenseBreakdownCard({required this.statistics});

  final StatisticsData statistics;

  @override
  Widget build(BuildContext context) {
    if (statistics.totalExpenses == 0) {
      return const _EmptyChartCard(
        message: 'No expenses recorded for this period.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 230,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 48,
                  sectionsSpace: 3,
                  sections: [
                    for (
                      var index = 0;
                      index < statistics.expenseBreakdown.length;
                      index++
                    )
                      PieChartSectionData(
                        value: statistics.expenseBreakdown[index].amount
                            .toDouble(),
                        title:
                            '${statistics.expenseBreakdown[index].percentage.toStringAsFixed(0)}%',
                        radius: 78,
                        color: colors[index % colors.length],
                        titleStyle: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                for (
                  var index = 0;
                  index < statistics.expenseBreakdown.length;
                  index++
                )
                  _LegendItem(
                    label: statistics.expenseBreakdown[index].categoryName,
                    amount: statistics.expenseBreakdown[index].amount,
                    color: colors[index % colors.length],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: Rs. $amount'),
      ],
    );
  }
}

class _MonthlyComparisonCard extends StatelessWidget {
  const _MonthlyComparisonCard({required this.statistics});

  final List<MonthlyStatistics> statistics;

  String _monthLabel(DateTime month) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return labels[month.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = statistics.fold<double>(0, (maximum, item) {
      final highest = item.income > item.expenses ? item.income : item.expenses;

      return highest > maximum ? highest.toDouble() : maximum;
    });

    if (maxValue == 0) {
      return const _EmptyChartCard(
        message: 'No income or expenses recorded yet.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 16),
        child: SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              maxY: maxValue * 1.2,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _compactAmount(value),
                        style: Theme.of(context).textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= statistics.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _monthLabel(statistics[index].month),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var index = 0; index < statistics.length; index++)
                  BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: statistics[index].income.toDouble(),
                        width: 9,
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: statistics[index].expenses.toDouble(),
                        width: 9,
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _compactAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }

    return value.toStringAsFixed(0);
  }
}

class _CategorySpendingCard extends StatelessWidget {
  const _CategorySpendingCard({required this.statistics});

  final StatisticsData statistics;

  @override
  Widget build(BuildContext context) {
    if (statistics.categorySpending.isEmpty) {
      return const _EmptyChartCard(
        message: 'No category spending for this period.',
      );
    }

    return Card(
      child: Column(
        children: [
          for (
            var index = 0;
            index < statistics.categorySpending.length;
            index++
          ) ...[
            ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(statistics.categorySpending[index].categoryName),
              trailing: Text(
                'Rs. ${statistics.categorySpending[index].amount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (index < statistics.categorySpending.length - 1)
              const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _EmptyChartCard extends StatelessWidget {
  const _EmptyChartCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text(message, textAlign: TextAlign.center)),
      ),
    );
  }
}

class _ChartLoadingCard extends StatelessWidget {
  const _ChartLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _StatisticsError extends StatelessWidget {
  const _StatisticsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Failed to load statistics.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
