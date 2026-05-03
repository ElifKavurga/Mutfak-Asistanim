import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../widgets/featured_bento_cards.dart';
import '../widgets/inventory_item_tile.dart';
import '../widgets/inventory_stat_card.dart';
import '../widgets/product_card.dart';
import '../widgets/recipe_grid_card.dart';
import 'mock_kitchen_data_service.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

class KitchenNotificationData {
  const KitchenNotificationData({
    required this.id,
    required this.message,
    required this.sendingDate,
    required this.isRead,
    required this.inventoryId,
    required this.productName,
  });

  final int id;
  final String message;
  final DateTime? sendingDate;
  final bool isRead;
  final int? inventoryId;
  final String productName;
}

class BackendApiService {
  BackendApiService._({http.Client? client})
    : _client = client ?? http.Client();

  static final BackendApiService instance = BackendApiService._();

  static const List<String> supportedCategoryLabels = <String>[
    'Meyve',
    'Sebze',
    'Et',
    'Sut Urunleri',
    'Tahil / Kuru Gida',
    'Icecekler',
    'Atistirmalik',
  ];

  static const List<String> supportedUnitLabels = <String>[
    'Adet',
    'Kg',
    'Litre',
  ];

  static const String allFilterLabel = 'Tumu';
  static const int _defaultLocalApiPort = 8081;
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  final http.Client _client;

  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  Future<void> authenticate({
    required String username,
    required String password,
  }) async {
    final payload = await _request(
      method: 'POST',
      path: '/authenticate',
      requiresAuth: false,
      body: <String, dynamic>{'username': username, 'password': password},
    );
    _applyTokens(payload);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    await _request(
      method: 'POST',
      path: '/register',
      requiresAuth: false,
      body: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      },
    );
  }

  Future<void> registerAndAuthenticate({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    await register(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
    );
    await authenticate(username: username, password: password);
  }

  void clearSession() {
    _accessToken = null;
    _refreshToken = null;
  }

  String normalizeCategoryLabel(String? rawLabel) {
    final normalized = _normalizeText(rawLabel);
    if (normalized.isEmpty) {
      return supportedCategoryLabels.first;
    }

    if (_containsAny(normalized, <String>['meyve'])) {
      return 'Meyve';
    }
    if (_containsAny(normalized, <String>['sebze', 'yesillik'])) {
      return 'Sebze';
    }
    if (_containsAny(normalized, <String>['et', 'tavuk', 'balik'])) {
      return 'Et';
    }
    if (_containsAny(normalized, <String>['sut', 'peynir', 'yogurt'])) {
      return 'Sut Urunleri';
    }
    if (_containsAny(normalized, <String>['tahil', 'kuru gida', 'bakliyat'])) {
      return 'Tahil / Kuru Gida';
    }
    if (_containsAny(normalized, <String>['icecek', 'mesrubat'])) {
      return 'Icecekler';
    }
    if (_containsAny(normalized, <String>[
      'atistirmalik',
      'cikolata',
      'biskuvi',
    ])) {
      return 'Atistirmalik';
    }

    return supportedCategoryLabels.first;
  }

  String normalizeUnitLabel(String? rawLabel) {
    final normalized = _normalizeText(rawLabel);
    if (normalized.contains('kg') || normalized.contains('kilo')) {
      return 'Kg';
    }
    if (normalized.contains('litre') || normalized.contains('ltr')) {
      return 'Litre';
    }
    return 'Adet';
  }

  String createFallbackBarcode(String productName) {
    final slug = _normalizeText(productName).replaceAll(' ', '-');
    final suffix = DateTime.now().millisecondsSinceEpoch;
    return 'manual-${slug.isEmpty ? 'urun' : slug}-$suffix';
  }

  Future<KitchenHomeData> loadHomeData() async {
    final payload = await _request(method: 'GET', path: '/dashboard');
    final dashboard = _DashboardDto.fromJson(_asMap(payload));
    final hasInventory = dashboard.totalInventoryCount > 0;

    var suggestionRecipe = dashboard.recommendedRecipes.isNotEmpty
        ? dashboard.recommendedRecipes.first
        : null;
    if (suggestionRecipe == null && hasInventory) {
      final recipes = await _loadRecipeList('/rest/api/recipe/list');
      if (recipes.isNotEmpty) {
        suggestionRecipe = recipes.first;
      }
    }

    final expiringProducts = dashboard.expiringProducts
      ..sort((left, right) {
        final leftDate = left.expirationDate ?? DateTime(9999);
        final rightDate = right.expirationDate ?? DateTime(9999);
        return leftDate.compareTo(rightDate);
      });

    final expiringNames = expiringProducts
        .take(3)
        .map((item) => item.product.productName)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    return KitchenHomeData(
      displayName: dashboard.username.trim().isEmpty
          ? 'Mutfagina Hos Geldin'
          : 'Merhaba, ${dashboard.username}',
      description: expiringNames.isNotEmpty
          ? '$expiringNames yakinda son kullanma tarihine ulasacak. Once bunlari degerlendirebilirsin.'
          : (hasInventory
                ? '${dashboard.totalInventoryCount} urun takip ediliyor. Mutfak ozetin guncel durumda.'
                : 'Hesabin hazir. Urun ekledikce envanter ve tarif onerileri burada dolacak.'),
      weeklySavingsLabel: '${dashboard.totalInventoryCount}',
      products: expiringProducts.take(4).map(_toProductCardData).toList(),
      suggestion: suggestionRecipe == null
          ? null
          : KitchenHomeSuggestionData(
              title: 'Bugun Icin Oneri',
              recipeName: suggestionRecipe.recipeName,
              description:
                  dashboard.recommendedRecipes.any(
                    (recipe) => recipe.id == suggestionRecipe!.id,
                  )
                  ? 'Eldeki malzemelere gore uygun bir tarif one cikarildi.'
                  : 'Tarif arsivinden populer bir secim hazirlandi.',
              buttonLabel: 'Tarifi Ac',
              routeArguments: _buildRecipeRouteArgumentsFromSummary(
                suggestionRecipe,
                tag: _recipeTag(
                  suggestionRecipe,
                  isRecommended: dashboard.recommendedRecipes.any(
                    (recipe) => recipe.id == suggestionRecipe!.id,
                  ),
                ),
              ),
            ),
    );
  }

  Future<KitchenInventoryData> loadInventoryData() async {
    final payload = await _request(
      method: 'GET',
      path: '/rest/api/inventory/list',
    );
    final inventories =
        _asList(
            payload,
          ).map((item) => _InventoryDto.fromJson(_asMap(item))).toList()
          ..sort((left, right) {
            final leftDate = left.expirationDate ?? DateTime(9999);
            final rightDate = right.expirationDate ?? DateTime(9999);
            return leftDate.compareTo(rightDate);
          });

    final categories = <String>{
      allFilterLabel,
      ...inventories.map((item) => _categoryLabel(item.product.categoryType)),
    }.toList();

    final expiringSoonCount = inventories.where((item) {
      final days = _daysUntil(item.expirationDate);
      return days != null && days <= 7;
    }).length;

    return KitchenInventoryData(
      categories: categories,
      items: inventories.map(_toInventoryItemData).toList(),
      stats:
          <InventoryStatCardData>[
                const InventoryStatCardData(
                  title: 'Toplam Urun',
                  value: '0',
                  icon: Icons.inventory_2_rounded,
                  backgroundColor: AppColors.surfaceContainerLow,
                  foregroundColor: AppColors.textPrimary,
                  outlineLabelColor: AppColors.outline,
                ),
                const InventoryStatCardData(
                  title: 'Yakinda Bitecek',
                  value: '0',
                  icon: Icons.warning_amber_rounded,
                  backgroundColor: Color(0xFFF8E2DD),
                  foregroundColor: Color(0xFFB94C3A),
                ),
                const InventoryStatCardData(
                  title: 'Kategori',
                  value: '0',
                  icon: Icons.category_rounded,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  accentIcon: Icons.energy_savings_leaf_rounded,
                ),
              ]
              .asMap()
              .entries
              .map((entry) {
                switch (entry.key) {
                  case 0:
                    return InventoryStatCardData(
                      title: entry.value.title,
                      value: '${inventories.length}',
                      icon: entry.value.icon,
                      backgroundColor: entry.value.backgroundColor,
                      foregroundColor: entry.value.foregroundColor,
                      accentIcon: entry.value.accentIcon,
                      outlineLabelColor: entry.value.outlineLabelColor,
                    );
                  case 1:
                    return InventoryStatCardData(
                      title: entry.value.title,
                      value: '$expiringSoonCount',
                      icon: entry.value.icon,
                      backgroundColor: entry.value.backgroundColor,
                      foregroundColor: entry.value.foregroundColor,
                      accentIcon: entry.value.accentIcon,
                      outlineLabelColor: entry.value.outlineLabelColor,
                    );
                  default:
                    return InventoryStatCardData(
                      title: entry.value.title,
                      value: '${categories.length - 1}',
                      icon: entry.value.icon,
                      backgroundColor: entry.value.backgroundColor,
                      foregroundColor: entry.value.foregroundColor,
                      accentIcon: entry.value.accentIcon,
                      outlineLabelColor: entry.value.outlineLabelColor,
                    );
                }
              })
              .toList(growable: false),
    );
  }

  Future<InventoryItemData> updateInventoryQuantity({
    required InventoryItemData item,
    required num quantity,
  }) async {
    if (item.inventoryId == null ||
        item.unitTypeCode == null ||
        item.expirationDate == null) {
      throw const ApiException(
        'Envanter kaydi eksik oldugu icin guncellenemedi.',
      );
    }

    final payload = await _request(
      method: 'PUT',
      path: '/rest/api/inventory/update/${item.inventoryId}',
      body: <String, dynamic>{
        'quantity': quantity,
        'unitType': item.unitTypeCode,
        'expirationDate': _formatBackendDate(item.expirationDate!),
      },
    );

    return _toInventoryItemData(_InventoryDto.fromJson(_asMap(payload)));
  }

  Future<KitchenRecipeDiscoveryData> loadRecipeDiscoveryData() async {
    final dashboardPayload = await _request(method: 'GET', path: '/dashboard');
    final dashboard = _DashboardDto.fromJson(_asMap(dashboardPayload));

    if (dashboard.totalInventoryCount <= 0) {
      return _buildEmptyRecipeDiscoveryData(
        infoTitle: 'Tarif onerileri icin once urun ekle',
        infoDescription:
            'Bu hesapta henuz envanter kaydi olmadigi icin '
            'tarif listesi bilincli olarak bos birakildi.',
        seasonalTitle: 'Envanter doldukca tarifler burada acilacak',
        seasonalDescription:
            'Yeni giris yapan kullanicilar bos baslar. '
            'Urun ekledikten sonra sana uygun tarifler burada listelenir.',
      );
    }

    final allRecipes = await _loadRecipeList('/rest/api/recipe/list');
    final recommendedRecipes = dashboard.recommendedRecipes;
    final mergedRecipes = _mergeRecipes(recommendedRecipes, allRecipes);

    if (mergedRecipes.isEmpty) {
      return _buildEmptyRecipeDiscoveryData(
        infoTitle: 'Su an tarif bulunmuyor',
        infoDescription:
            'Goruntulenecek tarif olmadigi icin liste simdilik bos gorunuyor.',
        seasonalTitle: 'Yeni tarifler yolda',
        seasonalDescription:
            'Yeni tarifler eklendikce bu alan otomatik olarak guncellenecek.',
      );
    }

    final categories = <String>{
      allFilterLabel,
      ...mergedRecipes.map(
        (recipe) => _recipeTag(
          recipe,
          isRecommended: recommendedRecipes.any(
            (recommended) => recommended.id == recipe.id,
          ),
        ),
      ),
    }.toList();

    final featuredRecipe = mergedRecipes.first;
    final isFeaturedRecommended = recommendedRecipes.any(
      (recipe) => recipe.id == featuredRecipe.id,
    );

    return KitchenRecipeDiscoveryData(
      categories: categories,
      featuredRecipe: _toFeaturedRecipeData(
        featuredRecipe,
        isRecommended: isFeaturedRecommended,
      ),
      infoCard: FeaturedInfoCardData(
        title: 'Sana Uygun Tarif',
        description: isFeaturedRecommended
            ? 'Bu tarif, mevcut envanterinle uyumlu gorunen oneriler arasindan secildi.'
            : 'Tum tarifler arasindan sana uygun secenekleri filtreleyerek kolayca bulabilirsin.',
        actionLabel: 'Tarifi Incele',
        routeArguments: _buildRecipeRouteArgumentsFromSummary(
          featuredRecipe,
          tag: _recipeTag(featuredRecipe, isRecommended: isFeaturedRecommended),
        ),
      ),
      recipes: mergedRecipes
          .map(
            (recipe) => _toRecipeCardData(
              recipe,
              isRecommended: recommendedRecipes.any(
                (recommended) => recommended.id == recipe.id,
              ),
            ),
          )
          .toList(growable: false),
      seasonalHighlight: const KitchenSeasonalHighlightData(
        eyebrow: 'MENUNU PLANLA',
        title: 'Tarifleri kolayca kesfet',
        description:
            'Arama ve filtreleri birlikte kullanarak sana uygun tarifi daha hizli bulabilirsin.',
        actionLabel: 'Tarifleri Gor',
      ),
    );
  }

  KitchenRecipeDiscoveryData _buildEmptyRecipeDiscoveryData({
    required String infoTitle,
    required String infoDescription,
    required String seasonalTitle,
    required String seasonalDescription,
  }) {
    const fallbackRecipe = FeaturedRecipeData(
      badge: 'TARIF',
      title: 'Tarif Bulunamadi',
      duration: '0 dk',
      sustainabilityLabel: 'Henuz Hazir Degil',
      gradientColors: <Color>[Color(0xFF92A87B), Color(0xFF4C673C)],
    );

    return KitchenRecipeDiscoveryData(
      categories: const <String>[allFilterLabel],
      featuredRecipe: fallbackRecipe,
      infoCard: FeaturedInfoCardData(
        title: infoTitle,
        description: infoDescription,
        actionLabel: 'Yenile',
      ),
      recipes: const <RecipeCardData>[],
      seasonalHighlight: KitchenSeasonalHighlightData(
        eyebrow: 'KESFET',
        title: seasonalTitle,
        description: seasonalDescription,
        actionLabel: 'Tekrar Goz At',
      ),
    );
  }

  Future<Map<String, dynamic>> loadRecipeRouteArguments({
    required int recipeId,
    Map<String, dynamic>? fallbackArguments,
  }) async {
    final payload = await _request(
      method: 'GET',
      path: '/rest/api/recipe/$recipeId',
    );
    final detail = _RecipeDetailDto.fromJson(_asMap(payload));
    return _buildRecipeRouteArgumentsFromDetail(
      detail,
      fallbackArguments: fallbackArguments,
    );
  }

  Future<List<KitchenNotificationData>> loadNotifications() async {
    final payload = await _request(
      method: 'GET',
      path: '/rest/api/notifications/list',
    );
    return _asList(payload)
        .map((item) => _NotificationDto.fromJson(_asMap(item)))
        .map(
          (dto) => KitchenNotificationData(
            id: dto.id,
            message: dto.message,
            sendingDate: dto.sendingDate,
            isRead: dto.isRead,
            inventoryId: dto.inventoryId,
            productName: dto.productName,
          ),
        )
        .toList(growable: false);
  }

  Future<void> markNotificationAsRead(int id) async {
    await _request(method: 'PATCH', path: '/rest/api/notifications/$id/read');
  }

  Future<void> markAllNotificationsAsRead() async {
    await _request(method: 'PATCH', path: '/rest/api/notifications/read-all');
  }

  Future<void> deleteNotification(int id) async {
    await _request(
      method: 'DELETE',
      path: '/rest/api/notifications/delete/$id',
    );
  }

  Future<void> deleteAllNotifications() async {
    await _request(
      method: 'DELETE',
      path: '/rest/api/notifications/delete-all',
    );
  }

  Future<void> createProductAndInventory({
    required String productName,
    required String barcode,
    required String categoryLabel,
    required num quantity,
    required String unitLabel,
    required DateTime expirationDate,
    String? productImageUrl,
  }) async {
    final productPayload = await _request(
      method: 'POST',
      path: '/rest/api/product/save',
      body: <String, dynamic>{
        'productName': productName,
        'barcode': barcode,
        'productImageUrl': productImageUrl,
        'categoryType': _categoryCode(categoryLabel),
      },
    );

    final product = _ProductDto.fromJson(_asMap(productPayload));

    await _request(
      method: 'POST',
      path: '/rest/api/inventory/save',
      body: <String, dynamic>{
        'quantity': quantity,
        'unitType': _unitCode(unitLabel),
        'expirationDate': _formatBackendDate(expirationDate),
        'productId': product.id,
      },
    );
  }

  Future<List<_RecipeSummaryDto>> _loadRecipeList(String path) async {
    final payload = await _request(method: 'GET', path: path);
    return _asList(payload)
        .map((item) => _RecipeSummaryDto.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<dynamic> _request({
    required String method,
    required String path,
    Map<String, String>? queryParameters,
    Object? body,
    bool requiresAuth = true,
    bool allowRefresh = true,
  }) async {
    if (requiresAuth && !isAuthenticated) {
      throw const ApiException(
        'Oturum bulunamadi. Lutfen tekrar giris yapin.',
        statusCode: 401,
      );
    }

    final uri = _buildUri(path, queryParameters: queryParameters);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (requiresAuth && _accessToken != null)
        'Authorization': 'Bearer $_accessToken',
    };

    late final http.Response response;
    final encodedBody = body == null ? null : jsonEncode(body);

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;
        case 'PUT':
          response = await _client.put(uri, headers: headers, body: encodedBody);
          break;
        case 'PATCH':
          response = await _client.patch(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;
        case 'DELETE':
          response = await _client.delete(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;
        default:
          throw ApiException('Desteklenmeyen HTTP metodu: $method');
      }
    } on http.ClientException catch (error) {
      throw _toConnectionException(error, uri);
    } catch (error) {
      if (_looksLikeConnectionIssue(error)) {
        throw _toConnectionException(error, uri);
      }
      rethrow;
    }

    if (response.statusCode == 401 && allowRefresh && _refreshToken != null) {
      await _refreshAccessToken();
      return _request(
        method: method,
        path: path,
        queryParameters: queryParameters,
        body: body,
        requiresAuth: requiresAuth,
        allowRefresh: false,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _toApiException(response);
    }

    final rawBody = utf8.decode(response.bodyBytes);
    if (rawBody.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawBody);
    if (decoded is Map<String, dynamic> && decoded.containsKey('payload')) {
      return decoded['payload'];
    }

    return decoded;
  }

  Future<void> _refreshAccessToken() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      clearSession();
      throw const ApiException(
        'Oturum suresi doldu. Lutfen yeniden giris yapin.',
        statusCode: 401,
      );
    }

    final payload = await _request(
      method: 'POST',
      path: '/refreshToken',
      requiresAuth: false,
      allowRefresh: false,
      body: <String, dynamic>{'refreshToken': refreshToken},
    );
    _applyTokens(payload);
  }

  void _applyTokens(dynamic payload) {
    final map = _asMap(payload);
    final accessToken = map['accessToken']?.toString().trim() ?? '';
    final refreshToken = map['refreshToken']?.toString().trim() ?? '';

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const ApiException(
        'Kimlik dogrulama yaniti beklenen token alanlarini icermiyor.',
      );
    }

    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  ApiException _toApiException(http.Response response) {
    final rawBody = utf8.decode(response.bodyBytes);
    if (rawBody.trim().isEmpty) {
      return ApiException(
        'Sunucu ${response.statusCode} kodu ile bos bir yanit dondu.',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(rawBody);
      final message = _extractErrorMessage(decoded);
      return ApiException(message, statusCode: response.statusCode);
    } catch (_) {
      return ApiException(rawBody, statusCode: response.statusCode);
    }
  }

  ApiException _toConnectionException(Object error, Uri uri) {
    final addressHint = _isLoopbackHost(uri.host)
        ? 'Uygulamayi farkli bir cihazdan calistiriyorsan --dart-define=API_BASE_URL=http://<bilgisayar-ip>:$_defaultLocalApiPort kullan.'
        : 'API_BASE_URL ayarini ve sunucunun calistigini kontrol edin.';
    return ApiException(
      'Sunucuya baglanilamadi. ${uri.toString()} adresine ulasilamadi. $addressHint',
    );
  }

  bool _looksLikeConnectionIssue(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('connection refused') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('no route to host') ||
        message.contains('socketexception') ||
        message.contains('xmlhttprequest error');
  }

  String _extractErrorMessage(dynamic decoded) {
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }
    if (decoded is Map<String, dynamic>) {
      if (decoded['errorMessage'] is String &&
          (decoded['errorMessage'] as String).trim().isNotEmpty) {
        return (decoded['errorMessage'] as String).trim();
      }

      if (decoded['exception'] is Map<String, dynamic>) {
        return _extractErrorMessage(
          (decoded['exception'] as Map<String, dynamic>)['message'],
        );
      }

      final buffer = <String>[];
      decoded.forEach((key, value) {
        final valueText = _extractErrorMessage(value);
        if (valueText.trim().isNotEmpty) {
          buffer.add('$key: $valueText');
        }
      });
      if (buffer.isNotEmpty) {
        return buffer.join('\n');
      }
    }

    if (decoded is List) {
      final messages = decoded
          .map(_extractErrorMessage)
          .where((message) => message.trim().isNotEmpty)
          .toList(growable: false);
      if (messages.isNotEmpty) {
        return messages.join(', ');
      }
    }

    return 'Istek islenemedi.';
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    if (_configuredBaseUrl.isNotEmpty) {
      final baseUri = Uri.parse(_configuredBaseUrl);
      return baseUri.resolveUri(
        Uri(
          path: normalizedPath.substring(1),
          queryParameters: queryParameters,
        ),
      );
    }

    if (kIsWeb) {
      final currentOrigin = Uri.base;
      if (_isLoopbackHost(currentOrigin.host) || currentOrigin.host == '0.0.0.0') {
        return Uri(
          scheme: 'http',
          host: _defaultApiHost(),
          port: _defaultLocalApiPort,
          path: normalizedPath,
          queryParameters: queryParameters,
        );
      }

      return currentOrigin.resolveUri(
        Uri(
          path: normalizedPath.substring(1),
          queryParameters: queryParameters,
        ),
      );
    }

    return Uri(
      scheme: 'http',
      host: _defaultApiHost(),
      port: _defaultLocalApiPort,
      path: normalizedPath,
      queryParameters: queryParameters,
    );
  }

  String _defaultApiHost() {
    if (kIsWeb) {
      final currentHost = Uri.base.host.trim();
      if (currentHost.isEmpty || currentHost == '0.0.0.0') {
        return 'localhost';
      }
      return currentHost;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => '10.0.2.2',
      _ => 'localhost',
    };
  }

  bool _isLoopbackHost(String host) {
    final normalizedHost = host.trim().toLowerCase();
    return normalizedHost == 'localhost' ||
        normalizedHost == '127.0.0.1' ||
        normalizedHost == '::1';
  }

  ProductCardData _toProductCardData(_InventoryDto inventory) {
    final visual = _categoryVisual(inventory.product.categoryType);
    return ProductCardData(
      name: inventory.product.productName,
      location: visual.label,
      quantity:
          '${_formatQuantity(inventory.quantity)} ${_unitLabel(inventory.unitType)}',
      remainingLabel: _homeRemainingLabel(inventory.expirationDate),
      categories: <String>[
        visual.label,
        if ((_daysUntil(inventory.expirationDate) ?? 99) <= 2) 'Oncelikli',
      ],
      icon: visual.icon,
      backgroundColors: visual.colors,
    );
  }

  InventoryItemData _toInventoryItemData(_InventoryDto inventory) {
    final visual = _categoryVisual(inventory.product.categoryType);
    final isCritical = (_daysUntil(inventory.expirationDate) ?? 99) <= 2;
    return InventoryItemData(
      inventoryId: inventory.id,
      name: inventory.product.productName,
      statusLabel: _inventoryStatusLabel(inventory.expirationDate),
      quantity: inventory.quantity,
      unit: _unitLabel(inventory.unitType),
      unitTypeCode: inventory.unitType,
      expirationDate: inventory.expirationDate,
      category: visual.label,
      icon: visual.icon,
      backgroundColors: visual.colors,
      isCritical: isCritical,
    );
  }

  RecipeCardData _toRecipeCardData(
    _RecipeSummaryDto recipe, {
    required bool isRecommended,
  }) {
    final visual = _recipeVisual(recipe);
    final tag = _recipeTag(recipe, isRecommended: isRecommended);
    return RecipeCardData(
      title: recipe.recipeName,
      duration: _formatDuration(recipe.prepTimeMinutes),
      tag: tag,
      gradientColors: visual.colors,
      icon: visual.icon,
      routeArguments: _buildRecipeRouteArgumentsFromSummary(recipe, tag: tag),
      searchKeywords: <String>[recipe.recipeName, recipe.description, tag],
    );
  }

  FeaturedRecipeData _toFeaturedRecipeData(
    _RecipeSummaryDto recipe, {
    required bool isRecommended,
  }) {
    final visual = _recipeVisual(recipe);
    final tag = _recipeTag(recipe, isRecommended: isRecommended);
    return FeaturedRecipeData(
      badge: tag,
      title: recipe.recipeName,
      duration: _formatDuration(recipe.prepTimeMinutes),
      sustainabilityLabel: recipe.calorie > 0
          ? '${recipe.calorie} kcal'
          : 'Detaylar Hazirlaniyor',
      gradientColors: visual.colors,
      routeArguments: _buildRecipeRouteArgumentsFromSummary(recipe, tag: tag),
    );
  }

  Map<String, dynamic> _buildRecipeRouteArgumentsFromSummary(
    _RecipeSummaryDto recipe, {
    required String tag,
  }) {
    final visual = _recipeVisual(recipe);
    return <String, dynamic>{
      'id': recipe.id,
      'title': recipe.recipeName,
      'tag': tag,
      'duration': _formatDuration(recipe.prepTimeMinutes),
      'icon': visual.icon,
      'gradientColors': visual.colors,
      'servings': _estimatedServings(0),
      'calories': recipe.calorie > 0 ? '${recipe.calorie} kcal' : 'Bilinmiyor',
      'chefNote': recipe.description.isEmpty
          ? 'Tarifin ayrintili aciklamasi hazirlaniyor.'
          : recipe.description,
      'ingredients': const <String>[],
      'missingIngredients': const <String>[],
      'steps': const <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _buildRecipeRouteArgumentsFromDetail(
    _RecipeDetailDto detail, {
    Map<String, dynamic>? fallbackArguments,
  }) {
    final fallback = fallbackArguments ?? const <String, dynamic>{};
    final summary = _RecipeSummaryDto(
      id: detail.id,
      recipeName: detail.recipeName,
      description: detail.description,
      prepTimeMinutes: detail.prepTimeMinutes,
      calorie: detail.calorie,
      recipeImageUrl: detail.recipeImageUrl,
    );
    final visual = _recipeVisual(summary);

    return <String, dynamic>{
      'id': detail.id,
      'title': detail.recipeName,
      'tag':
          fallback['tag']?.toString() ??
          _recipeTag(summary, isRecommended: false),
      'duration': _formatDuration(detail.prepTimeMinutes),
      'icon': fallback['icon'] is IconData
          ? fallback['icon'] as IconData
          : visual.icon,
      'gradientColors':
          (fallback['gradientColors'] as List?)
                  ?.whereType<Color>()
                  .toList(growable: false)
                  .isNotEmpty ==
              true
          ? (fallback['gradientColors'] as List).whereType<Color>().toList()
          : visual.colors,
      'servings': _estimatedServings(detail.ingredients.length),
      'calories': detail.calorie > 0 ? '${detail.calorie} kcal' : 'Bilinmiyor',
      'chefNote': detail.description.isEmpty
          ? 'Tarif aciklamasi bulunamadi.'
          : detail.description,
      'ingredients': detail.ingredients
          .map(
            (ingredient) =>
                '${_formatQuantity(ingredient.quantity)} ${_unitLabel(ingredient.unitType)} ${ingredient.product.productName}',
          )
          .toList(growable: false),
      'missingIngredients': const <String>[],
      'steps': _buildGenericSteps(detail),
    };
  }

  List<Map<String, dynamic>> _buildGenericSteps(_RecipeDetailDto detail) {
    final ingredientNames = detail.ingredients
        .map((ingredient) => ingredient.product.productName)
        .where((name) => name.trim().isNotEmpty)
        .toList(growable: false);

    return <Map<String, dynamic>>[
      <String, dynamic>{
        'title': 'Malzemeleri Hazirla',
        'description': ingredientNames.isEmpty
            ? 'Tarif icin gerekli malzemeleri olcup hazirlayin.'
            : '${ingredientNames.join(', ')} malzemelerini tezgaha alin ve olculeri hazirlayin.',
        'showPlaceholder': false,
      },
      <String, dynamic>{
        'title': 'Pisirme Adimi',
        'description':
            '${detail.recipeName} tarifini aciklamadaki siraya gore hazirlayabilirsin. Ayrintili adimlar eklendikce bu alan daha da zenginlesecek.',
        'showPlaceholder': true,
      },
      <String, dynamic>{
        'title': 'Servis Et',
        'description':
            'Pisirme bittiginde sicak servis edin ve kalan malzemeleri envanterde guncelleyin.',
        'showPlaceholder': false,
      },
    ];
  }

  List<_RecipeSummaryDto> _mergeRecipes(
    List<_RecipeSummaryDto> recommended,
    List<_RecipeSummaryDto> allRecipes,
  ) {
    final unique = <int, _RecipeSummaryDto>{};
    for (final recipe in recommended) {
      unique[recipe.id] = recipe;
    }
    for (final recipe in allRecipes) {
      unique.putIfAbsent(recipe.id, () => recipe);
    }
    return unique.values.toList(growable: false);
  }

  String _recipeTag(_RecipeSummaryDto recipe, {required bool isRecommended}) {
    if (isRecommended) {
      return 'ONERILEN';
    }
    if (recipe.prepTimeMinutes > 0 && recipe.prepTimeMinutes <= 20) {
      return 'HIZLI';
    }
    if (recipe.calorie > 0 && recipe.calorie <= 350) {
      return 'FIT';
    }
    return 'TARIF';
  }

  _RecipeVisual _recipeVisual(_RecipeSummaryDto recipe) {
    final normalized = _normalizeText(
      '${recipe.recipeName} ${recipe.description}',
    );

    if (_containsAny(normalized, <String>['corba', 'soup'])) {
      return const _RecipeVisual(
        icon: Icons.soup_kitchen_rounded,
        colors: <Color>[Color(0xFFB0CFA2), Color(0xFF5F7E55)],
      );
    }
    if (_containsAny(normalized, <String>['makarna', 'pasta'])) {
      return const _RecipeVisual(
        icon: Icons.ramen_dining_rounded,
        colors: <Color>[Color(0xFFF2C063), Color(0xFFB47431)],
      );
    }
    if (_containsAny(normalized, <String>['salata', 'yesil', 'vegan'])) {
      return const _RecipeVisual(
        icon: Icons.eco_rounded,
        colors: <Color>[Color(0xFF89B86B), Color(0xFF46683F)],
      );
    }
    if (_containsAny(normalized, <String>['tatli', 'dessert', 'sutlac'])) {
      return const _RecipeVisual(
        icon: Icons.icecream_rounded,
        colors: <Color>[Color(0xFFF0DDC0), Color(0xFFB28A55)],
      );
    }
    if (_containsAny(normalized, <String>['et', 'tavuk'])) {
      return const _RecipeVisual(
        icon: Icons.lunch_dining_rounded,
        colors: <Color>[Color(0xFFE88B7A), Color(0xFFB24A41)],
      );
    }

    return const _RecipeVisual(
      icon: Icons.restaurant_menu_rounded,
      colors: <Color>[Color(0xFF92A87B), Color(0xFF4C673C)],
    );
  }

  _CategoryVisual _categoryVisual(String categoryCode) {
    switch (categoryCode.toUpperCase()) {
      case 'FRUIT':
        return const _CategoryVisual(
          label: 'Meyve',
          icon: Icons.local_florist_rounded,
          colors: <Color>[Color(0xFFE7B38A), Color(0xFFB45C3A)],
        );
      case 'VEGETABLE':
        return const _CategoryVisual(
          label: 'Sebze',
          icon: Icons.spa_rounded,
          colors: <Color>[Color(0xFF89B86B), Color(0xFF46683F)],
        );
      case 'MEAT':
        return const _CategoryVisual(
          label: 'Et',
          icon: Icons.set_meal_rounded,
          colors: <Color>[Color(0xFFE88B7A), Color(0xFFB24A41)],
        );
      case 'DAIRY':
        return const _CategoryVisual(
          label: 'Sut Urunleri',
          icon: Icons.breakfast_dining_rounded,
          colors: <Color>[Color(0xFFB4D9E8), Color(0xFF5C8798)],
        );
      case 'GRAIN':
        return const _CategoryVisual(
          label: 'Tahil / Kuru Gida',
          icon: Icons.rice_bowl_rounded,
          colors: <Color>[Color(0xFFE7DFC7), Color(0xFFB79D63)],
        );
      case 'BEVERAGE':
        return const _CategoryVisual(
          label: 'Icecekler',
          icon: Icons.local_drink_rounded,
          colors: <Color>[Color(0xFF9DD3E8), Color(0xFF467A9A)],
        );
      case 'SNACK':
        return const _CategoryVisual(
          label: 'Atistirmalik',
          icon: Icons.cookie_rounded,
          colors: <Color>[Color(0xFFF2C063), Color(0xFFB47431)],
        );
      default:
        return const _CategoryVisual(
          label: 'Meyve',
          icon: Icons.inventory_2_rounded,
          colors: <Color>[Color(0xFF92A87B), Color(0xFF4C673C)],
        );
    }
  }

  String _categoryLabel(String categoryCode) =>
      _categoryVisual(categoryCode).label;

  String _categoryCode(String label) {
    switch (normalizeCategoryLabel(label)) {
      case 'Meyve':
        return 'FRUIT';
      case 'Sebze':
        return 'VEGETABLE';
      case 'Et':
        return 'MEAT';
      case 'Sut Urunleri':
        return 'DAIRY';
      case 'Tahil / Kuru Gida':
        return 'GRAIN';
      case 'Icecekler':
        return 'BEVERAGE';
      case 'Atistirmalik':
        return 'SNACK';
      default:
        return 'FRUIT';
    }
  }

  String _unitCode(String label) {
    switch (normalizeUnitLabel(label)) {
      case 'Kg':
        return 'KG';
      case 'Litre':
        return 'LITER';
      default:
        return 'PIECE';
    }
  }

  String _unitLabel(String unitCode) {
    switch (unitCode.toUpperCase()) {
      case 'KG':
        return 'Kg';
      case 'LITER':
        return 'Litre';
      default:
        return 'Adet';
    }
  }

  String _formatDuration(int prepTimeMinutes) {
    if (prepTimeMinutes <= 0) {
      return 'Sure bilinmiyor';
    }
    return '$prepTimeMinutes dk';
  }

  String _estimatedServings(int ingredientCount) {
    if (ingredientCount <= 2) {
      return '1 kisilik';
    }
    if (ingredientCount <= 4) {
      return '2 kisilik';
    }
    if (ingredientCount <= 6) {
      return '3 kisilik';
    }
    return '4+ kisilik';
  }

  String _inventoryStatusLabel(DateTime? expirationDate) {
    final remainingDays = _daysUntil(expirationDate);
    if (remainingDays == null) {
      return 'Tarih bilgisi yok';
    }
    if (remainingDays <= 0) {
      return 'Bugun kullan';
    }
    if (remainingDays == 1) {
      return '1 gun icinde kullan';
    }
    return '$remainingDays gun icinde kullan';
  }

  String _homeRemainingLabel(DateTime? expirationDate) {
    final remainingDays = _daysUntil(expirationDate);
    if (remainingDays == null) {
      return 'TARIH YOK';
    }
    if (remainingDays <= 0) {
      return 'BUGUN';
    }
    if (remainingDays == 1) {
      return '1 GUN';
    }
    return '$remainingDays GUN';
  }

  int? _daysUntil(DateTime? expirationDate) {
    if (expirationDate == null) {
      return null;
    }

    final today = DateTime.now();
    final current = DateTime(today.year, today.month, today.day);
    final target = DateTime(
      expirationDate.year,
      expirationDate.month,
      expirationDate.day,
    );
    return target.difference(current).inDays;
  }

  String _formatQuantity(num quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(1);
  }

  String _formatBackendDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final raw = value.trim();
      if (raw.isEmpty) {
        return null;
      }

      final dashMatch = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(raw);
      if (dashMatch != null) {
        return DateTime(
          int.parse(dashMatch.group(3)!),
          int.parse(dashMatch.group(2)!),
          int.parse(dashMatch.group(1)!),
        );
      }

      final isoMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
      if (isoMatch != null) {
        return DateTime(
          int.parse(isoMatch.group(1)!),
          int.parse(isoMatch.group(2)!),
          int.parse(isoMatch.group(3)!),
        );
      }

      return DateTime.tryParse(raw);
    }

    if (value is List && value.length >= 3) {
      final parts = value
          .map((part) => int.tryParse(part.toString()) ?? 0)
          .toList();
      return DateTime(parts[0], parts[1], parts[2]);
    }

    return null;
  }

  num _asNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const <dynamic>[];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  String _normalizeText(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll('i', 'i')
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

  bool _containsAny(String value, List<String> needles) {
    for (final needle in needles) {
      if (value.contains(needle)) {
        return true;
      }
    }
    return false;
  }
}

class _CategoryVisual {
  const _CategoryVisual({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
}

class _RecipeVisual {
  const _RecipeVisual({required this.icon, required this.colors});

  final IconData icon;
  final List<Color> colors;
}

class _ProductDto {
  const _ProductDto({
    required this.id,
    required this.productName,
    required this.barcode,
    required this.categoryType,
    this.productImageUrl,
  });

  factory _ProductDto.fromJson(Map<String, dynamic> json) {
    return _ProductDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      productName: json['productName']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      categoryType: json['categoryType']?.toString() ?? 'FRUIT',
      productImageUrl: json['productImageUrl']?.toString(),
    );
  }

  final int id;
  final String productName;
  final String barcode;
  final String categoryType;
  final String? productImageUrl;
}

class _InventoryDto {
  const _InventoryDto({
    required this.id,
    required this.quantity,
    required this.unitType,
    required this.expirationDate,
    required this.product,
  });

  factory _InventoryDto.fromJson(Map<String, dynamic> json) {
    final service = BackendApiService.instance;
    return _InventoryDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      quantity: service._asNum(json['quantity']),
      unitType: json['unitType']?.toString() ?? 'PIECE',
      expirationDate: service._parseDate(json['expirationDate']),
      product: _ProductDto.fromJson(service._asMap(json['product'])),
    );
  }

  final int id;
  final num quantity;
  final String unitType;
  final DateTime? expirationDate;
  final _ProductDto product;
}

class _RecipeSummaryDto {
  const _RecipeSummaryDto({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.prepTimeMinutes,
    required this.calorie,
    this.recipeImageUrl,
  });

  factory _RecipeSummaryDto.fromJson(Map<String, dynamic> json) {
    final service = BackendApiService.instance;
    return _RecipeSummaryDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      recipeName: json['recipeName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      prepTimeMinutes: service._asInt(json['prepTimeMinutes']),
      calorie: service._asInt(json['calorie']),
      recipeImageUrl: json['recipeImageUrl']?.toString(),
    );
  }

  final int id;
  final String recipeName;
  final String description;
  final int prepTimeMinutes;
  final int calorie;
  final String? recipeImageUrl;
}

class _RecipeIngredientDto {
  const _RecipeIngredientDto({
    required this.quantity,
    required this.unitType,
    required this.required,
    required this.product,
  });

  factory _RecipeIngredientDto.fromJson(Map<String, dynamic> json) {
    final service = BackendApiService.instance;
    return _RecipeIngredientDto(
      quantity: service._asNum(json['quantity']),
      unitType: json['unitType']?.toString() ?? 'PIECE',
      required: json['required'] as bool? ?? false,
      product: _ProductDto.fromJson(service._asMap(json['product'])),
    );
  }

  final num quantity;
  final String unitType;
  final bool required;
  final _ProductDto product;
}

class _RecipeDetailDto {
  const _RecipeDetailDto({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.prepTimeMinutes,
    required this.calorie,
    required this.ingredients,
    this.recipeImageUrl,
  });

  factory _RecipeDetailDto.fromJson(Map<String, dynamic> json) {
    final service = BackendApiService.instance;
    return _RecipeDetailDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      recipeName: json['recipeName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      prepTimeMinutes: service._asInt(json['prepTimeMinutes']),
      calorie: service._asInt(json['calorie']),
      recipeImageUrl: json['recipeImageUrl']?.toString(),
      ingredients: service
          ._asList(json['ingredients'])
          .map((item) => _RecipeIngredientDto.fromJson(service._asMap(item)))
          .toList(growable: false),
    );
  }

  final int id;
  final String recipeName;
  final String description;
  final int prepTimeMinutes;
  final int calorie;
  final String? recipeImageUrl;
  final List<_RecipeIngredientDto> ingredients;
}

class _DashboardDto {
  const _DashboardDto({
    required this.username,
    required this.totalInventoryCount,
    required this.expiringSoonCount,
    required this.unreadNotificationCount,
    required this.expiringProducts,
    required this.recommendedRecipes,
  });

  factory _DashboardDto.fromJson(Map<String, dynamic> json) {
    final service = BackendApiService.instance;
    return _DashboardDto(
      username: json['username']?.toString() ?? '',
      totalInventoryCount: service._asInt(json['totalInventoryCount']),
      expiringSoonCount: service._asInt(json['expiringSoonCount']),
      unreadNotificationCount: service._asInt(json['unreadNotificationCount']),
      expiringProducts: service
          ._asList(json['expiringProducts'])
          .map((item) => _InventoryDto.fromJson(service._asMap(item)))
          .toList(growable: false),
      recommendedRecipes: service
          ._asList(json['recommendedRecipes'])
          .map((item) => _RecipeSummaryDto.fromJson(service._asMap(item)))
          .toList(growable: false),
    );
  }

  final String username;
  final int totalInventoryCount;
  final int expiringSoonCount;
  final int unreadNotificationCount;
  final List<_InventoryDto> expiringProducts;
  final List<_RecipeSummaryDto> recommendedRecipes;
}

class _NotificationDto {
  const _NotificationDto({
    required this.id,
    required this.message,
    required this.sendingDate,
    required this.isRead,
    required this.inventoryId,
    required this.productName,
  });

  factory _NotificationDto.fromJson(Map<String, dynamic> json) {
    final service = BackendApiService.instance;
    return _NotificationDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      sendingDate: service._parseDate(json['sendingDate']),
      isRead: json['isRead'] as bool? ?? false,
      inventoryId: json['inventoryId'] == null
          ? null
          : int.tryParse(json['inventoryId'].toString()),
      productName: json['productName']?.toString() ?? '',
    );
  }

  final int id;
  final String message;
  final DateTime? sendingDate;
  final bool isRead;
  final int? inventoryId;
  final String productName;
}
