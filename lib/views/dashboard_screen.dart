import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../models/transaction_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final txProvider  = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context);
    final settings    = Provider.of<SettingsProvider>(context);
    final accounts    = Provider.of<AccountProvider>(context);
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    final now         = DateTime.now();
    final month       = DateTime(now.year, now.month);
    final income      = txProvider.getTotalIncome(month);
    final expense     = txProvider.getTotalExpense(month);
    final balance     = income - expense;
    final savingsRate = txProvider.getSavingsRate(month);
    final expByCat    = txProvider.getExpensesByCategory(month);
    final recent      = txProvider.getRecent(count: 6);
    final currency    = settings.currency;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor:
                isDark ? AppConstants.darkBackground : AppConstants.lightBackground,
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Finanzas',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy', 'es').format(now),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              _QuickAddButton(currency: currency),
              const SizedBox(width: 8),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
              AppConstants.paddingMedium,
              AppConstants.paddingXL,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Tarjeta balance principal ──────────────────────────────
                _BalanceHeroCard(
                  balance: balance,
                  income: income,
                  expense: expense,
                  savingsRate: savingsRate,
                  currency: currency,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),

                const SizedBox(height: AppConstants.paddingLarge),

                // ── Alerta de presupuesto ──────────────────────────────────
                if (settings.shouldShowWarning(expense))
                  _BudgetWarningCard(
                    expense: expense,
                    settings: settings,
                    currency: currency,
                    isDark: isDark,
                  ).animate().fadeIn().slideX(begin: 0.05),

                if (settings.shouldShowWarning(expense))
                  const SizedBox(height: AppConstants.paddingMedium),

                // ── Presupuesto mensual ────────────────────────────────────
                if (settings.monthlyLimit > 0)
                  _BudgetProgressCard(
                    expense: expense,
                    settings: settings,
                    currency: currency,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 100.ms),

                if (settings.monthlyLimit > 0)
                  const SizedBox(height: AppConstants.paddingLarge),

                // ── Cuentas ────────────────────────────────────────────────
                if (accounts.accounts.isNotEmpty) ...[
                  _SectionHeader(title: 'Mis Cuentas', isDark: isDark),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _AccountsRow(accounts: accounts, currency: currency),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // ── Gastos por categoría ───────────────────────────────────
                if (expByCat.isNotEmpty) ...[
                  _SectionHeader(title: 'Gastos por categoría', isDark: isDark),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _ExpensesCategoryCard(
                    expByCat: expByCat,
                    totalExpense: expense,
                    catProvider: catProvider,
                    currency: currency,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // ── Evolución mensual ──────────────────────────────────────
                _SectionHeader(title: 'Evolución (6 meses)', isDark: isDark),
                const SizedBox(height: AppConstants.paddingSmall),
                _MonthlyChart(
                  data: txProvider.getMonthlyEvolution(),
                  isDark: isDark,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppConstants.paddingLarge),

                // ── Últimas transacciones ──────────────────────────────────
                if (recent.isNotEmpty) ...[
                  _SectionHeader(title: 'Movimientos recientes', isDark: isDark),
                  const SizedBox(height: AppConstants.paddingSmall),
                  ...recent.map((t) => TransactionListItem(
                    transaction: t,
                    onTap: () => _editTransaction(context, t),
                    onDelete: () => _deleteTransaction(context, t),
                  ).animate().fadeIn(delay: 50.ms)),
                ],
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('Agregar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _AddTransactionSheet(context: context),
    );
  }

  void _editTransaction(BuildContext context, TransactionModel t) {
    showDialog(
      context: context,
      builder: (_) => TransactionForm(type: t.type, transaction: t),
    );
  }

  void _deleteTransaction(BuildContext context, TransactionModel t) {
    Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(t);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internos
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }
}

// ── Balance Hero Card ─────────────────────────────────────────────────────────
class _BalanceHeroCard extends StatelessWidget {
  final double balance, income, expense, savingsRate;
  final String currency;
  final bool isDark;

  const _BalanceHeroCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.savingsRate,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Balance del mes',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Text(
                  currency,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(balance, currency: currency),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                savingsRate >= 0 ? Icons.trending_up : Icons.trending_down,
                color: savingsRate >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Tasa de ahorro: ${savingsRate.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Ingresos',
                  value: CurrencyFormatter.formatShort(income,
                      currency: currency),
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Gastos',
                  value: CurrencyFormatter.formatShort(expense,
                      currency: currency),
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MiniStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Budget Warning ────────────────────────────────────────────────────────────
class _BudgetWarningCard extends StatelessWidget {
  final double expense;
  final SettingsProvider settings;
  final String currency;
  final bool isDark;
  const _BudgetWarningCard(
      {required this.expense,
      required this.settings,
      required this.currency,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = settings.getExpensePercentage(expense);
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.warningColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: AppConstants.warningColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppConstants.warningColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Has usado el ${pct.toStringAsFixed(0)}% de tu presupuesto mensual',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppConstants.warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Budget Progress ───────────────────────────────────────────────────────────
class _BudgetProgressCard extends StatelessWidget {
  final double expense;
  final SettingsProvider settings;
  final String currency;
  final bool isDark;
  const _BudgetProgressCard(
      {required this.expense,
      required this.settings,
      required this.currency,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct    = settings.getExpensePercentage(expense) / 100;
    final limit  = settings.monthlyLimit;
    final isOver = expense > limit;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Presupuesto mensual',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isOver
                      ? AppConstants.expenseColor
                      : AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark
                  ? const Color(0xFF2D2D3F)
                  : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(
                isOver
                    ? AppConstants.expenseColor
                    : AppConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatShort(expense, currency: currency),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppConstants.expenseColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'de ${CurrencyFormatter.formatShort(limit, currency: currency)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Accounts Row ──────────────────────────────────────────────────────────────
class _AccountsRow extends StatelessWidget {
  final AccountProvider accounts;
  final String currency;
  const _AccountsRow({required this.accounts, required this.currency});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final a = accounts.accounts[i];
          final color = Color(a.colorValue);
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(a.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        a.name,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.formatShort(a.balance,
                      currency: a.currency),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Expenses by Category ──────────────────────────────────────────────────────
class _ExpensesCategoryCard extends StatelessWidget {
  final Map<String, double> expByCat;
  final double totalExpense;
  final CategoryProvider catProvider;
  final String currency;
  final bool isDark;

  const _ExpensesCategoryCard({
    required this.expByCat,
    required this.totalExpense,
    required this.catProvider,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = expByCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

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
        children: top.map((entry) {
          final cat = catProvider.getCategoryById(entry.key);
          final pct = totalExpense > 0 ? entry.value / totalExpense : 0.0;
          final color =
              cat != null ? Color(cat.colorValue) : AppConstants.primaryColor;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Row(
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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatShort(entry.value,
                                    currency: currency),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppConstants.expenseColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 34,
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
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? const Color(0xFF2D2D3F)
                                  : const Color(0xFFE2E8F0),
                              valueColor:
                                  AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Monthly Evolution Chart ───────────────────────────────────────────────────
class _MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isDark;
  const _MonthlyChart({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = data.fold<double>(
      100,
      (m, d) => [m, d['income'] as double, d['expense'] as double]
          .reduce((a, b) => a > b ? a : b),
    );

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
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendDot(
                  color: AppConstants.incomeColor, label: 'Ingresos'),
              const SizedBox(width: 16),
              _LegendDot(
                  color: AppConstants.expenseColor, label: 'Gastos'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                maxY: maxY * 1.25,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    strokeWidth: 1,
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
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final month = data[i]['month'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            AppConstants.monthsShort[month.month - 1],
                            style: GoogleFonts.inter(
                              fontSize: 10,
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
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _lineBar(
                    data: data.map((d) => d['income'] as double).toList(),
                    color: AppConstants.incomeColor,
                  ),
                  _lineBar(
                    data: data.map((d) => d['expense'] as double).toList(),
                    color: AppConstants.expenseColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineBar(
      {required List<double> data, required Color color}) {
    return LineChartBarData(
      spots: List.generate(
          data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (s, pct, bar, i) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 0,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.08),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

// ── Quick Add Button ──────────────────────────────────────────────────────────
class _QuickAddButton extends StatelessWidget {
  final String currency;
  const _QuickAddButton({required this.currency});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      icon: const Icon(Icons.add_rounded),
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXXL)),
        ),
        builder: (_) => _AddTransactionSheet(context: context),
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(40, 40),
      ),
    );
  }
}

// ── Add Transaction Sheet ─────────────────────────────────────────────────────
class _AddTransactionSheet extends StatelessWidget {
  final BuildContext context;
  const _AddTransactionSheet({required this.context});

  @override
  Widget build(BuildContext outerCtx) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Agregar movimiento',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _AddTypeButton(
                    label: 'Ingreso',
                    icon: Icons.arrow_downward_rounded,
                    color: AppConstants.incomeColor,
                    onTap: () {
                      Navigator.pop(outerCtx);
                      showDialog(
                        context: context,
                        builder: (_) => const TransactionForm(
                            type: TransactionType.income),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AddTypeButton(
                    label: 'Gasto',
                    icon: Icons.arrow_upward_rounded,
                    color: AppConstants.expenseColor,
                    onTap: () {
                      Navigator.pop(outerCtx);
                      showDialog(
                        context: context,
                        builder: (_) => const TransactionForm(
                            type: TransactionType.expense),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AddTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AddTypeButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
