import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/inventory_item_tile.dart';
import '../widgets/inventory_stat_card.dart';
import '../widgets/recipe_filter_chip.dart';
import 'add_product_screen.dart';
import 'ai_camera_screen.dart';
import 'home_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  static const String routeName = '/inventory';

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  static const List<String> _categories = [
    'Tümü',
    'Sebze & Meyve',
    'Süt Ürünleri',
    'Et & Tavuk',
    'İçecekler',
  ];

  static const List<InventoryStatCardData> _stats = [
    InventoryStatCardData(
      title: 'Toplam Ürün',
      value: '42',
      icon: Icons.inventory_2_rounded,
      backgroundColor: AppColors.surfaceContainerLow,
      foregroundColor: AppColors.textPrimary,
      outlineLabelColor: AppColors.outline,
    ),
    InventoryStatCardData(
      title: 'Kritik Tarih',
      value: '5',
      icon: Icons.warning_amber_rounded,
      backgroundColor: Color(0xFFF8E2DD),
      foregroundColor: Color(0xFFB94C3A),
    ),
    InventoryStatCardData(
      title: 'Eco Skoru',
      value: '%92',
      icon: Icons.eco_rounded,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      accentIcon: Icons.energy_savings_leaf_rounded,
    ),
  ];

  static const List<InventoryItemData> _allItems = [
    InventoryItemData(
      name: 'Domates',
      statusLabel: 'SKT: 2 Gün Kaldı',
      quantity: 5,
      unit: 'Adet',
      category: 'Sebze & Meyve',
      icon: Icons.local_pizza_outlined,
      backgroundColors: [Color(0xFFE38C7D), Color(0xFFB75E57)],
      isCritical: true,
    ),
    InventoryItemData(
      name: 'Süt (%3.5 Yağ)',
      statusLabel: 'Taze • SKT: 12.10.2023',
      quantity: 2,
      unit: 'Litre',
      category: 'Süt Ürünleri',
      icon: Icons.local_drink_rounded,
      backgroundColors: [Color(0xFF9CB5DF), Color(0xFF6A86BF)],
      isCritical: false,
    ),
    InventoryItemData(
      name: 'Granny Smith Elma',
      statusLabel: 'Taze • SKT: 18.10.2023',
      quantity: 1,
      unit: 'Kg',
      category: 'Sebze & Meyve',
      icon: Icons.eco_rounded,
      backgroundColors: [Color(0xFF9CC182), Color(0xFF628B4E)],
      isCritical: false,
    ),
    InventoryItemData(
      name: 'Beyaz Peynir',
      statusLabel: 'SKT: Yarın',
      quantity: 450,
      unit: 'g',
      category: 'Süt Ürünleri',
      icon: Icons.breakfast_dining_rounded,
      backgroundColors: [Color(0xFFE9D4AF), Color(0xFFC0A570)],
      isCritical: true,
    ),
    InventoryItemData(
      name: 'Maden Suyu',
      statusLabel: 'Taze • SKT: 28.10.2023',
      quantity: 6,
      unit: 'Adet',
      category: 'İçecekler',
      icon: Icons.wine_bar_rounded,
      backgroundColors: [Color(0xFF8BC1B7), Color(0xFF4A8F88)],
      isCritical: false,
    ),
  ];

  String _selectedCategory = _categories.first;
  late List<InventoryItemData> _items;

  @override
  void initState() {
    super.initState();
    _items = List<InventoryItemData>.from(_allItems);
  }

  void _updateQuantity(int index, int delta) {
    final current = _items[index];
    final nextQuantity = current.quantity + delta;
    if (nextQuantity <= 0) {
      return;
    }

    setState(() {
      _items[index] = current.copyWith(quantity: nextQuantity);
    });
  }

  List<InventoryItemData> get _filteredItems {
    if (_selectedCategory == 'Tümü') {
      return _items;
    }

    return _items
        .where((item) => item.category == _selectedCategory)
        .toList(growable: false);
  }

  void _openAddProduct() {
    Navigator.of(context).pushNamed(AddProductScreen.routeName);
  }

  void _openAiCamera() {
    Navigator.of(context).pushNamed(AiCameraScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 122),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buzdolabım',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mutfak envanterinizi yönetin ve israfı önleyin.',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width >= 900
                          ? 3
                          : width >= 580
                          ? 2
                          : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _stats.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 156,
                        ),
                        itemBuilder: (context, index) {
                          return InventoryStatCard(data: _stats[index]);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: RecipeFilterChip(
                            label: category,
                            selected: _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        ...List.generate(filteredItems.length, (visibleIndex) {
                          final item = filteredItems[visibleIndex];
                          final actualIndex = _items.indexOf(item);

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: visibleIndex == filteredItems.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: InventoryItemTile(
                              item: item,
                              onIncrement: () => _updateQuantity(actualIndex, 1),
                              onDecrement: () => _updateQuantity(actualIndex, -1),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _openAddProduct,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.primaryDim,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            icon: const Icon(Icons.add_circle_rounded),
                            label: Text(
                              'Yeni Ürün Ekle',
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
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        activeTab: DashboardTab.kitchen,
        onActiveTabTap: () {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        },
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
          onPressed: _openAiCamera,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          child: const Icon(Icons.photo_camera_rounded),
        ),
      ),
    );
  }
}
