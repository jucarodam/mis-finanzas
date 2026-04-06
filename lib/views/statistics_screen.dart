import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  DateTime _month = DateTime.now();
  late TabController _tabs;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _nextMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month + 1));

  @override
  Widget build(BuildContext context) {
    final txProvider  = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context);
    final settings    = Provider.of<SettingsProvider>(context);
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final currency    = settings.currency;

    final income    = txProvider.getTotalIncome(_month);
    final expense   = txProvider.getTotalExpense(_month);
    final balance   = income - expense;
    final expByCat  = txProvider.getExpensesByCategory(_month);
    final incByCat  = txProvider.getIncomesByCategory(_month);
    final evolution = txProvider.getMonthlyEvolution(months: 12);
    final savRate   = txProvider.getSavingsRate(_month);

    final isCurrentMonth = _month.year == DateTime.now().year &&
        _month.month == DateTime.now().month;

    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _MonthSelector(
            month: _month,
            onPrev: _prevMonth,
            onNext: _nextMonth,
            isCurrentMonth: isCurrentMonth,
            isDark: isDark,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMedium,
          AppConstants.paddingMedium,
          AppConstants.paddingMedium,
          AppConstants.paddingXL,
        ),
        children: [
          // ── Resumen del mes ─────────────────────────────────────────────
          _MonthSummaryRow(
            income:   income,
            expense:  expense,
            balance:  balance,
            savRate:  savRate,
            currency: currency,
            isDark:   isDark,
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: AppConstants.paddingLarge),

          // ── Evolución 12 meses ──────────────────────────────────────────
          _SectionTitle('Evolución anual (12 meses)', isDark),
          const SizedBox(height: AppConstants.paddingSmall),
          _AnnualEvolutionChart(
            data:     evolution,
            isDark:   isDark,
            currency: currency,
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: AppConstants.paddingLarge),

          // ── Gastos por categoría ────────────────────────────────────────
          if (expByCat.isNotEmpty) ...[
            _SectionTitle('Gastos por categoría', isDark),
            const SizedBox(height: AppConstants.paddingSmall),
            _CategoryBreakdown(
              byCategory:    expByCat,
              total:         expense,
              catProvider:   catProvider,
              currency:      currency,
              isDark:        isDark,
              touchedIndex:  _touchedIndex,
              onTouch:       (i) => setState(() => _touchedIndex = i),
              color:         AppConstants.expenseColor,
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // ── Ingresos por categoría ──────────────────────────────────────
          if (incByCat.isNotEmpty) ...[
            _SectionTitle('Ingresos por categoría', isDark),
            const SizedBox(height: AppConstants.paddingSmall),
            _CategoryBreakdown(
              byCategory:    incByCat,
              total:         income,
              catProvider:   catProvider,
              currency:      currency,
              isDark:        isDark,
              touchedIndex:  -1,
              onTouch:       (_) {},
              color:         AppConstants.incomeColor,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // ── Tendencias (días de la semana) ─────────────────────────────
          _SectionTitle('Gasto diario del mes', isDark),
          const SizedBox(height: AppConstants.paddingSmall),
          _DailyExpenseChart(
            transactions: txProvider.getExpensesByMonth(_month),
            month:        _month,
            isDark:       isDark,
            currency:     currency,
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionTitle(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }
}

// ── Month Selector ────────────────────────────────────────────────────────────
class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev, onNext;
  final bool isCurrentMonth, isDark;
  const _MonthSelector({
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.isCurrentMonth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrev,
            style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${AppConstants.months[month.month - 1]} ${month.year}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCurrentMonth
                      ? AppConstants.primaryColor
                      : null,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: isCurrentMonth ? null : onNext,
            style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
          ),
        ],
      ),
    );
  }
}

// ── Month Summary Row ─────────────────────────────────────────────────────────
class _MonthSummaryRow extends StatelessWidget {
  final double income, expense, balance, savRate;
  final String currency;
  final bool isDark;
  const _MonthSummaryRow({
    required this.income,
    required this.expense,
    required this.balance,
    required this.savRate,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
          label: 'Ingresos',
          value: CurrencyFormatter.formatShort(income, currency: currency),
          color: AppConstants.incomeColor,
          icon: Icons.arrow_downward_rounded,
          isDark: isDark,
        )),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
          label: 'Gastos',
          value: CurrencyFormatter.formatShort(expense, currency: currency),
          color: AppConstants.expenseColor,
          icon: Icons.arrow_upward_rounded,
          isDark: isDark,
        )),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
          label: 'Ahorro',
          value: '${savRate.toStringAsFixed(0)}%',
          color: AppConstants.savingsColor,
          icon: Icons.savings_rounded,
          isDark: isDark,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final bool isDark;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isDark
              ? AppConstants.darkBorder
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Annual Evolution Chart ─────────────────────────────────────────────────────
class _AnnualEvolutionChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isDark;
  final String currency;
  const _AnnualEvolutionChart(
      {required this.data, required this.isDark, required this.currency});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxY = data.fold<double>(
      100,
      (m, d) => [m, d['income'] as double, d['expense'] as double]
          .reduce((a, b) => a > b ? a : b),
    );

    final gridColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isDark
              ? AppConstants.darkBorder
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Dot(color: AppConstants.incomeColor, label: 'Ingresos'),
              const SizedBox(width: 16),
              _Dot(color: AppConstants.expenseColor, label: 'Gastos'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.3,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor:
                        isDark ? AppConstants.darkSurface : Colors.white,
                    getTooltipItem: (group, gi, rod, ri) {
                      final d = data[group.x.toInt()];
                      final isIncome = ri == 0;
                      return BarTooltipItem(
                        CurrencyFormatter.formatShort(rod.toY,
                            currency: currency),
                        GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isIncome
                              ? AppConstants.incomeColor
                              : AppConstants.expenseColor,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final m = data[i]['month'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppConstants.monthsShort[m.month - 1],
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: gridColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  final d = data[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: d['income'] as double,
                        color: AppConstants.incomeColor,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: d['expense'] as double,
                        color: AppConstants.expenseColor,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    barsSpace: 3,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: color)),
      ],
    );
  }
}

// ── Category Breakdown ────────────────────────────────────────────────────────
class _CategoryBreakdown extends StatelessWidget {
  final Map<String, double> byCategory;
  final double total;
  final CategoryProvider catProvider;
  final String currency;
  final bool isDark;
  final int touchedIndex;
  final ValueChanged<int> onTouch;
  final Color color;

  const _CategoryBreakdown({
    required this.byCategory,
    required this.total,
    required this.catProvider,
    required this.currency,
    required this.isDark,
    required this.touchedIndex,
    required this.onTouch,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = sorted.asMap().entries.map((e) {
      final i   = e.key;
      final ent = e.value;
      final cat = catProvider.getCategoryById(ent.key);
      final pct = total > 0 ? ent.value / total * 100 : 0.0;
      final isTouched = i == touchedIndex;
      final catColor = cat != null ? Color(cat.colorValue) : color;

      return PieChartSectionData(
        value:  ent.value,
        title:  '${pct.toStringAsFixed(0)}%',
        color:  catColor,
        radius: isTouched ? 70 : 58,
        titleStyle: GoogleFonts.inter(
          fontSize: isTouched ? 13 : 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isDark
              ? AppConstants.darkBorder
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          // Pie chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections:       sections,
                sectionsSpace:  2,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent e, PieTouchResponse? r) {
                    if (!e.isInterestedForInteractions ||
                        r?.touchedSection == null) {
                      onTouch(-1);
                    } else {
                      onTouch(
                          r!.touchedSection!.touchedSectionIndex);
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),
          const Divider(),
          const SizedBox(height: AppConstants.paddingSmall),

          // Lista de categorías
          ...sorted.take(8).map((ent) {
            final cat = catProvider.getCategoryById(ent.key);
            final pct = total > 0 ? ent.value / total : 0.0;
            final catColor =
                cat != null ? Color(cat.colorValue) : color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(cat?.icon ?? '💸',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat?.name ?? 'Sin categoría',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatShort(ent.value,
                                  currency: currency),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: catColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 4,
                            backgroundColor: isDark
                                ? const Color(0xFF2D2D3F)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation(catColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Daily Expense Chart ───────────────────────────────────────────────────────
class _DailyExpenseChart extends StatelessWidget {
  final List transactions;
  final DateTime month;
  final bool isDark;
  final String currency;

  const _DailyExpenseChart({
    required this.transactions,
    required this.month,
    required this.isDark,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(month.year, month.month);

    // Acumular gastos por día
    final dailyExpenses = List<double>.filled(daysInMonth, 0);
    for (final t in transactions) {
      final day = (t as dynamic).date.day as int;
      if (day >= 1 && day <= daysInMonth) {
        dailyExpenses[day - 1] += (t.amount as double);
      }
    }

    if (dailyExpenses.every((v) => v == 0)) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(
            color: isDark
                ? AppConstants.darkBorder
                : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Center(
          child: Text(
            'Sin gastos este mes',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ),
      );
    }

    final maxY = dailyExpenses.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isDark
              ? AppConstants.darkBorder
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: maxY * 1.3,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor:
                    isDark ? AppConstants.darkSurface : Colors.white,
                getTooltipItem: (group, gi, rod, ri) =>
                    BarTooltipItem(
                  'Día ${group.x + 1}\n${CurrencyFormatter.formatShort(rod.toY, currency: currency)}',
                  GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.expenseColor,
                  ),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 18,
                  interval: 5,
                  getTitlesWidget: (v, _) {
                    final day = v.toInt() + 1;
                    if (day % 5 != 0 && day != 1) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$day',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: dailyExpenses.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    color: e.value > 0
                        ? AppConstants.expenseColor.withOpacity(0.7)
                        : Colors.transparent,
                    width: 5,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
