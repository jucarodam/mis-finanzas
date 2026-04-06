import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/currency_input_formatter.dart';
import '../utils/constants.dart';

class TransactionForm extends StatefulWidget {
  final TransactionType type;
  final TransactionModel? transaction;

  const TransactionForm({
    Key? key,
    required this.type,
    this.transaction,
  }) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _titleController    = TextEditingController(text: t?.title ?? '');
    _amountController   = TextEditingController(
      text: t != null ? CurrencyFormatter.formatNumber(t.amount) : '',
    );
    _notesController    = TextEditingController(text: t?.notes ?? t?.description ?? '');
    _selectedCategoryId = t?.categoryId;
    _selectedAccountId  = t?.accountId;
    _selectedDate       = t?.date ?? DateTime.now();
    _isRecurring        = t?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppConstants.primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona una categoría',
              style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        ),
      );
      return;
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final amount = CurrencyFormatter.parse(_amountController.text);
    final notes =
        _notesController.text.isEmpty ? null : _notesController.text;

    if (widget.transaction == null) {
      provider.addTransaction(
        title:       _titleController.text.trim(),
        amount:      amount,
        type:        widget.type,
        categoryId:  _selectedCategoryId!,
        date:        _selectedDate,
        isRecurring: _isRecurring,
        accountId:   _selectedAccountId,
        notes:       notes,
      );
    } else {
      final updated = widget.transaction!.copyWith(
        title:       _titleController.text.trim(),
        amount:      amount,
        categoryId:  _selectedCategoryId!,
        date:        _selectedDate,
        isRecurring: _isRecurring,
        accountId:   _selectedAccountId,
        notes:       notes,
      );
      provider.updateTransaction(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final accountProvider  = Provider.of<AccountProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = widget.type == TransactionType.income;

    final categories = isIncome
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    final accentColor =
        isIncome ? AppConstants.incomeColor : AppConstants.expenseColor;
    final label =
        widget.transaction == null ? 'Nuevo' : 'Editar';
    final typeLabel = isIncome ? 'Ingreso' : 'Gasto';

    return Dialog(
      backgroundColor:
          isDark ? AppConstants.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.15),
                    accentColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusXXL),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$label $typeLabel',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulario ─────────────────────────────────────────────────
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Ej: Compra de mercado',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'Ingresa un título' : null,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Monto
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Monto *',
                        hintText: '0',
                        prefixIcon:
                            const Icon(Icons.attach_money_rounded),
                        prefixText:
                            '${CurrencyFormatter.symbol(settingsProvider.currency)} ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Ingresa un monto';
                        if (CurrencyFormatter.parse(v!) <= 0) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Cuenta (si hay cuentas creadas)
                    if (accountProvider.accounts.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Cuenta (opcional)',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sin cuenta específica'),
                          ),
                          ...accountProvider.accounts.map((a) =>
                              DropdownMenuItem(
                                value: a.id,
                                child: Row(
                                  children: [
                                    Text(a.icon),
                                    const SizedBox(width: 8),
                                    Text(a.name),
                                  ],
                                ),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedAccountId = v),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                    ],

                    // Fecha
                    InkWell(
                      onTap: _selectDate,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLarge),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Notas
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        hintText: 'Añade detalles...',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Gasto fijo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppConstants.darkCard
                            : const Color(0xFFF8FAFC),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLarge),
                        border: Border.all(
                          color: isDark
                              ? AppConstants.darkBorder
                              : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Recurrente mensual',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Se repite cada mes',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        value: _isRecurring,
                        onChanged: (v) => setState(() => _isRecurring = v),
                        activeColor: accentColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // ── Categorías ─────────────────────────────────────────
                    Text(
                      'Categoría *',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final selected = _selectedCategoryId == cat.id;
                        final catColor = Color(cat.colorValue);
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedCategoryId = cat.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? catColor
                                  : catColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium),
                              border: Border.all(
                                color: catColor,
                                width: selected ? 0 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat.icon,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? Colors.white
                                        : catColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.paddingXL),

                    // ── Botones ────────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                            ),
                            child: Text(
                              widget.transaction == null
                                  ? 'Guardar'
                                  : 'Actualizar',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
