import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/common_button.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/suggestion_chip.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  static const String routeName = '/add-product';

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const List<String> _categories = [
    'Süt ve Kahvaltılık',
    'Sebze ve Meyve',
    'Kuru Gıda',
    'Et ve Tavuk',
  ];

  static const List<String> _quickSuggestions = [
    'Yumurta',
    'Yoğurt',
    'Ekmek',
    'Muz',
  ];

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _productNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      final month = selected.month.toString().padLeft(2, '0');
      final day = selected.day.toString().padLeft(2, '0');
      _dateController.text = '$day.$month.${selected.year}';
    });
  }

  void _applySuggestion(String suggestion) {
    setState(() {
      _productNameController.text = suggestion;
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
        ),
        title: Text(
          'MutfakAsistanım',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 132),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(textTheme: textTheme),
                  const SizedBox(height: 28),
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
                        CustomInputField(
                          label: 'Ürün Adı',
                          hintText: 'Örn: Organik Süt',
                          prefixIcon: Icons.edit_note_rounded,
                          controller: _productNameController,
                        ),
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 640;

                            if (stacked) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  const SizedBox(height: 22),
                                  CustomInputField(
                                    label: 'Son Tüketim Tarihi',
                                    hintText: 'Tarih seçin',
                                    prefixIcon: Icons.event_rounded,
                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: _pickDate,
                                    suffix: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CategoryDropdown(
                                    label: 'Kategori',
                                    value: _selectedCategory,
                                    items: _categories,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: CustomInputField(
                                    label: 'Son Tüketim Tarihi',
                                    hintText: 'Tarih seçin',
                                    prefixIcon: Icons.event_rounded,
                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: _pickDate,
                                    suffix: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Hızlı Öneriler',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _quickSuggestions
                              .map(
                                (suggestion) => SuggestionChip(
                                  label: suggestion,
                                  onTap: () => _applySuggestion(suggestion),
                                ),
                              )
                              .toList(),
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
                            label: 'Ürün Ekle',
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
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(
                        alpha: 0.36,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.tertiaryContainer),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.tips_and_updates_rounded,
                            color: AppColors.primaryDim,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Mutfak İpucu: ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryDim,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'Süt ürünlerini buzdolabının iç raflarında saklamak, kapak rafına göre daha uzun süre taze kalmalarını sağlar.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
      bottomNavigationBar: const DashboardBottomNav(
        activeTab: DashboardTab.kitchen,
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.textTheme});

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
                'Mutfağınızı\nTaze Tutun',
                style: textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yeni malzemeleri envanterinize ekleyerek israfı önleyin ve bir sonraki öğününüzü daha kolay planlayın.',
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
                    'Mutfağınızı\nTaze Tutun',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      'Yeni malzemeleri envanterinize ekleyerek israfı önleyin ve bir sonraki öğününüzü daha kolay planlayın.',
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
            right: -26,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.local_grocery_store_rounded,
              size: 74,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Taze giriş',
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
