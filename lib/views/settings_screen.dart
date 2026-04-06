import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/currency_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/currency_input_formatter.dart';
import '../utils/constants.dart';
import 'categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings  = Provider.of<SettingsProvider>(context);
    final theme     = Provider.of<ThemeProvider>(context);
    final currency  = Provider.of<CurrencyProvider>(context);
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall),
        children: [

          // ── Apariencia ──────────────────────────────────────────────────
          _GroupHeader('Apariencia', isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: Icon(
                  theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppConstants.primaryColor,
                ),
                title: Text('Modo oscuro',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  theme.isDarkMode ? 'Tema oscuro activo' : 'Tema claro activo',
                  style: GoogleFonts.inter(fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
                value: theme.isDarkMode,
                onChanged: (_) => theme.toggleTheme(),
                activeColor: AppConstants.primaryColor,
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // ── Divisa ──────────────────────────────────────────────────────
          _GroupHeader('Divisa y tasas de cambio', isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              // Selector de divisa principal
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.currency_exchange_rounded,
                      color: AppConstants.accentColor, size: 18),
                ),
                title: Text('Divisa principal',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  '${currency.getFlag(settings.currency)}  ${settings.currency} — ${currency.getName(settings.currency)}',
                  style: GoogleFonts.inter(fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showCurrencyPicker(context, settings, currency),
              ),
              const Divider(height: 1, indent: 56),

              // Tasas de cambio rápidas
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppConstants.savingsColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: AppConstants.savingsColor, size: 18),
                ),
                title: Text('Ver tasas de cambio',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  currency.lastFetched != null
                      ? 'Actualizado: ${_timeAgo(currency.lastFetched!)}'
                      : 'Usando tasas de reserva',
                  style: GoogleFonts.inter(fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
                trailing: currency.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right_rounded),
                onTap: () => _showRatesSheet(context, currency, settings.currency),
              ),

              // Conversor rápido
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppConstants.warningColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: AppConstants.warningColor, size: 18),
                ),
                title: Text('Conversor de divisas',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('Convierte entre cualquier moneda',
                    style: GoogleFonts.inter(fontSize: 12,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showConverterSheet(context, currency),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // ── Presupuesto ─────────────────────────────────────────────────
          _GroupHeader('Presupuesto mensual', isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _BudgetLimitTile(settings: settings, isDark: isDark),
              const Divider(height: 1, indent: 56),
              _WarningThresholdTile(settings: settings, isDark: isDark),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // ── Datos ───────────────────────────────────────────────────────
          _GroupHeader('Datos', isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.category_rounded,
                      color: AppConstants.primaryColor, size: 18),
                ),
                title: Text('Categorías',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('Gestionar categorías de ingresos y gastos',
                    style: GoogleFonts.inter(fontSize: 12,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CategoriesScreen())),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // ── Acerca de ───────────────────────────────────────────────────
          _GroupHeader('Acerca de', isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 18),
                ),
                title: Text('Mis Finanzas',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('Versión 2.0.0 — Flutter Web',
                    style: GoogleFonts.inter(fontSize: 12,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} días';
  }

  void _showCurrencyPicker(
      BuildContext context, SettingsProvider settings, CurrencyProvider cp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _CurrencyPickerSheet(
        settings: settings,
        currencyProvider: cp,
      ),
    );
  }

  void _showRatesSheet(
      BuildContext context, CurrencyProvider cp, String baseCurrency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _RatesSheet(
        currencyProvider: cp,
        baseCurrency: baseCurrency,
      ),
    );
  }

  void _showConverterSheet(BuildContext context, CurrencyProvider cp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL)),
      ),
      builder: (_) => _ConverterSheet(currencyProvider: cp),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de apoyo
// ─────────────────────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String text;
  final bool isDark;
  const _GroupHeader(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ── Budget Limit ──────────────────────────────────────────────────────────────
class _BudgetLimitTile extends StatefulWidget {
  final SettingsProvider settings;
  final bool isDark;
  const _BudgetLimitTile({required this.settings, required this.isDark});

  @override
  State<_BudgetLimitTile> createState() => _BudgetLimitTileState();
}

class _BudgetLimitTileState extends State<_BudgetLimitTile> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.settings.monthlyLimit > 0
          ? widget.settings.monthlyLimit.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppConstants.incomeColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.account_balance_wallet_outlined,
            color: AppConstants.incomeColor, size: 18),
      ),
      title: Text('Límite mensual',
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(
        widget.settings.monthlyLimit > 0
            ? CurrencyFormatter.formatShort(widget.settings.monthlyLimit,
                currency: widget.settings.currency)
            : 'Sin límite configurado',
        style: GoogleFonts.inter(fontSize: 12,
            color: widget.isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8)),
      ),
      trailing: const Icon(Icons.edit_outlined, size: 18),
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Límite mensual',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Límite (${widget.settings.currency})',
              hintText: '0',
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
                final val = CurrencyFormatter.parse(_ctrl.text);
                widget.settings.updateMonthlyLimit(val);
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Warning Threshold ─────────────────────────────────────────────────────────
class _WarningThresholdTile extends StatefulWidget {
  final SettingsProvider settings;
  final bool isDark;
  const _WarningThresholdTile(
      {required this.settings, required this.isDark});

  @override
  State<_WarningThresholdTile> createState() =>
      _WarningThresholdTileState();
}

class _WarningThresholdTileState extends State<_WarningThresholdTile> {
  late double _pct;

  @override
  void initState() {
    super.initState();
    _pct = widget.settings.warningPercentage;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppConstants.warningColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.warning_amber_rounded,
            color: AppConstants.warningColor, size: 18),
      ),
      title: Text('Alerta de gasto',
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(
        'Alertar al ${widget.settings.warningPercentage.toStringAsFixed(0)}% del límite',
        style: GoogleFonts.inter(fontSize: 12,
            color: widget.isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8)),
      ),
      trailing: const Icon(Icons.edit_outlined, size: 18),
      onTap: () => showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setModalState) => AlertDialog(
            title: Text('Umbral de alerta',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_pct.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.warningColor,
                  ),
                ),
                Slider(
                  value: _pct,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  activeColor: AppConstants.warningColor,
                  onChanged: (v) => setModalState(() => _pct = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.settings.updateWarningPercentage(_pct);
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Currency Picker Sheet ─────────────────────────────────────────────────────
class _CurrencyPickerSheet extends StatelessWidget {
  final SettingsProvider settings;
  final CurrencyProvider currencyProvider;
  const _CurrencyPickerSheet(
      {required this.settings, required this.currencyProvider});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Seleccionar divisa',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              itemCount: AppConstants.supportedCurrencies.length,
              itemBuilder: (_, i) {
                final c = AppConstants.supportedCurrencies[i];
                final isSelected = settings.currency == c['code'];
                return ListTile(
                  leading: Text(c['flag']!,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(
                    '${c['code']} — ${c['name']}',
                    style: GoogleFonts.inter(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 14,
                      color: isSelected
                          ? AppConstants.primaryColor
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    '1 USD = ${currencyProvider.getRate('USD', c['code']!).toStringAsFixed(2)} ${c['code']}',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppConstants.primaryColor)
                      : null,
                  onTap: () {
                    settings.updateCurrency(c['code']!);
                    currencyProvider.setDisplayCurrency(c['code']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rates Sheet ───────────────────────────────────────────────────────────────
class _RatesSheet extends StatelessWidget {
  final CurrencyProvider currencyProvider;
  final String baseCurrency;
  const _RatesSheet(
      {required this.currencyProvider, required this.baseCurrency});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Tasas de cambio',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Actualizar'),
                      onPressed: () => currencyProvider.fetchRates(),
                    ),
                  ],
                ),
                Text(
                  'Base: 1 $baseCurrency',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              itemCount: AppConstants.supportedCurrencies.length,
              itemBuilder: (_, i) {
                final c = AppConstants.supportedCurrencies[i];
                if (c['code'] == baseCurrency) return const SizedBox.shrink();
                final rate = currencyProvider.getRate(baseCurrency, c['code']!);
                return ListTile(
                  leading: Text(c['flag']!,
                      style: const TextStyle(fontSize: 22)),
                  title: Text(
                    c['code']!,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(c['name']!,
                      style: GoogleFonts.inter(fontSize: 12)),
                  trailing: Text(
                    '${CurrencyFormatter.symbol(c['code']!)} ${rate.toStringAsFixed(4)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Converter Sheet ───────────────────────────────────────────────────────────
class _ConverterSheet extends StatefulWidget {
  final CurrencyProvider currencyProvider;
  const _ConverterSheet({required this.currencyProvider});

  @override
  State<_ConverterSheet> createState() => _ConverterSheetState();
}

class _ConverterSheetState extends State<_ConverterSheet> {
  final _ctrl = TextEditingController(text: '1');
  String _from = 'USD';
  String _to   = 'COP';

  double get _result {
    final amount = double.tryParse(_ctrl.text.replaceAll(',', '')) ?? 0;
    return widget.currencyProvider.convert(amount, from: _from, to: _to);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Conversor de divisas',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),

            // Monto
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: Text(
                  CurrencyFormatter.symbol(_from),
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // From → To
            Row(
              children: [
                Expanded(child: _CurrencyDropdown(
                  value: _from,
                  onChanged: (v) => setState(() => _from = v),
                  isDark: isDark,
                )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.swap_horiz_rounded,
                      color: AppConstants.primaryColor),
                ),
                Expanded(child: _CurrencyDropdown(
                  value: _to,
                  onChanged: (v) => setState(() => _to = v),
                  isDark: isDark,
                )),
              ],
            ),

            const SizedBox(height: 24),

            // Resultado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              ),
              child: Column(
                children: [
                  Text(
                    '${_ctrl.text.isEmpty ? '0' : _ctrl.text} $_from =',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyFormatter.symbol(_to)} ${_result.toStringAsFixed(
                        _to == 'COP' || _to == 'CLP' || _to == 'JPY' ? 0 : 2)}',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _to,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              '1 $_from = ${CurrencyFormatter.symbol(_to)} ${widget.currencyProvider.getRate(_from, _to).toStringAsFixed(4)} $_to',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool isDark;
  const _CurrencyDropdown(
      {required this.value, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppConstants.darkBorder
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: AppConstants.supportedCurrencies.map((c) {
            return DropdownMenuItem(
              value: c['code'],
              child: Text(
                '${c['flag']} ${c['code']}',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}
