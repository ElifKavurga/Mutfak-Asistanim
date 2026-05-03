import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../widgets/featured_bento_cards.dart';
import '../widgets/inventory_item_tile.dart';
import '../widgets/inventory_stat_card.dart';
import '../widgets/product_card.dart';
import '../widgets/recipe_grid_card.dart';
import '../widgets/shopping_list_item.dart';

class KitchenRecipeDiscoveryData {
  const KitchenRecipeDiscoveryData({
    required this.categories,
    required this.featuredRecipe,
    required this.infoCard,
    required this.recipes,
    required this.seasonalHighlight,
  });

  final List<String> categories;
  final FeaturedRecipeData featuredRecipe;
  final FeaturedInfoCardData infoCard;
  final List<RecipeCardData> recipes;
  final KitchenSeasonalHighlightData seasonalHighlight;
}

class KitchenSeasonalHighlightData {
  const KitchenSeasonalHighlightData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
}

class KitchenInventoryData {
  const KitchenInventoryData({
    required this.categories,
    required this.items,
    required this.stats,
  });

  final List<String> categories;
  final List<InventoryItemData> items;
  final List<InventoryStatCardData> stats;
}

class KitchenShoppingData {
  const KitchenShoppingData({required this.sections});

  final List<KitchenShoppingSection> sections;
}

class KitchenShoppingSection {
  const KitchenShoppingSection({required this.title, required this.items});

  final String title;
  final List<ShoppingListItemData> items;
}

class KitchenHomeData {
  const KitchenHomeData({
    required this.displayName,
    required this.description,
    required this.weeklySavingsLabel,
    required this.products,
    this.suggestion,
  });

  final String displayName;
  final String description;
  final String weeklySavingsLabel;
  final List<ProductCardData> products;
  final KitchenHomeSuggestionData? suggestion;
}

class KitchenHomeSuggestionData {
  const KitchenHomeSuggestionData({
    required this.title,
    required this.recipeName,
    required this.description,
    required this.buttonLabel,
    required this.routeArguments,
  });

  final String title;
  final String recipeName;
  final String description;
  final String buttonLabel;
  final Map<String, dynamic> routeArguments;
}

class MockKitchenDataService {
  MockKitchenDataService._();

  static final MockKitchenDataService instance = MockKitchenDataService._();
  static const String _assetPath = 'assets/data/mock_kitchen_data.json';

  Future<_KitchenData>? _cachedData;

  Future<KitchenRecipeDiscoveryData> loadRecipeDiscoveryData() async {
    final data = await _loadData();
    final matches = _buildRecipeMatches(data);

    final categories = <String>[
      'Tümü',
      ...{for (final match in matches) match.recipe.tag},
    ];

    final topMatch = matches.first;
    final highlightedIngredients = topMatch.expiringInventory
        .take(2)
        .map((item) => item.name)
        .join(', ');
    final availabilitySummary = topMatch.missingIngredients.isEmpty
        ? 'Tüm malzemeler elinizde.'
        : '${topMatch.availableIngredients.length}/${topMatch.recipe.ingredients.length} malzeme hazır.';

    return KitchenRecipeDiscoveryData(
      categories: categories,
      featuredRecipe: FeaturedRecipeData(
        badge: topMatch.recipe.tag,
        title: topMatch.recipe.title,
        duration: topMatch.recipe.duration,
        sustainabilityLabel: topMatch.recipe.sustainabilityLabel,
        gradientColors: _gradientForKey(topMatch.recipe.gradientKey),
        routeArguments: _buildRouteArguments(topMatch),
      ),
      infoCard: FeaturedInfoCardData(
        title: data.featuredInfo.title,
        description: highlightedIngredients.isEmpty
            ? '${data.featuredInfo.description} $availabilitySummary'
            : 'Önce $highlightedIngredients değerlendir. $availabilitySummary',
        actionLabel: data.featuredInfo.actionLabel,
        routeArguments: _buildRouteArguments(topMatch),
      ),
      recipes: matches
          .map(
            (match) => RecipeCardData(
              title: match.recipe.title,
              duration: match.recipe.duration,
              tag: match.recipe.tag,
              gradientColors: _gradientForKey(match.recipe.gradientKey),
              icon: _iconForKey(match.recipe.iconKey),
              routeArguments: _buildRouteArguments(match),
              searchKeywords: <String>[
                match.recipe.title,
                match.recipe.tag,
                ...match.recipe.ingredients.map(
                  (ingredient) => ingredient.name,
                ),
              ],
            ),
          )
          .toList(growable: false),
      seasonalHighlight: data.seasonalHighlight,
    );
  }

  Future<KitchenInventoryData> loadInventoryData() async {
    final data = await _loadData();
    final inventory = [...data.inventory]
      ..sort(
        (left, right) => left.daysUntilExpiry.compareTo(right.daysUntilExpiry),
      );

    final categories = <String>[
      'Tümü',
      ...{for (final item in inventory) item.category},
    ];

    final usedIngredientNames = data.recipes
        .expand((recipe) => recipe.ingredients)
        .map((ingredient) => _normalizeName(ingredient.name))
        .toSet();
    final criticalCount = inventory
        .where((item) => item.daysUntilExpiry <= 2)
        .length;
    final ecoScore = inventory.isEmpty
        ? 0
        : ((inventory
                          .where(
                            (item) => usedIngredientNames.contains(
                              _normalizeName(item.name),
                            ),
                          )
                          .length /
                      inventory.length) *
                  100)
              .round();

    return KitchenInventoryData(
      categories: categories,
      items: inventory
          .map(
            (item) => InventoryItemData(
              name: item.name,
              statusLabel: _expiryLabel(item.daysUntilExpiry),
              quantity: item.quantity,
              unit: item.unit,
              category: item.category,
              icon: _iconForKey(item.iconKey),
              backgroundColors: _gradientForKey(item.gradientKey),
              isCritical: item.daysUntilExpiry <= 2,
            ),
          )
          .toList(growable: false),
      stats: [
        InventoryStatCardData(
          title: 'Toplam Ürün',
          value: '${inventory.length}',
          icon: Icons.inventory_2_rounded,
          backgroundColor: AppColors.surfaceContainerLow,
          foregroundColor: AppColors.textPrimary,
          outlineLabelColor: AppColors.outline,
        ),
        InventoryStatCardData(
          title: 'Kritik Tarih',
          value: '$criticalCount',
          icon: Icons.warning_amber_rounded,
          backgroundColor: const Color(0xFFF8E2DD),
          foregroundColor: const Color(0xFFB94C3A),
        ),
        InventoryStatCardData(
          title: 'Eco Skoru',
          value: '%$ecoScore',
          icon: Icons.eco_rounded,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          accentIcon: Icons.energy_savings_leaf_rounded,
        ),
      ],
    );
  }

  Future<KitchenShoppingData> loadShoppingData() async {
    final data = await _loadData();
    final groupedByName = <String, ShoppingListItemData>{};

    for (final item in data.missingIngredients) {
      groupedByName[_normalizeName(item.name)] = ShoppingListItemData(
        name: item.name,
        quantity: '${item.quantity} ${item.unit} · ${item.reason}',
        visual: _shoppingVisualForKey(item.iconKey),
      );
    }

    for (final staple in data.frequentIngredients) {
      final currentQuantity = data.inventory
          .where(
            (item) => _normalizeName(item.name) == _normalizeName(staple.name),
          )
          .fold<int>(0, (sum, item) => sum + item.quantity);
      final shortage = staple.desiredQuantity - currentQuantity;
      if (shortage <= 0) {
        continue;
      }

      groupedByName.putIfAbsent(
        _normalizeName(staple.name),
        () => ShoppingListItemData(
          name: staple.name,
          quantity: '$shortage ${staple.unit} · stok yenile',
          visual: _shoppingVisualForKey(staple.iconKey),
        ),
      );
    }

    for (final match in _buildRecipeMatches(data).take(3)) {
      for (final ingredient in match.missingIngredients) {
        groupedByName.putIfAbsent(
          _normalizeName(ingredient.name),
          () => ShoppingListItemData(
            name: ingredient.name,
            quantity:
                '${ingredient.quantity} ${ingredient.unit} · ${match.recipe.title}',
            visual: _shoppingVisualForKey(
              _fallbackIngredientIconKey(ingredient.name),
            ),
          ),
        );
      }
    }

    final sections = <String, List<ShoppingListItemData>>{};
    for (final item in groupedByName.values) {
      final category = _resolveShoppingCategory(data, item.name);
      sections.putIfAbsent(category, () => <ShoppingListItemData>[]).add(item);
    }

    final orderedSections =
        sections.entries
            .map(
              (entry) => KitchenShoppingSection(
                title: entry.key,
                items: entry.value
                  ..sort((left, right) => left.name.compareTo(right.name)),
              ),
            )
            .toList(growable: false)
          ..sort((left, right) => left.title.compareTo(right.title));

    return KitchenShoppingData(sections: orderedSections);
  }

  Future<KitchenHomeData> loadHomeData() async {
    final data = await _loadData();
    final inventory = [...data.inventory]
      ..sort(
        (left, right) => left.daysUntilExpiry.compareTo(right.daysUntilExpiry),
      );
    final matches = _buildRecipeMatches(data);
    final topMatch = matches.first;
    final urgentNames = inventory
        .where((item) => item.daysUntilExpiry <= 3)
        .take(3)
        .map((item) => item.name)
        .join(', ');
    final savingsAmount = inventory
        .where((item) => item.daysUntilExpiry <= 3)
        .fold<int>(0, (sum, item) => sum + (item.quantity * 9));
    final availableCount = topMatch.availableIngredients.length;
    final ingredientCount = topMatch.recipe.ingredients.length;

    return KitchenHomeData(
      displayName: 'Mutfak Kontrolu',
      description: urgentNames.isEmpty
          ? 'Envanterindeki urunlere gore tarifler ve kritik stoklar burada toplanir.'
          : '$urgentNames yakinda tarihi dolacak. Once bu urunleri degerlendirelim.',
      weeklySavingsLabel: '₺$savingsAmount',
      products: inventory
          .take(4)
          .map(
            (item) => ProductCardData(
              name: item.name,
              location: item.category,
              quantity: '${item.quantity} ${item.unit}',
              remainingLabel: _homeRemainingLabel(item.daysUntilExpiry),
              categories: <String>[
                item.category,
                if (item.daysUntilExpiry <= 2) 'Oncelikli',
              ],
              icon: _iconForKey(item.iconKey),
              backgroundColors: _gradientForKey(item.gradientKey),
            ),
          )
          .toList(growable: false),
      suggestion: KitchenHomeSuggestionData(
        title: 'TensorFlow destekli oneri',
        recipeName: topMatch.recipe.title,
        description: topMatch.missingIngredients.isEmpty
            ? '${topMatch.expiringInventory.take(2).map((item) => item.name).join(', ')} ile tarifi bugun eksiksiz cikarabilirsin.'
            : '${topMatch.expiringInventory.take(2).map((item) => item.name).join(', ')} once kullan. $availableCount/$ingredientCount malzeme hazir.',
        buttonLabel: 'Tarife Git',
        routeArguments: _buildRouteArguments(topMatch),
      ),
    );
  }

  Future<_KitchenData> _loadData() {
    return _cachedData ??= _readData();
  }

  Future<_KitchenData> _readData() async {
    final content = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Mock kitchen JSON root must be an object.');
    }

    return _KitchenData.fromJson(decoded);
  }

  List<_RecipeMatch> _buildRecipeMatches(_KitchenData data) {
    final inventoryByName = <String, _InventoryEntry>{
      for (final item in data.inventory) _normalizeName(item.name): item,
    };

    final matches =
        data.recipes
            .map((recipe) {
              final availableIngredients = <_RecipeIngredient>[];
              final missingIngredients = <_RecipeIngredient>[];
              final expiringInventory = <_InventoryEntry>[];
              var score = 0;

              for (final ingredient in recipe.ingredients) {
                final inventoryItem =
                    inventoryByName[_normalizeName(ingredient.name)];
                if (inventoryItem == null ||
                    inventoryItem.unit != ingredient.unit ||
                    inventoryItem.quantity < ingredient.quantity) {
                  missingIngredients.add(ingredient);
                  score -= ingredient.isFrequent ? 22 : 14;
                  continue;
                }

                availableIngredients.add(ingredient);
                expiringInventory.add(inventoryItem);
                score += 24;
                score += (12 - inventoryItem.daysUntilExpiry).clamp(0, 10) * 3;
              }

              expiringInventory.sort(
                (left, right) =>
                    left.daysUntilExpiry.compareTo(right.daysUntilExpiry),
              );
              score +=
                  (recipe.ingredients.length - missingIngredients.length) * 4;

              return _RecipeMatch(
                recipe: recipe,
                score: score,
                availableIngredients: availableIngredients,
                missingIngredients: missingIngredients,
                expiringInventory: expiringInventory,
              );
            })
            .toList(growable: false)
          ..sort((left, right) {
            final scoreCompare = right.score.compareTo(left.score);
            if (scoreCompare != 0) {
              return scoreCompare;
            }

            final missingCompare = left.missingIngredients.length.compareTo(
              right.missingIngredients.length,
            );
            if (missingCompare != 0) {
              return missingCompare;
            }

            return left.recipe.title.compareTo(right.recipe.title);
          });

    return matches;
  }

  Map<String, dynamic> _buildRouteArguments(_RecipeMatch match) {
    return <String, dynamic>{
      'id': match.recipe.id,
      'title': match.recipe.title,
      'duration': match.recipe.duration,
      'tag': match.recipe.tag,
      'gradientColors': _gradientForKey(match.recipe.gradientKey),
      'icon': _iconForKey(match.recipe.iconKey),
      'servings': match.recipe.servings,
      'calories': match.recipe.calories,
      'chefNote': _buildChefNote(match),
      'ingredients': match.recipe.ingredients
          .map(
            (ingredient) =>
                '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
          )
          .toList(growable: false),
      'missingIngredients': match.missingIngredients
          .map(
            (ingredient) =>
                '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
          )
          .toList(growable: false),
      'steps': match.recipe.steps
          .map(
            (step) => <String, dynamic>{
              'title': step.title,
              'description': step.description,
              'showPlaceholder': step.showPlaceholder,
            },
          )
          .toList(growable: false),
    };
  }

  String _buildChefNote(_RecipeMatch match) {
    if (match.missingIngredients.isEmpty &&
        match.expiringInventory.isNotEmpty) {
      return '${match.recipe.chefNote} Önce ${match.expiringInventory.first.name.toLowerCase()} kullan.';
    }

    if (match.missingIngredients.isNotEmpty) {
      final missingNames = match.missingIngredients
          .map((ingredient) => ingredient.name)
          .join(', ');
      return '${match.recipe.chefNote} Eksik malzemeler: $missingNames.';
    }

    return match.recipe.chefNote;
  }

  String _resolveShoppingCategory(_KitchenData data, String itemName) {
    for (final staple in data.frequentIngredients) {
      if (_normalizeName(staple.name) == _normalizeName(itemName)) {
        return staple.category;
      }
    }

    for (final recipe in data.recipes) {
      for (final ingredient in recipe.ingredients) {
        if (_normalizeName(ingredient.name) == _normalizeName(itemName)) {
          return ingredient.category;
        }
      }
    }

    return 'Diğer';
  }

  String _expiryLabel(int daysUntilExpiry) {
    if (daysUntilExpiry <= 0) {
      return 'Bugün kullan';
    }
    if (daysUntilExpiry == 1) {
      return '1 gün içinde kullan';
    }
    if (daysUntilExpiry == 2) {
      return '2 gün içinde kullan';
    }
    return '$daysUntilExpiry gün içinde kullan';
  }

  String _homeRemainingLabel(int daysUntilExpiry) {
    if (daysUntilExpiry <= 0) {
      return 'BUGUN';
    }
    if (daysUntilExpiry == 1) {
      return '1 GUN';
    }
    return '$daysUntilExpiry GUN';
  }

  ShoppingListVisual _shoppingVisualForKey(String key) {
    return ShoppingListVisual.icon(
      icon: _iconForKey(key),
      backgroundColor: AppColors.surfaceContainerLow,
      foregroundColor: AppColors.primary,
    );
  }

  String _fallbackIngredientIconKey(String ingredientName) {
    final normalized = _normalizeName(ingredientName);
    if (normalized.contains('sogan')) {
      return 'onion';
    }
    if (normalized.contains('sarimsak')) {
      return 'garlic';
    }
    if (normalized.contains('zeytinyagi')) {
      return 'oil';
    }
    if (normalized.contains('limon')) {
      return 'lemon';
    }
    if (normalized.contains('domates')) {
      return 'tomato';
    }
    return 'spinach';
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'yogurt':
        return Icons.breakfast_dining_rounded;
      case 'spinach':
        return Icons.spa_rounded;
      case 'mushroom':
        return Icons.eco_rounded;
      case 'tortilla':
        return Icons.bakery_dining_rounded;
      case 'tomato':
        return Icons.local_pizza_rounded;
      case 'egg':
        return Icons.egg_alt_rounded;
      case 'milk':
        return Icons.local_drink_rounded;
      case 'rice':
        return Icons.rice_bowl_rounded;
      case 'pasta':
        return Icons.ramen_dining_rounded;
      case 'onion':
        return Icons.grass_rounded;
      case 'garlic':
        return Icons.eco_outlined;
      case 'oil':
        return Icons.water_drop_rounded;
      case 'lemon':
        return Icons.wb_sunny_outlined;
      case 'omelet':
        return Icons.egg_alt_rounded;
      case 'wrap':
        return Icons.lunch_dining_rounded;
      case 'skillet':
        return Icons.restaurant_rounded;
      case 'pastaPlate':
        return Icons.ramen_dining_rounded;
      case 'dessert':
        return Icons.icecream_rounded;
      case 'ricePlate':
        return Icons.rice_bowl_rounded;
      default:
        return Icons.restaurant_menu_rounded;
    }
  }

  List<Color> _gradientForKey(String key) {
    switch (key) {
      case 'coolMint':
        return const [Color(0xFF8DC9A7), Color(0xFF4F7E63)];
      case 'freshLeaf':
        return const [Color(0xFF89B86B), Color(0xFF46683F)];
      case 'earthMushroom':
        return const [Color(0xFFAF8C74), Color(0xFF6A4E42)];
      case 'warmBread':
        return const [Color(0xFFE4B676), Color(0xFF9A6C32)];
      case 'tomatoGlow':
        return const [Color(0xFFE88B7A), Color(0xFFB24A41)];
      case 'eggSun':
        return const [Color(0xFFF7D27C), Color(0xFFCC8B39)];
      case 'milkBlue':
        return const [Color(0xFFB4D9E8), Color(0xFF5C8798)];
      case 'riceCream':
        return const [Color(0xFFE7DFC7), Color(0xFFB79D63)];
      case 'pastaGold':
        return const [Color(0xFFF2C063), Color(0xFFB47431)];
      case 'omeletGreen':
        return const [Color(0xFF9BCB7C), Color(0xFF4B6D40)];
      case 'wrapFresh':
        return const [Color(0xFF88C7BC), Color(0xFF3D6E66)];
      case 'menemenWarm':
        return const [Color(0xFFF1A07A), Color(0xFFC35A3C)];
      case 'pastaBrown':
        return const [Color(0xFFD5B17E), Color(0xFF7C5A3D)];
      case 'dessertCream':
        return const [Color(0xFFF0DDC0), Color(0xFFB28A55)];
      case 'pilafGold':
        return const [Color(0xFFE3BE73), Color(0xFF8C6535)];
      default:
        return const [Color(0xFF92A87B), Color(0xFF4C673C)];
    }
  }

  String _normalizeName(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c')
        .trim();
  }
}

class _KitchenData {
  const _KitchenData({
    required this.inventory,
    required this.frequentIngredients,
    required this.missingIngredients,
    required this.featuredInfo,
    required this.seasonalHighlight,
    required this.recipes,
  });

  factory _KitchenData.fromJson(Map<String, dynamic> json) {
    final seasonalMap =
        json['seasonalHighlight'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    return _KitchenData(
      inventory: (json['inventory'] as List? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_InventoryEntry.fromJson)
          .toList(growable: false),
      frequentIngredients:
          (json['frequentIngredients'] as List? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(_FrequentIngredient.fromJson)
              .toList(growable: false),
      missingIngredients:
          ((json['missingIngredients'] as Map<String, dynamic>? ??
                          const <String, dynamic>{})['items']
                      as List? ??
                  const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(_ShoppingEntry.fromJson)
              .toList(growable: false),
      featuredInfo: _FeaturedInfoEntry.fromJson(
        json['featuredInfo'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      seasonalHighlight: KitchenSeasonalHighlightData(
        eyebrow: seasonalMap['eyebrow'] as String? ?? '',
        title: seasonalMap['title'] as String? ?? '',
        description: seasonalMap['description'] as String? ?? '',
        actionLabel: seasonalMap['actionLabel'] as String? ?? '',
      ),
      recipes: (json['recipes'] as List? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_RecipeEntry.fromJson)
          .toList(growable: false),
    );
  }

  final List<_InventoryEntry> inventory;
  final List<_FrequentIngredient> frequentIngredients;
  final List<_ShoppingEntry> missingIngredients;
  final _FeaturedInfoEntry featuredInfo;
  final KitchenSeasonalHighlightData seasonalHighlight;
  final List<_RecipeEntry> recipes;
}

class _InventoryEntry {
  const _InventoryEntry({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.daysUntilExpiry,
    required this.iconKey,
    required this.gradientKey,
  });

  factory _InventoryEntry.fromJson(Map<String, dynamic> json) {
    return _InventoryEntry(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      daysUntilExpiry: (json['daysUntilExpiry'] as num?)?.toInt() ?? 30,
      iconKey: json['iconKey'] as String? ?? '',
      gradientKey: json['gradientKey'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final int quantity;
  final String unit;
  final String category;
  final int daysUntilExpiry;
  final String iconKey;
  final String gradientKey;
}

class _FrequentIngredient {
  const _FrequentIngredient({
    required this.name,
    required this.desiredQuantity,
    required this.unit,
    required this.category,
    required this.iconKey,
  });

  factory _FrequentIngredient.fromJson(Map<String, dynamic> json) {
    return _FrequentIngredient(
      name: json['name'] as String? ?? '',
      desiredQuantity: (json['desiredQuantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      iconKey: json['iconKey'] as String? ?? '',
    );
  }

  final String name;
  final int desiredQuantity;
  final String unit;
  final String category;
  final String iconKey;
}

class _ShoppingEntry {
  const _ShoppingEntry({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.reason,
    required this.iconKey,
  });

  factory _ShoppingEntry.fromJson(Map<String, dynamic> json) {
    return _ShoppingEntry(
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      reason: json['reason'] as String? ?? 'Eksik',
      iconKey: json['iconKey'] as String? ?? '',
    );
  }

  final String name;
  final int quantity;
  final String unit;
  final String category;
  final String reason;
  final String iconKey;
}

class _FeaturedInfoEntry {
  const _FeaturedInfoEntry({
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  factory _FeaturedInfoEntry.fromJson(Map<String, dynamic> json) {
    return _FeaturedInfoEntry(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? 'Tarifi Aç',
    );
  }

  final String title;
  final String description;
  final String actionLabel;
}

class _RecipeEntry {
  const _RecipeEntry({
    required this.id,
    required this.title,
    required this.tag,
    required this.duration,
    required this.servings,
    required this.calories,
    required this.chefNote,
    required this.sustainabilityLabel,
    required this.iconKey,
    required this.gradientKey,
    required this.ingredients,
    required this.steps,
  });

  factory _RecipeEntry.fromJson(Map<String, dynamic> json) {
    return _RecipeEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      servings: json['servings'] as String? ?? '',
      calories: json['calories'] as String? ?? '',
      chefNote: json['chefNote'] as String? ?? '',
      sustainabilityLabel: json['sustainabilityLabel'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? '',
      gradientKey: json['gradientKey'] as String? ?? '',
      ingredients: (json['ingredients'] as List? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_RecipeIngredient.fromJson)
          .toList(growable: false),
      steps: (json['steps'] as List? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_RecipeStep.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final String title;
  final String tag;
  final String duration;
  final String servings;
  final String calories;
  final String chefNote;
  final String sustainabilityLabel;
  final String iconKey;
  final String gradientKey;
  final List<_RecipeIngredient> ingredients;
  final List<_RecipeStep> steps;
}

class _RecipeIngredient {
  const _RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.isFrequent,
  });

  factory _RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return _RecipeIngredient(
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      isFrequent: json['isFrequent'] as bool? ?? false,
    );
  }

  final String name;
  final int quantity;
  final String unit;
  final String category;
  final bool isFrequent;
}

class _RecipeStep {
  const _RecipeStep({
    required this.title,
    required this.description,
    required this.showPlaceholder,
  });

  factory _RecipeStep.fromJson(Map<String, dynamic> json) {
    return _RecipeStep(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      showPlaceholder: json['showPlaceholder'] as bool? ?? false,
    );
  }

  final String title;
  final String description;
  final bool showPlaceholder;
}

class _RecipeMatch {
  const _RecipeMatch({
    required this.recipe,
    required this.score,
    required this.availableIngredients,
    required this.missingIngredients,
    required this.expiringInventory,
  });

  final _RecipeEntry recipe;
  final int score;
  final List<_RecipeIngredient> availableIngredients;
  final List<_RecipeIngredient> missingIngredients;
  final List<_InventoryEntry> expiringInventory;
}
