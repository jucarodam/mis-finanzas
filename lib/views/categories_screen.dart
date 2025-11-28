import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Gastos', icon: Icon(Icons.shopping_cart)),
              Tab(text: 'Ingresos', icon: Icon(Icons.attach_money)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CategoryList(
              categories: categoryProvider.expenseCategories,
              isExpense: true,
            ),
            _CategoryList(
              categories: categoryProvider.incomeCategories,
              isExpense: false,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const _CategoryForm(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Nueva Categoría'),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isExpense;

  const _CategoryList({
    required this.categories,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay categorías',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: AppConstants.paddingMedium,
        crossAxisSpacing: AppConstants.paddingMedium,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(category: category);
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return Card(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _CategoryForm(category: category),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryForm extends StatefulWidget {
  final CategoryModel? category;

  const _CategoryForm({this.category});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedIcon;
  late Color _selectedColor;
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? AppConstants.categoryIcons[0];
    _selectedColor = widget.category != null
        ? Color(widget.category!.colorValue)
        : AppConstants.primaryColor;
    _isExpense = widget.category?.isExpense ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);

      if (widget.category == null) {
        provider.addCategory(
          name: _nameController.text,
          icon: _selectedIcon,
          colorValue: _selectedColor.value,
          isExpense: _isExpense,
        );
      } else {
        final updated = widget.category!.copyWith(
          name: _nameController.text,
          icon: _selectedIcon,
          colorValue: _selectedColor.value,
          isExpense: _isExpense,
        );
        provider.updateCategory(updated);
      }

      Navigator.pop(context);
    }
  }

  void _delete() {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    provider.deleteCategory(widget.category!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.category == null ? 'Nueva Categoría' : 'Editar Categoría',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.category != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppConstants.errorColor),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text(
                                '¿Estás seguro de eliminar esta categoría?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _delete();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.errorColor,
                                  ),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej: Alimentación',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tipo de categoría'),
                  subtitle: Text(_isExpense ? 'Gasto' : 'Ingreso'),
                  value: _isExpense,
                  onChanged: (value) => setState(() => _isExpense = value),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                const Text(
                  'Color',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Selecciona un color'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) {
                              setState(() => _selectedColor = color);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    child: const Center(
                      child: Text(
                        'Toca para cambiar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                const Text(
                  'Icono',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.categoryIcons.map((icon) {
                    final isSelected = _selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor
                              : _selectedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                          border: Border.all(
                            color: _selectedColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
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
                      child: Text(widget.category == null ? 'Guardar' : 'Actualizar'),
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
