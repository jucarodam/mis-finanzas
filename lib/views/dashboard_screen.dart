import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    final totalIncome = transactionProvider.getTotalIncome(currentMonth);
    final totalExpense = transactionProvider.getTotalExpense(currentMonth);
    final balance = totalIncome - totalExpense;

    final expensesByCategory = transactionProvider.getExpensesByCategory(currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          // Resumen de saldos
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            children: [
              SummaryCard(
                title: 'Ingresos del mes',
                value: CurrencyFormatter.format(totalIncome),
                icon: Icons.arrow_downward,
                color: AppConstants.successColor,
              ),
              SummaryCard(
                title: 'Gastos del mes',
                value: CurrencyFormatter.format(totalExpense),
                icon: Icons.arrow_upward,
                color: AppConstants.errorColor,
                subtitle: settingsProvider.monthlyLimit > 0
                    ? '${settingsProvider.getExpensePercentage(totalExpense).toStringAsFixed(1)}% del límite'
                    : null,
              ),
              SummaryCard(
                title: 'Balance disponible',
                value: CurrencyFormatter.format(balance),
                icon: Icons.account_balance_wallet,
                color: balance >= 0 ? AppConstants.accentColor : AppConstants.errorColor,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Advertencia de límite
          if (settingsProvider.shouldShowWarning(totalExpense))
            Card(
              color: AppConstants.warningColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppConstants.warningColor),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: Text(
                        'Has alcanzado el ${settingsProvider.getExpensePercentage(totalExpense).toStringAsFixed(0)}% de tu límite mensual',
                        style: TextStyle(color: AppConstants.warningColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Gráfico de distribución de gastos
          if (expensesByCategory.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribución de Gastos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: expensesByCategory.entries.map((entry) {
                            final category = categoryProvider.getCategoryById(entry.key);
                            final percentage = (entry.value / totalExpense) * 100;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${percentage.toStringAsFixed(0)}%',
                              color: category != null
                                  ? Color(category.colorValue)
                                  : Colors.grey,
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    // Leyenda
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: expensesByCategory.entries.map((entry) {
                        final category = categoryProvider.getCategoryById(entry.key);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category != null
                                    ? Color(category.colorValue)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${category?.icon ?? ''} ${category?.name ?? "Sin categoría"}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              CurrencyFormatter.formatCompact(entry.value),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // Gráfico de evolución mensual
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evolución Mensual (últimos 6 meses)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  SizedBox(
                    height: 250,
                    child: _MonthlyEvolutionChart(
                      data: transactionProvider.getMonthlyEvolution(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyEvolutionChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _MonthlyEvolutionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final maxY = data.fold<double>(
      0,
      (max, item) => [max, item['income'] as double, item['expense'] as double]
          .reduce((a, b) => a > b ? a : b),
    );

    // Asegurar que maxY no sea 0 para evitar errores en el gráfico
    final safeMaxY = maxY > 0 ? maxY : 1000.0;

    return LineChart(
      LineChartData(
        maxY: safeMaxY * 1.2,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: safeMaxY / 5,
        ),
        titlesData: FlTitlesData(
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
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final month = data[value.toInt()]['month'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      AppConstants.months[month.month - 1].substring(0, 3),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Línea de ingresos
          LineChartBarData(
            spots: List.generate(
              data.length,
              (index) => FlSpot(index.toDouble(), data[index]['income'] as double),
            ),
            isCurved: true,
            color: AppConstants.successColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppConstants.successColor.withOpacity(0.1),
            ),
          ),
          // Línea de gastos
          LineChartBarData(
            spots: List.generate(
              data.length,
              (index) => FlSpot(index.toDouble(), data[index]['expense'] as double),
            ),
            isCurved: true,
            color: AppConstants.errorColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppConstants.errorColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
