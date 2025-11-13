import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'income_screen.dart';
import 'expense_screen.dart';
import 'categories_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    IncomeScreen(),
    ExpenseScreen(),
    CategoriesScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  final List<_NavigationItem> _navigationItems = const [
    _NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavigationItem(
      icon: Icons.arrow_downward,
      label: 'Ingresos',
    ),
    _NavigationItem(
      icon: Icons.arrow_upward,
      label: 'Gastos',
    ),
    _NavigationItem(
      icon: Icons.category,
      label: 'Categorías',
    ),
    _NavigationItem(
      icon: Icons.bar_chart,
      label: 'Estadísticas',
    ),
    _NavigationItem(
      icon: Icons.settings,
      label: 'Configuración',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: _navigationItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
              leading: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppConstants.primaryColor,
                            AppConstants.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mis\nFinanzas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: _navigationItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;

  const _NavigationItem({
    required this.icon,
    required this.label,
  });
}
