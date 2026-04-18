import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/dashboard_bottom_nav.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';
import 'shopping_list_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  static const String routeName = '/plan';

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static const List<String> _weekdayLabels = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  int _selectedDayIndex = 0;
  _MealData? _breakfastMeal;
  _MealData? _dinnerMeal;

  List<_DayData> get _days {
    final today = DateTime.now();
    return List<_DayData>.generate(7, (index) {
      final date = today.add(Duration(days: index));
      return _DayData(date: date, label: _weekdayLabels[date.weekday - 1]);
    });
  }

  void _openAddRecipe() {
    Navigator.of(context).pushNamed(AddRecipeScreen.routeName);
  }

  void _openShoppingList() {
    Navigator.of(context).pushNamed(ShoppingListScreen.routeName);
  }

  void _openRecipeDetail() {
    Navigator.of(
      context,
    ).pushNamed(RecipeDetailScreen.routeName, arguments: _dinnerMeal?.routeData);
  }

  void _removeBreakfastMeal() {
    setState(() {
      _breakfastMeal = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Öğün plandan çıkarıldı.')));
  }

  String _caloriesFor(_MealData? meal) => meal?.caloriesLabel ?? '0 kcal';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = _days;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Planla',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: _openShoppingList,
              icon: const Icon(Icons.shopping_basket_rounded),
              tooltip: 'Alışveriş listesi',
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final selected = index == _selectedDayIndex;

                        return _DayCard(
                          day: day,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  _MealSectionHeader(
                    title: 'Kahvaltı',
                    calories: _caloriesFor(_breakfastMeal),
                  ),
                  const SizedBox(height: 12),
                  _BreakfastCard(
                    meal: _breakfastMeal,
                    onRemove: _removeBreakfastMeal,
                  ),
                  const SizedBox(height: 24),
                  const _MealSectionHeader(
                    title: 'Öğle Yemeği',
                    calories: '0 kcal',
                  ),
                  const SizedBox(height: 12),
                  _EmptyMealCard(onTap: _openAddRecipe),
                  const SizedBox(height: 24),
                  _MealSectionHeader(
                    title: 'Akşam Yemeği',
                    calories: _caloriesFor(_dinnerMeal),
                  ),
                  const SizedBox(height: 12),
                  _DinnerCard(
                    meal: _dinnerMeal,
                    onOpenRecipe: _openRecipeDetail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openAddRecipe,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          tooltip: 'Tarif ekle',
          child: const Icon(Icons.add_task_rounded),
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(
        activeTab: DashboardTab.planner,
      ),
    );
  }
}

class _MealSectionHeader extends StatelessWidget {
  const _MealSectionHeader({required this.title, required this.calories});

  final String title;
  final String calories;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            calories,
            style: textTheme.labelMedium?.copyWith(color: AppColors.primaryDim),
          ),
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final _DayData day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 62,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: selected
                ? Border.all(color: AppColors.background, width: 3)
                : null,
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day.label,
                style: textTheme.labelSmall?.copyWith(
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${day.date.day}',
                style: textTheme.titleLarge?.copyWith(
                  color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakfastCard extends StatelessWidget {
  const _BreakfastCard({
    required this.meal,
    required this.onRemove,
  });

  final _MealData? meal;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD7E5F9), Color(0xFF9FBAE6)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 14,
                  right: 12,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Icon(
                  meal?.icon ?? Icons.breakfast_dining_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal?.title ?? '',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meal?.description ?? '',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.outline,
            tooltip: 'Öğünü kaldır',
          ),
        ],
      ),
    );
  }
}

class _EmptyMealCard extends StatelessWidget {
  const _EmptyMealCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomPaint(
      painter: const _DashedBorderPainter(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 156),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tarif Ekle',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DinnerCard extends StatelessWidget {
  const _DinnerCard({
    required this.meal,
    required this.onOpenRecipe,
  });

  final _MealData? meal;
  final VoidCallback onOpenRecipe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = meal?.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 244,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const _DinnerFallback();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const _DinnerFallback();
                },
              )
            else
              const _DinnerFallback(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xA6000000)],
                  stops: [0.3, 1],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          meal?.title ?? '',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (meal?.tags ?? const <String>[])
                              .map(
                                (tag) => _TagChip(
                                  label: tag,
                                  backgroundColor: const Color(0xD8ECEEEC),
                                  foregroundColor: AppColors.textPrimary,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      onPressed: onOpenRecipe,
                      icon: const Icon(Icons.refresh_rounded),
                      color: Colors.white,
                      tooltip: 'Öğünü yenile',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DinnerFallback extends StatelessWidget {
  const _DinnerFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF91A68A), Color(0xFF536443)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.set_meal_rounded,
          size: 44,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(30);
    const strokeWidth = 2.2;
    const dashWidth = 10.0;
    const dashSpace = 8.0;

    final paint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, radius);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DayData {
  const _DayData({required this.date, required this.label});

  final DateTime date;
  final String label;
}

class _MealData {
  const _MealData({
    required this.title,
    required this.description,
    required this.caloriesLabel,
    required this.icon,
    required this.tags,
    required this.imageUrl,
    required this.routeData,
  });

  final String title;
  final String description;
  final String caloriesLabel;
  final IconData icon;
  final List<String> tags;
  final String? imageUrl;
  final Map<String, dynamic>? routeData;
}
