import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<KitchenNotificationData> _notifications =
      const <KitchenNotificationData>[];
  String? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final notifications = await BackendApiService.instance
          .loadNotifications();
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(KitchenNotificationData item) async {
    try {
      await BackendApiService.instance.markNotificationAsRead(item.id);
      await _loadNotifications();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await BackendApiService.instance.markAllNotificationsAsRead();
      await _loadNotifications();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteNotification(KitchenNotificationData item) async {
    try {
      await BackendApiService.instance.deleteNotification(item.id);
      await _loadNotifications();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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
        actions: const <Widget>[SizedBox(width: 96)],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadNotifications,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Mutfak Gunlugu',
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
                          onPressed: _notifications.isEmpty
                              ? null
                              : _markAllAsRead,
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
                            'Tumunu Oku',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yaklasan son kullanma tarihleri ve mutfagindaki onemli hatirlatmalar burada yer alir.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_loadError != null)
                      _NotificationsErrorState(
                        message: _loadError!,
                        onRetry: _loadNotifications,
                      )
                    else if (_notifications.isEmpty)
                      const _NotificationsEmptyState()
                    else
                      ..._notifications.map(
                        (notification) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _NotificationCard(
                            data: notification,
                            onPrimaryAction: notification.isRead
                                ? null
                                : () => _markAsRead(notification),
                            onSecondaryAction: () =>
                                _deleteNotification(notification),
                          ),
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
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.data,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final KitchenNotificationData data;
  final Future<void> Function()? onPrimaryAction;
  final Future<void> Function()? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = _paletteForNotification(data);

    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        border: Border(left: BorderSide(color: palette.accentColor, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: palette.iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                palette.icon,
                color: palette.accentColor,
                size: 28,
                fill: data.isRead ? 0 : 1,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              palette.categoryLabel.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: palette.accentColor.withValues(
                                  alpha: 0.88,
                                ),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data.productName.isEmpty
                                  ? 'Bildirim'
                                  : data.productName,
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
                        children: <Widget>[
                          Text(
                            _formatDate(data.sendingDate),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (!data.isRead) ...<Widget>[
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
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      if (onPrimaryAction != null)
                        FilledButton(
                          onPressed: () => onPrimaryAction?.call(),
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.accentColor,
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
                          child: const Text('Okundu Isaretle'),
                        ),
                      if (onSecondaryAction != null)
                        TextButton(
                          onPressed: () => onSecondaryAction?.call(),
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
                          child: const Text('Sil'),
                        ),
                    ],
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
        children: <Widget>[
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
              children: <Widget>[
                Text(
                  'Surdurulebilir Mutfak',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryDim,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bildirimlerin burada toplaniyor. Kritik urunleri ve onemli hatirlatmalari tek ekrandan takip edebilirsin.',
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
                  child: const Text('Kapat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
            size: 44,
          ),
          const SizedBox(height: 14),
          Text(
            'Bildirim bulunmuyor',
            style: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni hatirlatmalar geldiginde burada gorebilirsin. Su an takip edilmesi gereken bir durum yok.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsErrorState extends StatelessWidget {
  const _NotificationsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB94C3A),
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            'Bildirimler yuklenemedi',
            style: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}

class _NotificationPalette {
  const _NotificationPalette({
    required this.categoryLabel,
    required this.icon,
    required this.accentColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
  });

  final String categoryLabel;
  final IconData icon;
  final Color accentColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
}

_NotificationPalette _paletteForNotification(KitchenNotificationData item) {
  final message = item.message.toLowerCase();
  if (message.contains('son kullanma') || message.contains('tarih')) {
    return const _NotificationPalette(
      categoryLabel: 'Kritik Tarih',
      icon: Icons.warning_amber_rounded,
      accentColor: Color(0xFFB94C3A),
      iconBackgroundColor: Color(0xFFF8E2DD),
      backgroundColor: Color(0xFFFFF6F3),
    );
  }
  if (message.contains('envanter') || message.contains('stok')) {
    return const _NotificationPalette(
      categoryLabel: 'Stok',
      icon: Icons.inventory_2_rounded,
      accentColor: AppColors.primary,
      iconBackgroundColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surface,
    );
  }
  return const _NotificationPalette(
    categoryLabel: 'Genel',
    icon: Icons.notifications_active_rounded,
    accentColor: Color(0xFF5C8798),
    iconBackgroundColor: Color(0xFFE4F2F8),
    backgroundColor: Color(0xFFF7FCFF),
  );
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Tarih yok';
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
