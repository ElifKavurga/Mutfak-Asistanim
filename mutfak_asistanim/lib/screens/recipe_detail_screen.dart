import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  static const String routeName = '/recipe-detail';

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late final Map<String, dynamic> _recipe;
  late final List<String> _ingredients;
  late final List<bool> _checked;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map<String, dynamic> ? args : <String, dynamic>{};
    _recipe = {
      'title': map['title'] ?? 'Baharatlı Avokado ve Çılbır Esintili Kahvaltı',
      'tag': map['tag'] ?? 'KAHVALTI',
      'duration': map['duration'] ?? '15 Dakika',
      'icon': map['icon'] ?? Icons.breakfast_dining_rounded,
      'gradientColors':
          map['gradientColors'] ?? const [Color(0xFF92A87B), Color(0xFF4C673C)],
    };
    _ingredients = const [
      '2 adet olgun avokado',
      '4 adet köy yumurtası',
      '2 dilim ekşi mayalı ekmek',
      'Süzme yoğurt (2 yemek kaşığı)',
      'Pul biber ve taze dereotu',
      'Zeytinyağı ve deniz tuzu',
    ];
    _checked = List<bool>.filled(_ingredients.length, false);
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gradientColors =
        (_recipe['gradientColors'] as List).whereType<Color>().toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 430,
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
            actions: [
              _TopCircleButton(
                icon: Icons.favorite_border_rounded,
                onTap: () {},
              ),
              const SizedBox(width: 8),
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
                children: [
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
                        colors: [
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
                    bottom: 84,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _HeroChip(
                              label: _mapCategory(_recipe['tag'] as String),
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
                            'Baharatlı Avokado ve Çılbır Esintili Kahvaltı',
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 980;
                      final sidebar = _buildSidebar(context);
                      final content = _buildContent(context);

                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sidebar,
                            const SizedBox(height: 28),
                            content,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: sidebar),
                          const SizedBox(width: 28),
                          Expanded(flex: 7, child: content),
                        ],
                      );
                    },
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
      children: [
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.restaurant_rounded,
                label: 'Porsiyon',
                value: '2 Kişilik',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Kalori',
                value: '340 kcal',
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
            children: [
              Text(
                'Malzemeler',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_ingredients.length, (index) {
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
                    _ingredients[index],
                    style: textTheme.bodyLarge?.copyWith(
                      color: _checked[index]
                          ? AppColors.outline
                          : AppColors.textPrimary,
                      decoration: _checked[index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.primaryDim,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  icon: const Icon(Icons.shopping_basket_rounded),
                  label: Text(
                    'Eksikleri Listeye Ekle',
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
    const steps = [
      (
        'Ekmekleri Hazırlayın',
        'Ekşi mayalı ekmek dilimlerini hafifçe zeytinyağlayın ve tavada her iki yüzü de altın sarısı olana kadar kızartın. Sıcak kalmaları için bir kenara alın.',
      ),
      (
        'Avokado Kreması',
        'Olgun avokadoları deniz tuzu, karabiber ve birkaç damla limon ile ezin. Hafif dokulu kalması lezzeti artırır.',
      ),
      (
        'Poşe Yumurta',
        'Suyu kaynama noktasına getirin, girdap oluşturun ve yumurtaları tek tek ortaya kırarak 3-4 dakika pişirin.',
      ),
      (
        'Birleştirme ve Servis',
        'Kızarmış ekmeklerin üzerine süzme yoğurt, avokado karışımı ve poşe yumurtaları yerleştirin. Pul biber ve dereotu ile servis edin.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            children: [
              Text(
                'Şefin Notu',
                style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Yumurtaların tam kıvamında olması için suya bir damla elma sirkesi eklemeyi unutmayın. Soğuk sıkım zeytinyağı lezzeti belirgin şekilde yükseltir.',
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
        ...List.generate(steps.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 22),
            child: _StepCard(
              stepNumber: index + 1,
              title: steps[index].$1,
              description: steps[index].$2,
              showPlaceholder: index == 2,
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
                  children: [
                    Text(
                      'Bu tarifi beğendiniz mi?',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pişirdiğiniz yemeğin fotoğrafını bizimle paylaşın.',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    _ShareButton(textTheme: textTheme),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bu tarifi beğendiniz mi?',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pişirdiğiniz yemeğin fotoğrafını bizimle paylaşın.',
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

String _mapCategory(String tag) {
  switch (tag) {
    case 'VEGAN':
      return 'Vegan';
    case 'LOW CARBON':
      return '15 Dakika';
    default:
      return 'Kahvaltı';
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

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
            color: Colors.white.withValues(alpha: 0.88),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
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
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
        ),
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
        children: [
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  children: [
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
          if (showPlaceholder) ...[
            const SizedBox(height: 18),
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE7E1CA), Color(0xFFC7B57C)],
                ),
              ),
              child: Stack(
                children: [
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
