import 'package:flutter/material.dart';

import '../services/mock_kitchen_data_service.dart';
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
  List<String> _categories = const <String>['Tümü'];
  List<InventoryItemData> _items = const <InventoryItemData>[];
  List<InventoryStatCardData> _stats = const <InventoryStatCardData>[];
  String _selectedCategory = 'Tümü';
  String? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final data = await MockKitchenDataService.instance.loadInventoryData();
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = data.categories;
        _items = data.items;
        _stats = data.stats;
        _selectedCategory = data.categories.first;
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

  void _updateQuantity(int index, int delta) {
    final current = _items[index];
    final nextQuantity = current.quantity + delta;
    if (nextQuantity <= 0) {
      return;
    }

    setState(() {
      final updated = List<InventoryItemData>.of(_items);
      updated[index] = current.copyWith(quantity: nextQuantity);
      _items = updated;
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
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 122),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: _buildBody(textTheme, filteredItems),
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

  Widget _buildBody(TextTheme textTheme, List<InventoryItemData> filteredItems) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return _InventoryErrorState(
        message: _loadError!,
        onRetry: _loadData,
      );
    }

    return Column(
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
          'Mock JSON verisinden gelen malzemeler, son kullanımı yakın olana göre sıralandı.',
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
            }).toList(growable: false),
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
              if (filteredItems.isEmpty)
                _InventoryEmptyState(onAddProduct: _openAddProduct)
              else
                ...List.generate(filteredItems.length, (visibleIndex) {
                  final item = filteredItems[visibleIndex];
                  final actualIndex = _items.indexOf(item);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: visibleIndex == filteredItems.length - 1 ? 0 : 12,
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
    );
  }
}

class _InventoryEmptyState extends StatelessWidget {
  const _InventoryEmptyState({required this.onAddProduct});

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'Bu kategoride ürün görünmüyor',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı kategori seçebilir ya da yeni bir ürün ekleyebilirsin.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Ürün Ekle'),
          ),
        ],
      ),
    );
  }
}

class _InventoryErrorState extends StatelessWidget {
  const _InventoryErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB94C3A),
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                'Envanter yüklenemedi',
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
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
              FilledButton(
                onPressed: onRetry,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
