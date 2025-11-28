import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction?.title ?? '');
    _amountController = TextEditingController(
      text: widget.transaction != null
          ? CurrencyFormatter.format(widget.transaction!.amount)
          : '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _selectedCategoryId = widget.transaction?.categoryId;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _isRecurring = widget.transaction?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);

      if (widget.transaction == null) {
        provider.addTransaction(
          title: _titleController.text,
          amount: CurrencyFormatter.parse(_amountController.text),
          type: widget.type,
          categoryId: _selectedCategoryId!,
          date: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isRecurring: _isRecurring,
        );
      } else {
        final updated = widget.transaction!.copyWith(
          title: _titleController.text,
          amount: CurrencyFormatter.parse(_amountController.text),
          categoryId: _selectedCategoryId!,
          date: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isRecurring: _isRecurring,
        );
        provider.updateTransaction(updated);
      }

      Navigator.pop(context);
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una categoría')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = widget.type == TransactionType.income
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  widget.transaction == null
                      ? 'Nuevo ${widget.type == TransactionType.income ? "Ingreso" : "Gasto"}'
                      : 'Editar ${widget.type == TransactionType.income ? "Ingreso" : "Gasto"}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej: Compra de mercado',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ingresa un título' : null,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    hintText: '0',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Ingresa un monto';
                    if (CurrencyFormatter.parse(value!) <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Añade detalles...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Gasto fijo mensual'),
                  value: _isRecurring,
                  onChanged: (value) => setState(() => _isRecurring = value),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                const Text(
                  'Categoría',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = _selectedCategoryId == category.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryId = category.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(category.colorValue)
                              : Color(category.colorValue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          border: Border.all(
                            color: Color(category.colorValue),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(category.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Color(category.colorValue),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(widget.transaction == null ? 'Guardar' : 'Actualizar'),
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
}
