import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';
import '../providers/settings_provider.dart';
import '../models/goal_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoalProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final currency = settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Metas',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('Nueva',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            onPressed: () => _showGoalForm(context, provider, settings),
          ),
        ],
      ),

      body: provider.goals.isEmpty
          ? _EmptyState(
              onAdd: () => _showGoalForm(context, provider, settings))
          : CustomScrollView(
              slivers: [
                // Resumen
                SliverToBoxAdapter(
                  child: _GoalsSummary(
                    provider: provider,
                    currency: currency,
                    isDark: isDark,
                  ).animate().fadeIn(duration: 400.ms),
                ),

                // Metas activas
                if (provider.activeGoals.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingMedium,
                      AppConstants.paddingSmall,
                      AppConstants.paddingMedium,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                        child: Text(
                          'En progreso',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _GoalCard(
                        goal: provider.activeGoals[i],
                        currency: currency,
                        isDark: isDark,
                        onEdit: () => _showGoalForm(ctx, provider, settings,
                            goal: provider.activeGoals[i]),
                        onDelete: () => provider
                            .deleteGoal(provider.activeGoals[i].id),
                        onAddMoney: () => _showAddMoneyDialog(
                            ctx, provider, provider.activeGoals[i]),
                      ).animate().fadeIn(delay: (i * 60).ms),
                      childCount: provider.activeGoals.length,
                    ),
                  ),
                ),

                // Metas completadas
                if (provider.completedGoals.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingMedium,
                      AppConstants.paddingLarge,
                      AppConstants.paddingMedium,
                      AppConstants.paddingSmall,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Completadas ✅',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingMedium,
                      0,
                      AppConstants.paddingMedium,
                      100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _GoalCard(
                          goal: provider.completedGoals[i],
                          currency: currency,
                          isDark: isDark,
                          onEdit: () {},
                          onDelete: () => provider
                              .deleteGoal(provider.completedGoals[i].id),
                          onAddMoney: null,
                        ),
                        childCount: provider.completedGoals.length,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  void _showGoalForm(
    BuildContext context,
    GoalProvider provider,
    SettingsProvider settings, {
    GoalModel? goal,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _GoalFormSheet(
        provider: provider,
        settings: settings,
        goal: goal,
      ),
    );
  }

  void _showAddMoneyDialog(
      BuildContext context, GoalProvider provider, GoalModel goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Agregar a "${goal.name}"',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monto a agregar',
            prefixIcon: Icon(Icons.add_rounded),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                provider.addAmount(goal.id, amount);
              }
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

// ── Goals Summary ─────────────────────────────────────────────────────────────
class _GoalsSummary extends StatelessWidget {
  final GoalProvider provider;
  final String currency;
  final bool isDark;
  const _GoalsSummary(
      {required this.provider, required this.currency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total   = provider.totalTargetAmount;
    final current = provider.totalCurrentAmount;
    final pct = total > 0 ? current / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.savingsColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso total',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                CurrencyFormatter.formatShort(current, currency: currency),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                ' / ${CurrencyFormatter.formatShort(total, currency: currency)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Text(
                '${provider.activeGoals.length} activas',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final String currency;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddMoney;

  const _GoalCard({
    required this.goal,
    required this.currency,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    final color   = Color(goal.colorValue);
    final pct     = goal.progress;
    final daysLeft = goal.daysLeft;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Center(
                  child: Text(goal.icon,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    if (daysLeft != null)
                      Text(
                        daysLeft > 0
                            ? '$daysLeft días restantes'
                            : goal.isCompleted
                                ? '¡Completada!'
                                : 'Plazo vencido',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: daysLeft > 0
                              ? color
                              : goal.isCompleted
                                  ? AppConstants.incomeColor
                                  : AppConstants.expenseColor,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (onAddMoney != null)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                      color: color,
                      onPressed: onAddMoney,
                      style: IconButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onPressed: () => _showOptions(context),
                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.formatShort(goal.currentAmount,
                              currency: goal.currency),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}% de ${CurrencyFormatter.formatShort(goal.targetAmount, currency: goal.currency)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? const Color(0xFF2D2D3F)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation(
                            goal.isCompleted ? AppConstants.incomeColor : color),
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
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar meta'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppConstants.expenseColor),
              title: const Text('Eliminar',
                  style: TextStyle(color: AppConstants.expenseColor)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Sin metas creadas',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define metas de ahorro y\nseguimiento su progreso',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear meta'),
          ),
        ],
      ),
    );
  }
}

// ── Goal Form Sheet ───────────────────────────────────────────────────────────
class _GoalFormSheet extends StatefulWidget {
  final GoalProvider provider;
  final SettingsProvider settings;
  final GoalModel? goal;

  const _GoalFormSheet({
    required this.provider,
    required this.settings,
    this.goal,
  });

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  DateTime? _deadline;
  Color _color = const Color(0xFF8B5CF6);
  String _icon = '🎯';
  String _currency = 'COP';

  static const List<String> _goalIcons = [
    '🎯', '🏠', '🚗', '✈️', '💻', '📱', '💍', '🎓',
    '💰', '🏖️', '🎸', '🐕', '⚽', '🏋️', '📚', '🌍',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _nameController    = TextEditingController(text: g?.name ?? '');
    _targetController  = TextEditingController(
        text: g != null ? g.targetAmount.toStringAsFixed(0) : '');
    _currentController = TextEditingController(
        text: g != null ? g.currentAmount.toStringAsFixed(0) : '');
    _deadline = g?.deadline;
    _color    = g != null ? Color(g.colorValue) : const Color(0xFF8B5CF6);
    _icon     = g?.icon ?? '🎯';
    _currency = g?.currency ?? widget.settings.currency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _deadline = date);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final target  = double.tryParse(_targetController.text) ?? 0;
    final current = double.tryParse(_currentController.text) ?? 0;
    if (widget.goal == null) {
      widget.provider.addGoal(
        name:          _nameController.text.trim(),
        targetAmount:  target,
        currentAmount: current,
        deadline:      _deadline,
        colorValue:    _color.value,
        icon:          _icon,
        currency:      _currency,
      );
    } else {
      final updated = widget.goal!.copyWith(
        name:          _nameController.text.trim(),
        targetAmount:  target,
        currentAmount: current,
        deadline:      _deadline,
        colorValue:    _color.value,
        icon:          _icon,
        currency:      _currency,
      );
      widget.provider.updateGoal(updated);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.goal != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(isEdit ? 'Editar meta' : 'Nueva meta',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la meta',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetController,
                      decoration: const InputDecoration(
                        labelText: 'Meta objetivo',
                        prefixIcon: Icon(Icons.flag_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Requerido';
                        if ((double.tryParse(v!) ?? 0) <= 0) {
                          return 'Ingresa un valor';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _currentController,
                      decoration: const InputDecoration(
                        labelText: 'Ya tengo',
                        prefixIcon: Icon(Icons.savings_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Divisa
              DropdownButtonFormField<String>(
                value: _currency,
                decoration: const InputDecoration(
                  labelText: 'Divisa',
                  prefixIcon: Icon(Icons.currency_exchange_rounded),
                ),
                items: AppConstants.supportedCurrencies.map((c) {
                  return DropdownMenuItem(
                    value: c['code'],
                    child: Text('${c['flag']} ${c['code']}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _currency = v ?? 'COP'),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Fecha límite
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha límite (opcional)',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                    suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                  ),
                  child: Text(
                    _deadline != null
                        ? DateFormat('dd/MM/yyyy').format(_deadline!)
                        : 'Sin fecha límite',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              ),
              if (_deadline != null) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Quitar fecha'),
                  onPressed: () => setState(() => _deadline = null),
                  style: TextButton.styleFrom(
                      foregroundColor: AppConstants.expenseColor,
                      padding: EdgeInsets.zero),
                ),
              ],
              const SizedBox(height: AppConstants.paddingMedium),

              // Íconos
              Text('Ícono',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goalIcons.map((ico) {
                  return GestureDetector(
                    onTap: () => setState(() => _icon = ico),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _icon == ico
                            ? _color.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _icon == ico
                            ? Border.all(color: _color, width: 2)
                            : Border.all(
                                color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(ico,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Colores
              Text('Color',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: AppConstants.accountColors.map((c) {
                  final col = Color(c);
                  return GestureDetector(
                    onTap: () => setState(() => _color = col),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: col,
                        shape: BoxShape.circle,
                        border: _color == col
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: _color == col
                            ? [
                                BoxShadow(
                                    color: col.withOpacity(0.4),
                                    blurRadius: 6)
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                  ),
                  child: Text(isEdit ? 'Guardar cambios' : 'Crear meta'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
