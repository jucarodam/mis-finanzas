import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../models/account_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider  = Provider.of<AccountProvider>(context);
    final settings  = Provider.of<SettingsProvider>(context);
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final currency  = settings.currency;
    final accounts  = provider.accounts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Cuentas',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('Nueva',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            onPressed: () => _showAccountForm(context, provider, settings),
          ),
        ],
      ),

      body: accounts.isEmpty
          ? _EmptyState(
              onAdd: () => _showAccountForm(context, provider, settings))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _NetWorthCard(
                    provider: provider,
                    currency: currency,
                    isDark: isDark,
                  ).animate().fadeIn(duration: 400.ms),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingMedium,
                    AppConstants.paddingMedium,
                    AppConstants.paddingMedium,
                    100,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _AccountCard(
                        account: accounts[i],
                        currency: currency,
                        isDark: isDark,
                        onEdit: () => _showAccountForm(
                            context, provider, settings,
                            account: accounts[i]),
                        onDelete: () =>
                            provider.deleteAccount(accounts[i].id),
                      ).animate().fadeIn(delay: (i * 60).ms),
                      childCount: accounts.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAccountForm(
    BuildContext context,
    AccountProvider provider,
    SettingsProvider settings, {
    AccountModel? account,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _AccountFormSheet(
        provider: provider,
        settings: settings,
        account: account,
      ),
    );
  }
}

// ── Net Worth Card ────────────────────────────────────────────────────────────
class _NetWorthCard extends StatelessWidget {
  final AccountProvider provider;
  final String currency;
  final bool isDark;
  const _NetWorthCard(
      {required this.provider,
      required this.currency,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total   = provider.totalBalance;
    final netWorth = provider.netWorth;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patrimonio neto',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(netWorth, currency: currency),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          if (total != netWorth) ...[
            const SizedBox(height: 4),
            Text(
              'Balance total: ${CurrencyFormatter.formatShort(total, currency: currency)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: [
              _StatPill(
                label: 'Cuentas',
                value:
                    '${provider.accounts.where((a) => a.type != AccountType.credit).length}',
              ),
              const SizedBox(width: 12),
              _StatPill(
                label: 'Créditos',
                value:
                    '${provider.accounts.where((a) => a.type == AccountType.credit).length}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account Card ──────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final String currency;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountCard({
    required this.account,
    required this.currency,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(account.colorValue);

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
      child: Row(
        children: [
          // Ícono
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Center(
              child: Text(account.icon,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        account.typeName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      account.currency,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(account.balance,
                    currency: account.currency),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: account.balance >= 0
                      ? color
                      : AppConstants.expenseColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit,
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 28),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _confirmDelete(context),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 28),
                      foregroundColor: AppConstants.expenseColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Text('¿Eliminar "${account.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style:
                TextButton.styleFrom(foregroundColor: AppConstants.expenseColor),
            child: const Text('Eliminar'),
          ),
        ],
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
          const Text('🏦', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Sin cuentas registradas',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tus cuentas bancarias,\nefectivo o tarjetas',
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
            label: const Text('Agregar cuenta'),
          ),
        ],
      ),
    );
  }
}

// ── Account Form Sheet ────────────────────────────────────────────────────────
class _AccountFormSheet extends StatefulWidget {
  final AccountProvider provider;
  final SettingsProvider settings;
  final AccountModel? account;

  const _AccountFormSheet({
    required this.provider,
    required this.settings,
    this.account,
  });

  @override
  State<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  AccountType _type = AccountType.cash;
  String _icon = '💵';
  Color _color = const Color(0xFF6366F1);
  String _currency = 'COP';

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController    = TextEditingController(text: a?.name ?? '');
    _balanceController = TextEditingController(
        text: a != null ? a.balance.toStringAsFixed(0) : '');
    _type     = a?.type ?? AccountType.cash;
    _icon     = a?.icon ?? '💵';
    _color    = a != null ? Color(a.colorValue) : const Color(0xFF6366F1);
    _currency = a?.currency ?? widget.settings.currency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final balance = double.tryParse(
            _balanceController.text.replaceAll(',', '').replaceAll('.', '')) ??
        0.0;
    if (widget.account == null) {
      widget.provider.addAccount(
        name:       _nameController.text.trim(),
        type:       _type,
        balance:    balance,
        colorValue: _color.value,
        icon:       _icon,
        currency:   _currency,
      );
    } else {
      final updated = widget.account!.copyWith(
        name:       _nameController.text.trim(),
        type:       _type,
        balance:    balance,
        colorValue: _color.value,
        icon:       _icon,
        currency:   _currency,
      );
      widget.provider.updateAccount(updated);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.account != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(isEdit ? 'Editar cuenta' : 'Nueva cuenta',
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

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la cuenta',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Balance inicial
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Balance actual',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Tipo de cuenta
              Text('Tipo de cuenta',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AccountType.values.map((t) {
                  final selected = _type == t;
                  return ChoiceChip(
                    label: Text(_typeName(t)),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _type = t;
                      _icon = _typeIcon(t);
                    }),
                    selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                  );
                }).toList(),
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
                    child: Text('${c['flag']} ${c['code']} - ${c['name']}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _currency = v ?? 'COP'),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Color e ícono
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: AppConstants.accountColors.map((c) {
                            final col = Color(c);
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _color = col),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  border: _color == col
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ícono',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: AppConstants.accountIcons.map((ico) {
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _icon = ico),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _icon == ico
                                    ? _color.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(8),
                                border: _icon == ico
                                    ? Border.all(color: _color)
                                    : null,
                              ),
                              child: Center(
                                child: Text(ico,
                                    style:
                                        const TextStyle(fontSize: 20)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Guardar cambios' : 'Agregar cuenta'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _typeName(AccountType t) {
    switch (t) {
      case AccountType.cash:       return 'Efectivo';
      case AccountType.bank:       return 'Bancaria';
      case AccountType.credit:     return 'Crédito';
      case AccountType.savings:    return 'Ahorros';
      case AccountType.investment: return 'Inversión';
    }
  }

  String _typeIcon(AccountType t) {
    switch (t) {
      case AccountType.cash:       return '💵';
      case AccountType.bank:       return '🏦';
      case AccountType.credit:     return '💳';
      case AccountType.savings:    return '🏧';
      case AccountType.investment: return '📈';
    }
  }
}
