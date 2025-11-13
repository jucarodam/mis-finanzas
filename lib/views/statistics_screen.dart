import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final monthTransactions = transactionProvider.getTransactionsByMonth(_selectedMonth);
    final monthIncome = transactionProvider.getTotalIncome(_selectedMonth);
    final monthExpense = transactionProvider.getTotalExpense(_selectedMonth);
    final expensesByCategory = transactionProvider.getExpensesByCategory(_selectedMonth);
    final incomesByCategory = transactionProvider.getIncomesByCategory(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${AppConstants.months[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          // Resumen del mes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                children: [
                  Text(
                    'Resumen del mes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Ingresos',
                        value: CurrencyFormatter.format(monthIncome),
                        color: AppConstants.successColor,
                      ),
                      _StatItem(
                        label: 'Gastos',
                        value: CurrencyFormatter.format(monthExpense),
                        color: AppConstants.errorColor,
                      ),
                      _StatItem(
                        label: 'Balance',
                        value: CurrencyFormatter.format(monthIncome - monthExpense),
                        color: monthIncome - monthExpense >= 0
                            ? AppConstants.accentColor
                            : AppConstants.errorColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    '${monthTransactions.length} transacciones',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Gráfico de barras: Gastos vs Ingresos
          if (expensesByCategory.isNotEmpty || incomesByCategory.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastos por Categoría',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: expensesByCategory.values.isEmpty
                              ? 100
                              : expensesByCategory.values.reduce((a, b) => a > b ? a : b) * 1.2,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final categoryId = expensesByCategory.keys.elementAt(groupIndex);
                                final category = categoryProvider.getCategoryById(categoryId);
                                return BarTooltipItem(
                                  '${category?.name ?? "Sin categoría"}\n',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: CurrencyFormatter.format(rod.toY),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < expensesByCategory.length) {
                                    final categoryId =
                                        expensesByCategory.keys.elementAt(value.toInt());
                                    final category = categoryProvider.getCategoryById(categoryId);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        category?.icon ?? '?',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    CurrencyFormatter.formatCompact(value),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          barGroups: List.generate(
                            expensesByCategory.length,
                            (index) {
                              final categoryId = expensesByCategory.keys.elementAt(index);
                              final category = categoryProvider.getCategoryById(categoryId);
                              final amount = expensesByCategory[categoryId]!;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: amount,
                                    color: category != null
                                        ? Color(category.colorValue)
                                        : Colors.grey,
                                    width: 20,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // Top 5 categorías de gastos
          if (expensesByCategory.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Categorías de Gastos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ...expensesByCategory.entries
                        .toList()
                        .asMap()
                        .entries
                        .take(5)
                        .map((entry) {
                      final categoryId = entry.value.key;
                      final amount = entry.value.value;
                      final category = categoryProvider.getCategoryById(categoryId);
                      final percentage = (amount / monthExpense) * 100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  category?.icon ?? '?',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category?.name ?? 'Sin categoría',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        color: category != null
                                            ? Color(category.colorValue)
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (entry.key < 4) const Divider(),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
