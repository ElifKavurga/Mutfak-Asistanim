import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/common_button.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  static const String routeName = '/add-recipe';

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  static const List<String> _categories = [
    'Kahvaltı',
    'Öğle',
    'Akşam',
    'Atıştırmalık',
  ];

  static const List<String> _durationUnits = ['Dakika'];

  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];

  String? _selectedCategory = _categories.first;
  String _selectedDurationUnit = _durationUnits.first;

  @override
  void dispose() {
    _recipeNameController.dispose();
    _durationController.dispose();
    _calorieController.dispose();
    _stepsController.dispose();
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length == 1) {
      return;
    }

    setState(() {
      final controller = _ingredientControllers.removeAt(index);
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
        ),
        title: Text(
          'Yeni Tarif',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecipeHero(textTheme: textTheme),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PhotoPickerPlaceholder(),
                        const SizedBox(height: 24),
                        _LabeledTextField(
                          label: 'Tarif Adı',
                          hintText: 'Örn: Fırında Sebzeli Tavuk',
                          prefixIcon: Icons.menu_book_rounded,
                          controller: _recipeNameController,
                        ),
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 640;

                            if (stacked) {
                              return Column(
                                children: [
                                  _DurationField(
                                    durationController: _durationController,
                                    selectedUnit: _selectedDurationUnit,
                                    onUnitChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setState(() {
                                        _selectedDurationUnit = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 22),
                                  _LabeledTextField(
                                    label: 'Kalori',
                                    hintText: 'Örn: 420',
                                    prefixIcon:
                                        Icons.local_fire_department_rounded,
                                    controller: _calorieController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _DurationField(
                                    durationController: _durationController,
                                    selectedUnit: _selectedDurationUnit,
                                    onUnitChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setState(() {
                                        _selectedDurationUnit = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: _LabeledTextField(
                                    label: 'Kalori',
                                    hintText: 'Örn: 420',
                                    prefixIcon:
                                        Icons.local_fire_department_rounded,
                                    controller: _calorieController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        CategoryDropdown(
                          label: 'Kategori',
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Malzemeler',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addIngredientField,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Malzeme Ekle'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_ingredientControllers.length, (
                          index,
                        ) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _ingredientControllers.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: _IngredientField(
                              index: index,
                              controller: _ingredientControllers[index],
                              canRemove: _ingredientControllers.length > 1,
                              onRemove: () => _removeIngredientField(index),
                            ),
                          );
                        }),
                        const SizedBox(height: 28),
                        _LabeledTextField(
                          label: 'Hazırlanış Adımları',
                          hintText:
                              'Adımları sırayla yazın. Örn: 1. Sebzeleri doğrayın...',
                          prefixIcon: Icons.format_list_numbered_rounded,
                          controller: _stepsController,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 28),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDim],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 28,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: CommonButton(
                            label: 'Tarifi Kaydet',
                            onPressed: () {},
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeHero extends StatelessWidget {
  const _RecipeHero({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haftalık Planına\nYeni Tatlar Ekle',
                style: textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yeni tariflerini tek ekranda tanımla, öğün planına ekle ve mutfak akışını düzenli tut.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              const _HeroVisual(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haftalık Planına\nYeni Tatlar Ekle',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Text(
                      'Yeni tariflerini tek ekranda tanımla, öğün planına ekle ve mutfak akışını düzenli tut.',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
            const Expanded(flex: 2, child: _HeroVisual()),
          ],
        );
      },
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceContainerLow, AppColors.surfaceContainer],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            bottom: -24,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.82),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: -22,
            child: Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Plan dostu',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPickerPlaceholder extends StatelessWidget {
  const _PhotoPickerPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomPaint(
      painter: const _DashedBorderPainter(radius: 28),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 190),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Tarif Fotoğrafı Ekle',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hazırladığın tabağı veya ilham görselini buraya ekleyebilirsin.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.durationController,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  final TextEditingController durationController;
  final String selectedUnit;
  final ValueChanged<String?> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Hazırlanma Süresi',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Örn: 25',
                  prefixIcon: Icon(
                    Icons.timer_rounded,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 128,
              child: DropdownButtonFormField<String>(
                initialValue: selectedUnit,
                onChanged: onUnitChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Dakika',
                    child: Text('Dakika'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IngredientField extends StatelessWidget {
  const _IngredientField({
    required this.index,
    required this.controller,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final TextEditingController controller;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Malzeme ${index + 1}',
        prefixIcon: const Icon(Icons.kitchen_rounded, color: AppColors.outline),
        suffixIcon: canRemove
            ? IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: AppColors.outline,
                tooltip: 'Malzemeyi kaldır',
              )
            : null,
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.textInputAction,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textInputAction: textInputAction,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: AppColors.outline),
            alignLabelWithHint: maxLines > 1,
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.2;
    const dashWidth = 10.0;
    const dashSpace = 8.0;

    final paint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}
