import 'package:flutter/material.dart';

import '../services/mock_kitchen_data_service.dart';
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
  List<_ShoppingCategory> _categories = const <_ShoppingCategory>[];
  String? _loadError;
  bool _isLoading = true;

  int get _totalItemCount => _categories.fold(
        0,
        (total, category) => total + category.items.length,
      );

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
      final data = await MockKitchenDataService.instance.loadShoppingData();
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = data.sections
            .map(
              (section) => _ShoppingCategory(
                title: section.title,
                items: section.items,
              ),
            )
            .toList(growable: false);
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
          .toList(growable: false);
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Yenile',
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: _buildBody(textTheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return _ShoppingErrorState(
        message: _loadError!,
        onRetry: _loadData,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eksik Malzemeler',
          style: textTheme.displayMedium?.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sık kullanılan malzemeler tükendiğinde ve tariflerde açık oluştuğunda bu liste otomatik doluyor.',
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
                        '$_totalItemCount ürün',
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
        if (_categories.isEmpty)
          const _ShoppingEmptyState()
        else
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
                      'Soğan, sarımsak ve zeytinyağı gibi temel ürünleri listede ayrı tutmak, tarif eksiklerini daha hızlı kapatır.',
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

class _ShoppingEmptyState extends StatelessWidget {
  const _ShoppingEmptyState();

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
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            'Şu an eksik malzeme görünmüyor',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sık kullanılan ürünler tükenirse veya tariflerde açık oluşursa liste burada belirecek.',
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

class _ShoppingErrorState extends StatelessWidget {
  const _ShoppingErrorState({
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
                'Alışveriş listesi yüklenemedi',
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
