import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  static const List<_NotificationItemData> _notifications = [
    _NotificationItemData(
      category: 'Son Tüketim Uyarısı',
      title: "Organik Süt'ün SKT'si yarın doluyor!",
      message:
          'Sütü bugün bir tatlıda kullanarak israfın önüne geçebilirsiniz.',
      timeLabel: '2 sa önce',
      icon: Icons.warning_rounded,
      accentColor: Color(0xFFA73B21),
      iconBackgroundColor: Color(0x33FD795A),
      backgroundColor: AppColors.surfaceContainerLow,
      hasUnreadDot: true,
      primaryActionLabel: 'Tarif Bul',
      secondaryActionLabel: 'Kapat',
    ),
    _NotificationItemData(
      category: 'Başarı Kazandınız',
      title: 'Tebrikler! Kompost Kralı rozetini kazandınız.',
      message:
          '10 farklı sebze atığını değerlendirdiğiniz için bu rozet koleksiyonunuza eklendi.',
      timeLabel: 'Dün',
      icon: Icons.star_rounded,
      accentColor: AppColors.primary,
      iconBackgroundColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surface,
      iconFilled: true,
    ),
    _NotificationItemData(
      category: 'Mutfak İpucu',
      title: 'Haftalık yemek planınızı oluşturmayı unutmayın.',
      message:
          'Pazar günü yapacağınız 15 dakikalık bir planlama, hafta içi size 5 saat kazandırır.',
      timeLabel: '2 gün önce',
      icon: Icons.lightbulb_rounded,
      accentColor: Color(0xFF686028),
      iconBackgroundColor: AppColors.tertiaryContainer,
      backgroundColor: AppColors.surface,
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
        centerTitle: true,
        leadingWidth: 96,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: Text(
              'Geri',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        title: Text(
          'Bildirimler',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [SizedBox(width: 96)],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mutfak Günlüğü',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bildirimler',
                              style: textTheme.displayMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Tümünü Oku',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ..._notifications.map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _NotificationCard(data: notification),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _PromoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.data});

  final _NotificationItemData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        border: Border(
          left: BorderSide(color: data.accentColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: data.iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                data.icon,
                color: data.accentColor,
                size: 28,
                fill: data.iconFilled ? 1 : 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.category.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: data.accentColor.withValues(alpha: 0.88),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data.title,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            data.timeLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (data.hasUnreadDot) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.message,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (data.primaryActionLabel != null ||
                      data.secondaryActionLabel != null) ...[
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (data.primaryActionLabel != null)
                          FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: data.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(data.primaryActionLabel!),
                          ),
                        if (data.secondaryActionLabel != null)
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(data.secondaryActionLabel!),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -24,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 18,
            child: Icon(
              Icons.eco_rounded,
              size: 108,
              color: AppColors.primary.withValues(alpha: 0.20),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sürdürülebilir Mutfak',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryDim,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atıksız bir mutfak için hazırladığımız özel rehbere göz atın.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDim.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
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
                  child: const Text('Rehberi Oku'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItemData {
  const _NotificationItemData({
    required this.category,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.accentColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    this.hasUnreadDot = false,
    this.iconFilled = false,
    this.primaryActionLabel,
    this.secondaryActionLabel,
  });

  final String category;
  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color accentColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final bool hasUnreadDot;
  final bool iconFilled;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
}
