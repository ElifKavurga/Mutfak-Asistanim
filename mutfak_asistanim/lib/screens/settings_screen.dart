import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/common_button.dart';
import '../widgets/custom_input_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _dietOptions = const ['Tumu'];

  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(text: '');

  String _selectedDiet = 'Tumu';
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = false;
  bool _sustainabilityTipsEnabled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leadingWidth: 104,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: Text(
              'Geri',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Ayarlar',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final contentWidth = viewport.maxWidth > 760
                ? 760.0
                : viewport.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                  children: [
                    _ProfileHeader(
                      name: _nameController.text.trim().isEmpty
                          ? 'Mutfagini kisisellestir'
                          : _nameController.text.trim(),
                      role: 'Tercihlerini ve bildirim ayarlarini buradan yonet.',
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 560;

                          return Column(
                            children: [
                              if (isWide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomInputField(
                                        label: 'Ad Soyad',
                                        hintText: 'Ad Soyad',
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        controller: _nameController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomInputField(
                                        label: 'E-posta',
                                        hintText: 'E-posta',
                                        prefixIcon: Icons.mail_outline_rounded,
                                        controller: _emailController,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                CustomInputField(
                                  label: 'Ad Soyad',
                                  hintText: 'Ad Soyad',
                                  prefixIcon: Icons.person_outline_rounded,
                                  controller: _nameController,
                                ),
                                const SizedBox(height: 16),
                                CustomInputField(
                                  label: 'E-posta',
                                  hintText: 'E-posta',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  controller: _emailController,
                                ),
                              ],
                              const SizedBox(height: 16),
                              CategoryDropdown(
                                label: 'Diyet Tercihi',
                                value: _selectedDiet,
                                items: _dietOptions,
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    _selectedDiet = value;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'UYGULAMA TERCIHLERI',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PreferenceTile(
                      title: 'Bildirimleri Ac',
                      subtitle: 'Yeni tarifler ve onemli hatirlatmalar',
                      icon: Icons.notifications_rounded,
                      iconBackgroundColor: AppColors.secondaryContainer,
                      iconColor: AppColors.secondary,
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _PreferenceTile(
                      title: 'Koyu Tema',
                      subtitle: 'Daha sakin bir gorunum kullan',
                      icon: Icons.dark_mode_rounded,
                      iconBackgroundColor: AppColors.secondaryContainer,
                      iconColor: AppColors.secondary,
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _PreferenceTile(
                      title: 'Surdurulebilirlik Ipuclari',
                      subtitle: 'Haftalik tasarruf ve mutfak onerileri',
                      icon: Icons.eco_rounded,
                      iconBackgroundColor: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                      value: _sustainabilityTipsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _sustainabilityTipsEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.96),
          boxShadow: const [
            BoxShadow(
              color: Color(0x122F3332),
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: CommonButton(
                label: 'Degisiklikleri Kaydet',
                icon: const Icon(Icons.save_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ayarlarin basariyla kaydedildi.'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 4),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 4,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: 20,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.surface,
            inactiveTrackColor: AppColors.surfaceContainerHigh,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.transparent;
              }

              return AppColors.outlineVariant;
            }),
          ),
        ],
      ),
    );
  }
}
