import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenFoodFactsLookupResult {
  const OpenFoodFactsLookupResult({
    required this.barcode,
    required this.found,
    this.productName,
    this.genericName,
    this.brand,
    this.quantity,
    this.imageUrl,
    this.suggestedCategory,
    this.quickSuggestions = const [],
  });

  final String barcode;
  final bool found;
  final String? productName;
  final String? genericName;
  final String? brand;
  final String? quantity;
  final String? imageUrl;
  final String? suggestedCategory;
  final List<String> quickSuggestions;

  String? get preferredName {
    if (productName != null && productName!.trim().isNotEmpty) {
      return productName!.trim();
    }
    if (genericName != null && genericName!.trim().isNotEmpty) {
      return genericName!.trim();
    }
    return null;
  }
}

class OpenFoodFactsService {
  OpenFoodFactsService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _baseUri = Uri.https('world.openfoodfacts.org');

  Future<OpenFoodFactsLookupResult> fetchProduct(String barcode) async {
    final uri = _baseUri.replace(
      path: '/api/v2/product/$barcode',
      queryParameters: {
        'fields':
            'code,product_name,generic_name,brands,quantity,image_url,categories_tags',
      },
    );

    final response = await _client.get(
      uri,
      headers: const {
        'User-Agent': 'MutfakAsistanim/1.0 (Flutter barcode scanner)',
        'Accept-Language': 'tr,en;q=0.8',
      },
    );

    if (response.statusCode != 200) {
      throw OpenFoodFactsException(
        'Ürün bilgisi alınamadı. Sunucu ${response.statusCode} döndürdü.',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw const OpenFoodFactsException(
        'Ürün bilgisi okunamadı. Beklenmeyen bir yanıt geldi.',
      );
    }

    final status = json['status'];
    if (status != 1) {
      return OpenFoodFactsLookupResult(barcode: barcode, found: false);
    }

    final product = json['product'];
    if (product is! Map<String, dynamic>) {
      return OpenFoodFactsLookupResult(barcode: barcode, found: false);
    }

    final productName = _readText(product['product_name']);
    final genericName = _readText(product['generic_name']);
    final brand = _readPrimaryBrand(product['brands']);
    final quantity = _readText(product['quantity']);
    final imageUrl = _readText(product['image_url']);
    final categories = _readStringList(product['categories_tags']);

    return OpenFoodFactsLookupResult(
      barcode: barcode,
      found: true,
      productName: productName,
      genericName: genericName,
      brand: brand,
      quantity: quantity,
      imageUrl: imageUrl,
      suggestedCategory: _mapCategory(categories),
      quickSuggestions: _buildQuickSuggestions(
        productName: productName,
        genericName: genericName,
        brand: brand,
      ),
    );
  }

  void dispose() {
    _client.close();
  }

  static String? _readText(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static String? _readPrimaryBrand(Object? value) {
    final brand = _readText(value);
    if (brand == null) {
      return null;
    }

    return brand
        .split(',')
        .map((part) => part.trim())
        .firstWhere((part) => part.isNotEmpty, orElse: () => brand);
  }

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    final text = _readText(value);
    if (text == null) {
      return const [];
    }

    return text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _buildQuickSuggestions({
    required String? productName,
    required String? genericName,
    required String? brand,
  }) {
    final suggestions = <String>[];
    for (final value in [productName, genericName, brand]) {
      if (value == null || value.trim().isEmpty) {
        continue;
      }

      final normalized = value.trim();
      if (!suggestions.contains(normalized)) {
        suggestions.add(normalized);
      }
    }
    return suggestions;
  }

  static String _normalizeTag(String tag) {
    final colonIndex = tag.indexOf(':');
    final rawTag = colonIndex >= 0 ? tag.substring(colonIndex + 1) : tag;
    return rawTag.replaceAll('-', ' ').toLowerCase();
  }

  static String? _mapCategory(List<String> categories) {
    final normalized = categories.map(_normalizeTag).join(' ');

    if (_containsAny(normalized, [
      'milk',
      'dairy',
      'yogurt',
      'cheese',
      'cream',
    ])) {
      return 'Süt Ürünleri';
    }
    if (_containsAny(normalized, [
      'drink',
      'beverage',
      'juice',
      'water',
      'tea',
      'coffee',
    ])) {
      return 'İçecekler';
    }
    if (_containsAny(normalized, [
      'snack',
      'biscuit',
      'chocolate',
      'dessert',
      'candy',
    ])) {
      return 'Atıştırmalık';
    }
    if (_containsAny(normalized, ['frozen'])) {
      return 'Dondurulmuş';
    }
    if (_containsAny(normalized, [
      'meat',
      'fish',
      'chicken',
      'sausage',
      'turkey',
    ])) {
      return 'Et & Tavuk';
    }
    if (_containsAny(normalized, ['fruit', 'vegetable', 'salad'])) {
      return 'Meyve & Sebze';
    }
    if (_containsAny(normalized, ['canned', 'conserve'])) {
      return 'Konserve';
    }
    if (_containsAny(normalized, [
      'legume',
      'rice',
      'pasta',
      'cereal',
      'grain',
      'flour',
    ])) {
      return 'Kuru Gıda';
    }
    if (_containsAny(normalized, ['spice', 'sauce', 'seasoning'])) {
      return 'Baharat & Sos';
    }
    return null;
  }

  static bool _containsAny(String value, List<String> needles) {
    for (final needle in needles) {
      if (value.contains(needle)) {
        return true;
      }
    }
    return false;
  }
}

class OpenFoodFactsException implements Exception {
  const OpenFoodFactsException(this.message);

  final String message;

  @override
  String toString() => message;
}
