import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'settings_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/stat_mini_card.dart';

class StatsProfileScreen extends StatelessWidget {
  const StatsProfileScreen({super.key});

  static const String routeName = '/stats-profile';

  static const List<StatMiniCardData> _stats = [
    StatMiniCardData(
      title: 'Kurtarılan Öğünler',
      value: '124',
      subtitle: '+12 geçen haftadan',
      icon: Icons.restaurant_menu_rounded,
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: AppColors.primaryDim,
      iconBackgroundColor: AppColors.primary,
    ),
    StatMiniCardData(
      title: 'Ekonomik Kazanç',
      value: '₺1.450',
      subtitle: 'Tahmini aylık tasarruf',
      icon: Icons.savings_rounded,
      backgroundColor: AppColors.tertiaryContainer,
      foregroundColor: Color(0xFF5C541D),
      iconBackgroundColor: Color(0x33686028),
    ),
  ];

  static const List<AchievementBadgeData> _achievements = [
    AchievementBadgeData(
      title: 'Kompost Kralı',
      icon: Icons.compost_rounded,
      isUnlocked: true,
    ),
    AchievementBadgeData(
      title: 'Sıfır Atık',
      icon: Icons.recycling_rounded,
      isUnlocked: true,
    ),
    AchievementBadgeData(
      title: 'Plan Ustası',
      icon: Icons.event_note_rounded,
      isUnlocked: false,
    ),
    AchievementBadgeData(
      title: 'Bilinçli Alıcı',
      icon: Icons.shopping_basket_rounded,
      isUnlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.primary,
            tooltip: 'Geri',
          ),
        ),
        centerTitle: true,
        title: Text(
          'Profil',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İstatistikler',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Mutfak alışkanlıklarınızın çevreye ve bütçenize olan etkisini takip edin.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;
                      final statsColumn = _StatsCardsSection(
                        stacked: isWide || constraints.maxWidth < 560,
                      );

                      if (!isWide) {
                        return Column(
                          children: [
                            const _FoodUsageAnalysisCard(),
                            const SizedBox(height: 18),
                            statsColumn,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            flex: 7,
                            child: _FoodUsageAnalysisCard(),
                          ),
                          const SizedBox(width: 18),
                          Expanded(flex: 5, child: statsColumn),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 960;

                      if (stacked) {
                        return const Column(
                          children: [
                            _ProfileSummaryCard(),
                            SizedBox(height: 18),
                            _AchievementsSection(),
                          ],
                        );
                      }

                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: _ProfileSummaryCard()),
                          SizedBox(width: 18),
                          Expanded(flex: 8, child: _AchievementsSection()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const _WeeklyInsightCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsCardsSection extends StatelessWidget {
  const _StatsCardsSection({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        children: List.generate(StatsProfileScreen._stats.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == StatsProfileScreen._stats.length - 1 ? 0 : 18,
            ),
            child: StatMiniCard(data: StatsProfileScreen._stats[index]),
          );
        }),
      );
    }

    return Row(
      children: List.generate(StatsProfileScreen._stats.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 0 ? 18 : 0),
            child: StatMiniCard(data: StatsProfileScreen._stats[index]),
          ),
        );
      }),
    );
  }
}

class _FoodUsageAnalysisCard extends StatelessWidget {
  const _FoodUsageAnalysisCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 640;
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gıda Kullanım Analizi',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bu ay aldığınız ürünlerin %75\'ini israf etmeden tükettiniz. Harika bir denge yakaladınız.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const _LegendItem(
                color: AppColors.primary,
                label: 'Kurtarılan Gıdalar',
                value: '%75',
              ),
              const SizedBox(height: 12),
              const _LegendItem(
                color: AppColors.tertiaryContainer,
                label: 'İsraf Oranı',
                value: '%25',
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.center,
                  child: _DonutChart(value: 0.75, label: 'Verimlilik'),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 18),
              const _DonutChart(value: 0.75, label: 'Verimlilik'),
            ],
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.labelMedium?.copyWith(color: AppColors.outline),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryContainer, AppColors.secondary],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'ZY',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryDim,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zeynep Yılmaz',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Master Chef',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Text(
                'Mutfak Puanı',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.outline,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                '2.450 XP',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.80,
              minHeight: 14,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Bir sonraki seviye için 550 XP gerekli',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.outlineVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(SettingsScreen.routeName),
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Düzenle'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Paylaş'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mutfak Başarıları',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Tümünü Gör',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryDim,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 4 : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: StatsProfileScreen._achievements.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: columns == 4 ? 0.98 : 1.16,
                ),
                itemBuilder: (context, index) {
                  return AchievementBadge(
                    data: StatsProfileScreen._achievements[index],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeeklyInsightCard extends StatelessWidget {
  const _WeeklyInsightCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8AA06D), Color(0xFF405333), Color(0xFF1F2C1D)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.24),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -10,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.22),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 28,
              top: 32,
              child: Row(
                children: const [
                  _InsightIconBubble(icon: Icons.spa_rounded, size: 56),
                  SizedBox(width: 12),
                  _InsightIconBubble(icon: Icons.eco_rounded, size: 42),
                ],
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.54),
                    ],
                    stops: const [0.22, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Haftalık İpucu',
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF5C541D),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Yeşil Yapraklıları Nasıl Daha Uzun Saklarsınız?',
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Ispanak ve roka gibi narin sebzeleri hafif nemli bir kağıt havlu ile kapalı kapta saklamak, ömürlerini birkaç gün uzatabilir.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Makaleyi Oku'),
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

class _InsightIconBubble extends StatelessWidget {
  const _InsightIconBubble({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.46),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = (value * 100).round();

    return SizedBox(
      width: 188,
      height: 188,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(188),
            painter: _DonutChartPainter(value: value),
          ),
          Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.outline,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 28.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    final backgroundPaint = Paint()
      ..color = AppColors.tertiaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);
    canvas.drawArc(rect, startAngle, math.pi * 2 * value, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
