import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'accounts_screen.dart';
import 'goals_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded,           label: 'Inicio'),
    _NavItem(icon: Icons.receipt_long_rounded,    label: 'Movimientos'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Cuentas'),
    _NavItem(icon: Icons.savings_rounded,         label: 'Metas'),
    _NavItem(icon: Icons.bar_chart_rounded,       label: 'Estadísticas'),
    _NavItem(icon: Icons.settings_rounded,        label: 'Ajustes'),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AccountsScreen(),
    GoalsScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: isWide ? _buildWideLayout(isDark) : _screens[_selectedIndex],
      bottomNavigationBar: isWide ? null : _buildBottomNav(isDark),
    );
  }

  Widget _buildWideLayout(bool isDark) {
    return Row(
      children: [
        // ── Rail lateral ───────────────────────────────────────────────────
        Container(
          width: 220,
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkSurface : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark
                    ? AppConstants.darkBorder
                    : Colors.black.withOpacity(0.06),
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppConstants.primaryColor,
                            AppConstants.secondaryColor,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mis Finanzas',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'v2.0',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    final selected = _selectedIndex == i;
                    return _RailItem(
                      icon: item.icon,
                      label: item.label,
                      selected: selected,
                      onTap: () => setState(() => _selectedIndex = i),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Contenido principal ───────────────────────────────────────────
        Expanded(child: _screens[_selectedIndex]),
      ],
    );
  }

  Widget _buildBottomNav(bool isDark) {
    // Solo mostramos 5 tabs en el bottom nav; "Ajustes" queda en índice 5
    // Usamos NavigationBar con 5 elementos visibles
    final visible = _items.take(5).toList();

    return NavigationBar(
      selectedIndex: _selectedIndex < 5 ? _selectedIndex : 0,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      destinations: visible.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primaryColor.withOpacity(isDark ? 0.2 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? AppConstants.primaryColor
                  : (isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8)),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppConstants.primaryColor
                    : (isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
