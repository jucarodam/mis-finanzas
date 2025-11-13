import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/constants.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_form.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final incomes = transactionProvider.incomes;

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final monthlyIncome = transactionProvider.getTotalIncome(currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos'),
      ),
      body: Column(
        children: [
          // Resumen de ingresos
          Container(
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.successColor, AppConstants.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingresos este mes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(monthlyIncome),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${incomes.where((t) => t.date.month == now.month && t.date.year == now.year).length} transacciones',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de ingresos
          Expanded(
            child: incomes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay ingresos registrados',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      final transaction = incomes[index];
                      return TransactionListItem(
                        transaction: transaction,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => TransactionForm(
                              type: TransactionType.income,
                              transaction: transaction,
                            ),
                          );
                        },
                        onDelete: () {
                          _confirmDelete(context, transaction, transactionProvider);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const TransactionForm(
              type: TransactionType.income,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Ingreso'),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TransactionModel transaction,
    TransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTransaction(transaction);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
