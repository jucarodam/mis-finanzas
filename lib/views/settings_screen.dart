import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/services.dart';
import '../utils/currency_formatter.dart';
import '../utils/currency_input_formatter.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          // Tema
          Card(
            child: SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: const Text('Activa el tema oscuro'),
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Presupuesto
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet),
                      const SizedBox(width: 12),
                      Text(
                        'Presupuesto',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Límite mensual'),
                    subtitle: Text(
                      settingsProvider.monthlyLimit > 0
                          ? '\$${settingsProvider.monthlyLimit.toStringAsFixed(0)}'
                          : 'Sin límite configurado',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showMonthlyLimitDialog(context, settingsProvider),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Porcentaje de advertencia'),
                    subtitle: Text('${settingsProvider.warningPercentage.toStringAsFixed(0)}%'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showWarningPercentageDialog(context, settingsProvider),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Información de la app
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 12),
                      Text(
                        'Acerca de',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Versión'),
                    subtitle: Text('1.0.0'),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Desarrollado con'),
                    subtitle: Text('Flutter Web + Material 3'),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Moneda'),
                    subtitle: Text('Pesos colombianos (COP)'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthlyLimitDialog(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(
      text: provider.monthlyLimit > 0
          ? CurrencyFormatter.format(provider.monthlyLimit)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Límite mensual'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: 'Monto',
            prefixText: '\$ ',
            hintText: 'Ej: 5.000.000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = CurrencyFormatter.parse(controller.text);
              provider.updateMonthlyLimit(value);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showWarningPercentageDialog(BuildContext context, SettingsProvider provider) {
    double currentValue = provider.warningPercentage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Porcentaje de advertencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${currentValue.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: currentValue,
                min: 50,
                max: 100,
                divisions: 10,
                label: '${currentValue.toStringAsFixed(0)}%',
                onChanged: (value) {
                  setState(() => currentValue = value);
                },
              ),
              const Text(
                'Recibirás una advertencia cuando tus gastos alcancen este porcentaje del límite mensual',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.updateWarningPercentage(currentValue);
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
