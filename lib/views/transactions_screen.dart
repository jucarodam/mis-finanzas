import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider   = Provider.of<TransactionProvider>(context);
    final catProvider  = Provider.of<CategoryProvider>(context);
    final settings     = Provider.of<SettingsProvider>(context);
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final now          = DateTime.now();
    final month        = DateTime(now.year, now.month);
    final currency     = settings.currency;

    final allTx    = txProvider.filtered;
    final incomes  = allTx.where((t) => t.type == TransactionType.income).toList();
    final expenses = allTx.where((t) => t.type == TransactionType.expense).toList();

    final totalIn  = txProvider.getTotalIncome(month);
    final totalOut = txProvider.getTotalExpense(month);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar transacciones...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.inter(
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 16),
                onChanged: (q) => txProvider.setSearch(q),
              )
            : Text('Movimientos',
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  txProvider.setSearch('');
                }
              });
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded),
                if (txProvider.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showFilterSheet(context, txProvider, catProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Resumen rápido
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child: Row(
                  children: [
                    _QuickStat(
                      label: 'Ingresos',
                      value: CurrencyFormatter.formatShort(totalIn,
                          currency: currency),
                      color: AppConstants.incomeColor,
                    ),
                    const SizedBox(width: 12),
                    _QuickStat(
                      label: 'Gastos',
                      value: CurrencyFormatter.formatShort(totalOut,
                          currency: currency),
                      color: AppConstants.expenseColor,
                    ),
                    const SizedBox(width: 12),
                    _QuickStat(
                      label: 'Balance',
                      value: CurrencyFormatter.formatShort(
                          totalIn - totalOut,
                          currency: currency),
                      color: totalIn >= totalOut
                          ? AppConstants.incomeColor
                          : AppConstants.expenseColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Todos'),
                        const SizedBox(width: 6),
                        _CountChip(count: allTx.length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_downward_rounded, size: 14),
                        const SizedBox(width: 4),
                        const Text('Ingresos'),
                        const SizedBox(width: 6),
                        _CountChip(count: incomes.length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 14),
                        const SizedBox(width: 4),
                        const Text('Gastos'),
                        const SizedBox(width: 6),
                        _CountChip(count: expenses.length),
                      ],
                    ),
                  ),
                ],
                labelStyle: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w400),
                indicatorColor: AppConstants.primaryColor,
                labelColor: AppConstants.primaryColor,
                unselectedLabelColor:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(
            transactions: allTx,
            currency: currency,
            isDark: isDark,
          ),
          _TransactionList(
            transactions: incomes,
            currency: currency,
            isDark: isDark,
          ),
          _TransactionList(
            transactions: expenses,
            currency: currency,
            isDark: isDark,
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_expense',
            onPressed: () => showDialog(
              context: context,
              builder: (_) =>
                  const TransactionForm(type: TransactionType.expense),
            ),
            icon: const Icon(Icons.arrow_upward_rounded),
            label: Text('Gasto',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            backgroundColor: AppConstants.expenseColor,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add_income',
            onPressed: () => showDialog(
              context: context,
              builder: (_) =>
                  const TransactionForm(type: TransactionType.income),
            ),
            icon: const Icon(Icons.arrow_downward_rounded),
            label: Text('Ingreso',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            backgroundColor: AppConstants.incomeColor,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(
      BuildContext context,
      TransactionProvider txProvider,
      CategoryProvider catProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _FilterSheet(
        txProvider: txProvider,
        catProvider: catProvider,
      ),
    );
  }
}

// ── Transaction List grouped by date ─────────────────────────────────────────
class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String currency;
  final bool isDark;

  const _TransactionList({
    required this.transactions,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📭', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No hay movimientos',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar por fecha
    final grouped = <String, List<TransactionModel>>{};
    for (final t in transactions) {
      final key = _dateKey(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
        AppConstants.paddingMedium,
        100,
      ),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final key = grouped.keys.elementAt(i);
        final dayTx = grouped[key]!;
        final dayTotal = dayTx.fold<double>(0.0, (sum, t) {
          return sum +
              (t.type == TransactionType.income ? t.amount : -t.amount);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(
                    key,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.formatShort(
                        dayTotal.abs(), currency: currency),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dayTotal >= 0
                          ? AppConstants.incomeColor
                          : AppConstants.expenseColor,
                    ),
                  ),
                ],
              ),
            ),
            ...dayTx.map(
              (t) => TransactionListItem(
                transaction: t,
                onTap: () => showDialog(
                  context: ctx,
                  builder: (_) => TransactionForm(
                    type: t.type,
                    transaction: t,
                  ),
                ),
                onDelete: () => Provider.of<TransactionProvider>(ctx,
                        listen: false)
                    .deleteTransaction(t),
              ),
            ),
          ],
        );
      },
    );
  }

  String _dateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Hoy';
    if (d == yesterday) return 'Ayer';
    return DateFormat('EEEE dd MMMM', 'es').format(date);
  }
}

// ── Quick Stat ────────────────────────────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _QuickStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Count Chip ────────────────────────────────────────────────────────────────
class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }
}

// ── Filter Sheet ──────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final TransactionProvider txProvider;
  final CategoryProvider catProvider;
  const _FilterSheet(
      {required this.txProvider, required this.catProvider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  TransactionType? _type;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _type       = widget.txProvider.typeFilter;
    _categoryId = widget.txProvider.categoryFilter;
  }

  void _apply() {
    widget.txProvider.setTypeFilter(_type);
    widget.txProvider.setCategoryFilter(_categoryId);
    Navigator.pop(context);
  }

  void _clear() {
    widget.txProvider.clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filtros',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                  onPressed: _clear, child: const Text('Limpiar')),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text('Tipo',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: _type == null,
                onSelected: (_) => setState(() => _type = null),
              ),
              FilterChip(
                label: const Text('Ingresos'),
                selected: _type == TransactionType.income,
                onSelected: (_) => setState(() => _type = TransactionType.income),
                selectedColor: AppConstants.incomeColor.withOpacity(0.2),
              ),
              FilterChip(
                label: const Text('Gastos'),
                selected: _type == TransactionType.expense,
                onSelected: (_) =>
                    setState(() => _type = TransactionType.expense),
                selectedColor: AppConstants.expenseColor.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text('Categoría',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: _categoryId == null,
                onSelected: (_) => setState(() => _categoryId = null),
              ),
              ...widget.catProvider.categories.map((c) => FilterChip(
                label: Text('${c.icon} ${c.name}'),
                selected: _categoryId == c.id,
                onSelected: (_) =>
                    setState(() => _categoryId = c.id),
                selectedColor: Color(c.colorValue).withOpacity(0.2),
              )),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              child: const Text('Aplicar filtros'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
