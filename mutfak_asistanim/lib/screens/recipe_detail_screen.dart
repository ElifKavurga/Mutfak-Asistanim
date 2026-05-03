import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../theme/app_colors.dart';
import 'shopping_list_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  static const String routeName = '/recipe-detail';

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Map<String, dynamic> _recipe;
  late List<String> _ingredients;
  late Set<String> _missingIngredients;
  late List<bool> _checked;
  late List<_RecipeStepData> _steps;
  late String _servings;
  late String _calories;
  late String _chefNote;

  int? _recipeId;
  bool _loaded = false;
  bool _isDetailLoading = false;
  String? _detailError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map<String, dynamic> ? args : <String, dynamic>{};
    _applyRouteArguments(map);
    _loaded = true;

    if (_recipeId != null) {
      _loadRecipeDetail();
    }
  }

  void _applyRouteArguments(Map<String, dynamic> map) {
    final routeGradientColors =
        (map['gradientColors'] as List?)?.whereType<Color>().toList() ??
        const <Color>[];

    _recipeId = map['id'] is int
        ? map['id'] as int
        : int.tryParse(map['id']?.toString() ?? '');
    _recipe = <String, dynamic>{
      'title': map['title'] as String? ?? '',
      'tag': map['tag'] as String? ?? '',
      'duration': map['duration'] as String? ?? '',
      'icon': map['icon'] is IconData
          ? map['icon'] as IconData
          : Icons.restaurant_menu_rounded,
      'gradientColors': routeGradientColors.isEmpty
          ? const <Color>[Color(0xFF92A87B), Color(0xFF4C673C)]
          : routeGradientColors,
    };
    _servings = map['servings'] as String? ?? 'Belirtilmedi';
    _calories = map['calories'] as String? ?? '0 kcal';
    _chefNote =
        map['chefNote'] as String? ??
        'Tarifi kendi damak zevkine göre küçük dokunuşlarla kolayca uyarlayabilirsin.';
    _ingredients =
        (map['ingredients'] as List?)?.whereType<String>().toList(
          growable: false,
        ) ??
        <String>[];
    _missingIngredients =
        ((map['missingIngredients'] as List?) ?? const <dynamic>[])
            .whereType<String>()
            .toSet();
    _steps = _parseSteps(map['steps']);
    _checked = List<bool>.filled(_ingredients.length, false);
  }

  Future<void> _loadRecipeDetail() async {
    final recipeId = _recipeId;
    if (recipeId == null) {
      return;
    }

    setState(() {
      _isDetailLoading = true;
      _detailError = null;
    });

    try {
      final details = await BackendApiService.instance.loadRecipeRouteArguments(
        recipeId: recipeId,
        fallbackArguments: _recipe,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _applyRouteArguments(details);
        _isDetailLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _detailError = error.toString();
        _isDetailLoading = false;
      });
    }
  }

  List<_RecipeStepData> _parseSteps(Object? rawSteps) {
    if (rawSteps is! List) {
      return <_RecipeStepData>[];
    }

    return rawSteps
        .map((item) {
          if (item is Map<String, dynamic>) {
            return _RecipeStepData(
              title: item['title'] as String? ?? '',
              description: item['description'] as String? ?? '',
              showPlaceholder: item['showPlaceholder'] as bool? ?? false,
            );
          }
          return null;
        })
        .whereType<_RecipeStepData>()
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gradientColors = (_recipe['gradientColors'] as List)
        .whereType<Color>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 360,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _TopCircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _TopCircleButton(
                  icon: Icons.share_rounded,
                  onTap: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 20,
                end: 20,
                bottom: 16,
              ),
              title: Text(
                'Tarif Detayı',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradientColors,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 110,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      child: Icon(
                        _recipe['icon'] as IconData,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -28,
                    top: 54,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.08),
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            _HeroChip(
                              label: (_recipe['tag'] as String).isEmpty
                                  ? 'TARIF'
                                  : _recipe['tag'] as String,
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                            ),
                            _HeroChip(
                              label: _recipe['duration'] as String,
                              backgroundColor: AppColors.secondaryContainer,
                              foregroundColor: AppColors.primaryDim,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Text(
                            _recipe['title'] as String,
                            style: textTheme.displayMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1.02,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (_isDetailLoading) ...<Widget>[
                        const LinearProgressIndicator(),
                        const SizedBox(height: 14),
                      ],
                      if (_detailError != null) ...<Widget>[
                        _InlineErrorCard(
                          message: _detailError!,
                          onRetry: _loadRecipeDetail,
                        ),
                        const SizedBox(height: 18),
                      ],
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 980;
                          final sidebar = _buildSidebar(context);
                          final content = _buildContent(context);

                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                sidebar,
                                const SizedBox(height: 28),
                                content,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(flex: 4, child: sidebar),
                              const SizedBox(width: 28),
                              Expanded(flex: 7, child: content),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(
                icon: Icons.restaurant_rounded,
                label: 'Porsiyon',
                value: _servings,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Kalori',
                value: _calories,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Malzemeler',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (_ingredients.isEmpty)
                Text(
                  'Malzeme listesi şu anda görüntülenemiyor.',
                  style: textTheme.bodyLarge,
                )
              else
                ...List.generate(_ingredients.length, (index) {
                  final ingredient = _ingredients[index];
                  final isMissing = _missingIngredients.contains(ingredient);

                  return CheckboxListTile(
                    value: _checked[index],
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _checked[index] = value ?? false;
                      });
                    },
                    title: Text(
                      ingredient,
                      style: textTheme.bodyLarge?.copyWith(
                        color: _checked[index]
                            ? AppColors.outline
                            : AppColors.textPrimary,
                        decoration: _checked[index]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: isMissing
                        ? Text(
                            'Eksik malzeme',
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFB94C3A),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  );
                }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _missingIngredients.isEmpty
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pushNamed(ShoppingListScreen.routeName);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.primaryDim,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  icon: const Icon(Icons.shopping_basket_rounded),
                  label: Text(
                    _missingIngredients.isEmpty
                        ? 'Tüm Malzemeler Hazır'
                        : 'Eksikleri Listede Gör',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryDim,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: const Border(
              left: BorderSide(color: AppColors.primary, width: 5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Şefin Notu',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _chefNote,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Hazırlanışı',
          style: textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 18),
        if (_steps.isEmpty)
          Text(
            'Hazırlanış adımları henüz ayrıntılı olarak eklenmedi. Genel akışı yine de burada görebilirsin.',
            style: textTheme.bodyLarge,
          )
        else
          ...List.generate(_steps.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _steps.length - 1 ? 0 : 22,
              ),
              child: _StepCard(
                stepNumber: index + 1,
                title: _steps[index].title,
                description: _steps[index].description,
                showPlaceholder: _steps[index].showPlaceholder,
              ),
            );
          }),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.surfaceContainerHigh),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bu tarifi denedin mi?',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hazırladığın yemeğin fotoğrafını paylaşarak başkalarına ilham olabilirsin.',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    _ShareButton(textTheme: textTheme),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Bu tarifi denedin mi?',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hazırladığın yemeğin fotoğrafını paylaşarak başkalarına ilham olabilirsin.',
                          style: textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  _ShareButton(textTheme: textTheme),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7B8AD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB94C3A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Tarif detayları açılırken bir sorun oluştu',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(message, style: textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.88),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 10),
          Text(label, style: textTheme.labelSmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.showPlaceholder,
  });

  final int stepNumber;
  final String title;
  final String description;
  final bool showPlaceholder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          if (showPlaceholder) ...<Widget>[
            const SizedBox(height: 18),
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFE7E1CA), Color(0xFFC7B57C)],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 18,
                    top: 18,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.egg_alt_rounded,
                      size: 74,
                      color: AppColors.primaryDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      ),
      child: Text(
        'Fotoğraf Paylaş',
        style: textTheme.labelLarge?.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}

class _RecipeStepData {
  const _RecipeStepData({
    required this.title,
    required this.description,
    required this.showPlaceholder,
  });

  final String title;
  final String description;
  final bool showPlaceholder;
}
