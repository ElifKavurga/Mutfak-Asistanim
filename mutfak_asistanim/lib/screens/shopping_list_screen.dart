import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/shopping_list_item.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  static const String routeName = '/shopping-list';

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingCategory {
  const _ShoppingCategory({
    required this.title,
    required this.items,
  });

  final String title;
  final List<ShoppingListItemData> items;

  _ShoppingCategory copyWith({List<ShoppingListItemData>? items}) {
    return _ShoppingCategory(
      title: title,
      items: items ?? this.items,
    );
  }
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  static const List<_ShoppingCategory> _initialCategories = [
    _ShoppingCategory(
      title: 'MANAV & SEBZE',
      items: [
        ShoppingListItemData(
          name: 'Taze Adaçayı',
          quantity: '1 Demet',
          visual: ShoppingListVisual.image(
            imageUrl:
                'https://images.unsplash.com/photo-1515543904379-3d757afe72e4?auto=format&fit=crop&w=200&q=80',
          ),
        ),
        ShoppingListItemData(
          name: 'Baby Ispanak',
          quantity: '200 g',
          visual: ShoppingListVisual.icon(
            icon: Icons.eco_rounded,
            backgroundColor: AppColors.secondaryContainer,
            foregroundColor: AppColors.primary,
          ),
        ),
        ShoppingListItemData(
          name: 'Cherry Domates',
          quantity: '500 g',
          visual: ShoppingListVisual.icon(
            icon: Icons.spa_rounded,
            backgroundColor: Color(0xFFF6D5CF),
            foregroundColor: Color(0xFFB75E57),
          ),
        ),
        ShoppingListItemData(
          name: 'Avokado',
          quantity: '2 Adet',
          visual: ShoppingListVisual.icon(
            icon: Icons.nature_rounded,
            backgroundColor: Color(0xFFDDE8C8),
            foregroundColor: AppColors.primaryDim,
          ),
        ),
        ShoppingListItemData(
          name: 'Taze Nane',
          quantity: '1 Demet',
          visual: ShoppingListVisual.image(
            imageUrl:
                'https://images.unsplash.com/photo-1628556270448-4d4e4148e54f?auto=format&fit=crop&w=200&q=80',
          ),
        ),
        ShoppingListItemData(
          name: 'Limon',
          quantity: '4 Adet',
          visual: ShoppingListVisual.icon(
            icon: Icons.wb_sunny_rounded,
            backgroundColor: AppColors.tertiaryContainer,
            foregroundColor: Color(0xFF6A622A),
          ),
        ),
      ],
    ),
    _ShoppingCategory(
      title: 'SÜT & KİLER',
      items: [
        ShoppingListItemData(
          name: 'Organik Yumurta',
          quantity: '10\'lu Paket',
          isChecked: true,
          visual: ShoppingListVisual.image(
            imageUrl:
                'https://images.unsplash.com/photo-1506976785307-8732e854ad03?auto=format&fit=crop&w=200&q=80',
          ),
        ),
        ShoppingListItemData(
          name: 'Yulaf Sütü',
          quantity: '1 Litre',
          visual: ShoppingListVisual.icon(
            icon: Icons.water_drop_rounded,
            backgroundColor: AppColors.tertiaryContainer,
            foregroundColor: AppColors.primaryDim,
          ),
        ),
        ShoppingListItemData(
          name: 'Artizan Sourdough',
          quantity: '1 Adet',
          visual: ShoppingListVisual.image(
            imageUrl:
                'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=200&q=80',
          ),
        ),
        ShoppingListItemData(
          name: 'Yoğurt',
          quantity: '750 g',
          visual: ShoppingListVisual.icon(
            icon: Icons.icecream_rounded,
            backgroundColor: Color(0xFFE4ECF9),
            foregroundColor: Color(0xFF6783BC),
          ),
        ),
        ShoppingListItemData(
          name: 'Zeytinyağı',
          quantity: '500 ml',
          visual: ShoppingListVisual.icon(
            icon: Icons.opacity_rounded,
            backgroundColor: Color(0xFFF2E5BA),
            foregroundColor: Color(0xFF8D6E1E),
          ),
        ),
        ShoppingListItemData(
          name: 'Parmesan',
          quantity: '150 g',
          visual: ShoppingListVisual.image(
            imageUrl:
                'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=200&q=80',
          ),
        ),
      ],
    ),
  ];

  late List<_ShoppingCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _initialCategories
        .map((category) => category.copyWith(items: List.of(category.items)))
        .toList(growable: true);
  }

  int get _totalItemCount => _categories.fold(
    0,
    (total, category) => total + category.items.length,
  );

  void _toggleItem(int categoryIndex, int itemIndex, bool value) {
    setState(() {
      final category = _categories[categoryIndex];
      final updatedItems = List<ShoppingListItemData>.of(category.items);
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(isChecked: value);
      _categories[categoryIndex] = category.copyWith(items: updatedItems);
    });
  }

  void _completeAll() {
    setState(() {
      _categories = _categories
          .map(
            (category) => category.copyWith(
              items: category.items
                  .map((item) => item.copyWith(isChecked: true))
                  .toList(growable: false),
            ),
          )
          .toList(growable: true);
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
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
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
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Arama',
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alışveriş Listesi',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Haftalık hazırlıklarınız için taze malzemeler.',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 620;

                      return Flex(
                        direction: stacked ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: stacked
                            ? CrossAxisAlignment.stretch
                            : CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shopping_basket_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_totalItemCount Ürün',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: stacked ? 0 : 16,
                            height: stacked ? 14 : 0,
                          ),
                          if (!stacked) const Spacer(),
                          FilledButton.icon(
                            onPressed: _completeAll,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.done_all_rounded),
                            label: Text(
                              'Tümünü Tamamla',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(_categories.length, (categoryIndex) {
                    final category = _categories[categoryIndex];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: categoryIndex == _categories.length - 1 ? 0 : 28,
                      ),
                      child: _ShoppingCategorySection(
                        title: category.title,
                        children: List.generate(category.items.length, (itemIndex) {
                          final item = category.items[itemIndex];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: itemIndex == category.items.length - 1 ? 0 : 12,
                            ),
                            child: ShoppingListItem(
                              item: item,
                              onChanged: (value) {
                                _toggleItem(categoryIndex, itemIndex, value);
                              },
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Şefin İpucu',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Malzemelerinizi kategorilere göre ayırmak, alışveriş sürenizi %30 oranında kısaltır.',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.lightbulb_rounded,
                            color: AppColors.primary,
                            size: 30,
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

class _ShoppingCategorySection extends StatelessWidget {
  const _ShoppingCategorySection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }
}
