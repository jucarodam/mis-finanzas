import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Categorías',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Gastos',   icon: Icon(Icons.arrow_upward_rounded)),
              Tab(text: 'Ingresos', icon: Icon(Icons.arrow_downward_rounded)),
            ],
            labelStyle: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600),
            indicatorColor: AppConstants.primaryColor,
            labelColor: AppConstants.primaryColor,
          ),
        ),
        body: TabBarView(
          children: [
            _CatGrid(cats: provider.expenseCategories, isExpense: true),
            _CatGrid(cats: provider.incomeCategories,  isExpense: false),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const _CategoryForm(),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text('Nueva',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ── Category Grid ─────────────────────────────────────────────────────────────
class _CatGrid extends StatelessWidget {
  final List<CategoryModel> cats;
  final bool isExpense;
  const _CatGrid({required this.cats, required this.isExpense});

  @override
  Widget build(BuildContext context) {
    if (cats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗂️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Sin categorías',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: cats.length,
      itemBuilder: (ctx, i) => _CatCard(cat: cats[i])
          .animate()
          .fadeIn(delay: (i * 40).ms)
          .scale(begin: const Offset(0.92, 0.92)),
    );
  }
}

// ── Category Card ─────────────────────────────────────────────────────────────
class _CatCard extends StatelessWidget {
  final CategoryModel cat;
  const _CatCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final color = Color(cat.colorValue);

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _CategoryForm(category: cat),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(cat.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cat.name,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Form ─────────────────────────────────────────────────────────────
class _CategoryForm extends StatefulWidget {
  final CategoryModel? category;
  const _CategoryForm({this.category});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late String _icon;
  late Color _color;
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.category?.name ?? '');
    _icon      = widget.category?.icon ?? AppConstants.categoryIcons[0];
    _color     = widget.category != null
        ? Color(widget.category!.colorValue)
        : AppConstants.primaryColor;
    _isExpense = widget.category?.isExpense ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final p = Provider.of<CategoryProvider>(context, listen: false);
    if (widget.category == null) {
      p.addCategory(
          name: _nameCtrl.text.trim(),
          icon: _icon,
          colorValue: _color.value,
          isExpense: _isExpense);
    } else {
      p.updateCategory(widget.category!.copyWith(
          name: _nameCtrl.text.trim(),
          icon: _icon,
          colorValue: _color.value,
          isExpense: _isExpense));
    }
    Navigator.pop(context);
  }

  void _delete() {
    Provider.of<CategoryProvider>(context, listen: false)
        .deleteCategory(widget.category!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.category != null;

    return Dialog(
      backgroundColor: isDark ? AppConstants.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusXXL)),
              ),
              child: Row(
                children: [
                  Text(_icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit ? 'Editar categoría' : 'Nueva categoría',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (isEdit)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppConstants.expenseColor),
                      onPressed: () => _confirmDelete(context),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.all(AppConstants.paddingLarge),
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        prefixIcon: Icon(Icons.label_outline_rounded),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Tipo
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
                                : Colors.black.withOpacity(0.08)),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Tipo',
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          _isExpense ? 'Gasto' : 'Ingreso',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _isExpense
                                  ? AppConstants.expenseColor
                                  : AppConstants.incomeColor),
                        ),
                        value: _isExpense,
                        onChanged: (v) => setState(() => _isExpense = v),
                        activeColor: AppConstants.expenseColor,
                        inactiveThumbColor: AppConstants.incomeColor,
                        inactiveTrackColor:
                            AppConstants.incomeColor.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Color
                    Text('Color',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Selecciona un color'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: _color,
                              onColorChanged: (c) {
                                setState(() => _color = c);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _color,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusLarge),
                        ),
                        child: Center(
                          child: Text(
                            'Tocar para cambiar color',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Íconos
                    Text('Ícono',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AppConstants.categoryIcons.map((ico) {
                        final sel = _icon == ico;
                        return GestureDetector(
                          onTap: () => setState(() => _icon = ico),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: sel
                                  ? _color
                                  : _color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium),
                              border: Border.all(
                                color: _color,
                                width: sel ? 0 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(ico,
                                  style:
                                      const TextStyle(fontSize: 22)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.paddingXL),

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
                                backgroundColor: _color),
                            child: Text(
                                isEdit ? 'Actualizar' : 'Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content:
            Text('¿Eliminar "${widget.category!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _delete();
            },
            style: TextButton.styleFrom(
                foregroundColor: AppConstants.expenseColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
