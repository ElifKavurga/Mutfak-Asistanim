import 'dart:typed_data';

import 'tflite_runtime_backend.dart';
import 'tflite_runtime_backend_stub.dart'
    if (dart.library.io) 'tflite_runtime_backend_native.dart'
    as runtime_backend;

class TensorFlowProductScanResult {
  const TensorFlowProductScanResult({
    required this.productName,
    required this.category,
    required this.dateText,
    required this.dateType,
    required this.quickSuggestions,
    required this.summaryTitle,
    required this.summaryDescription,
    required this.confidence,
    required this.insights,
    required this.relatedRecipes,
  });

  final String productName;
  final String category;
  final String dateText;
  final String dateType;
  final List<String> quickSuggestions;
  final String summaryTitle;
  final String summaryDescription;
  final double confidence;
  final List<String> insights;
  final List<String> relatedRecipes;

  String get confidenceLabel => 'Guven ${(confidence * 100).round()}%';
}

class TensorFlowKitchenService {
  TensorFlowKitchenService._();

  static final TensorFlowKitchenService instance = TensorFlowKitchenService._();

  static const List<_ProductProfile> _profiles = <_ProductProfile>[
    _ProductProfile(
      name: 'Yogurt',
      category: 'Sut Urunleri',
      keywords: <String>['yogurt', 'ayran'],
      labelKeywords: <String>['milk can', 'eggnog', 'ice cream'],
      quickSuggestions: <String>['Yogurt', 'Suzme Yogurt', 'Laktozsuz Yogurt'],
      relatedRecipes: <String>[
        'Yogurtlu Ispanak Kasesi',
        'Kahvaltilik Dip Sos',
      ],
      defaultDateType: 'TETT',
    ),
    _ProductProfile(
      name: 'Ispanak',
      category: 'Meyve & Sebze',
      keywords: <String>['ispanak', 'spinach', 'yesillik'],
      labelKeywords: <String>['broccoli', 'head cabbage', 'cardoon'],
      quickSuggestions: <String>[
        'Ispanak',
        'Baby Ispanak',
        'Temizlenmis Ispanak',
      ],
      relatedRecipes: <String>['Yogurtlu Ispanak Kasesi', 'Peynirli Gozleme'],
      defaultDateType: 'Son Kullanma Tarihi',
    ),
    _ProductProfile(
      name: 'Mantar',
      category: 'Meyve & Sebze',
      keywords: <String>['mantar', 'mushroom'],
      labelKeywords: <String>['mushroom'],
      quickSuggestions: <String>['Mantar', 'Kultur Mantari', 'Dilimli Mantar'],
      relatedRecipes: <String>['Kremali Mantar Sote', 'Sebzeli Tortilla'],
      defaultDateType: 'Son Kullanma Tarihi',
    ),
    _ProductProfile(
      name: 'Sut',
      category: 'Sut Urunleri',
      keywords: <String>['sut', 'milk'],
      labelKeywords: <String>['milk can'],
      quickSuggestions: <String>['Sut', 'Laktozsuz Sut', 'Yarim Yagli Sut'],
      relatedRecipes: <String>['Firinda Sutlac', 'Pankek Hazirligi'],
      defaultDateType: 'TETT',
    ),
    _ProductProfile(
      name: 'Yumurta',
      category: 'Kahvaltilik',
      keywords: <String>['yumurta', 'egg'],
      labelKeywords: <String>['eggnog', 'hen'],
      quickSuggestions: <String>[
        'Yumurta',
        'Organik Yumurta',
        'Gezen Tavuk Yumurtasi',
      ],
      relatedRecipes: <String>['Menemen', 'Sebzeli Omlet'],
      defaultDateType: 'Son Kullanma Tarihi',
    ),
    _ProductProfile(
      name: 'Domates',
      category: 'Meyve & Sebze',
      keywords: <String>['domates', 'tomato'],
      labelKeywords: <String>['bell pepper', 'pomegranate'],
      quickSuggestions: <String>['Domates', 'Ceri Domates', 'Beef Domates'],
      relatedRecipes: <String>['Menemen', 'Domatesli Makarna'],
      defaultDateType: 'Son Kullanma Tarihi',
    ),
    _ProductProfile(
      name: 'Limon',
      category: 'Meyve & Sebze',
      keywords: <String>['limon', 'lemon'],
      labelKeywords: <String>['lemon'],
      quickSuggestions: <String>['Limon', 'Yesil Limon', 'Dilimli Limon'],
      relatedRecipes: <String>['Limonlu Sos', 'Sebzeli Kase'],
      defaultDateType: 'Son Kullanma Tarihi',
    ),
    _ProductProfile(
      name: 'Tortilla',
      category: 'Kuru Gida',
      keywords: <String>['tortilla', 'lavas', 'wrap'],
      labelKeywords: <String>['plate', 'hotdog'],
      quickSuggestions: <String>['Tortilla', 'Tam Bugday Tortilla', 'Lavas'],
      relatedRecipes: <String>['Sebzeli Tortilla', 'Tavuklu Wrap'],
      defaultDateType: 'TETT',
    ),
  ];

  final TfliteRuntimeBackend _backend = runtime_backend
      .createTfliteRuntimeBackend();

  Future<TensorFlowProductScanResult> analyzeProductImage({
    required Uint8List imageBytes,
    required String imageName,
    String recognizedText = '',
    String ocrDetectedDate = '',
    String ocrDetectedDateType = '',
    List<String> ocrInsights = const <String>[],
    String? ocrAvailabilityNote,
  }) async {
    final predictions = await _backend.classify(imageBytes);
    final normalizedName = _normalize(imageName);
    final normalizedOcrText = _normalize(recognizedText);
    final profile = _resolveProfile(
      normalizedName: normalizedName,
      normalizedOcrText: normalizedOcrText,
      predictions: predictions,
      imageByteLength: imageBytes.length,
    );
    final detectedDate = ocrDetectedDate.isNotEmpty
        ? ocrDetectedDate
        : _extractDate(imageName);
    final detectedDateType = ocrDetectedDateType.isNotEmpty
        ? ocrDetectedDateType
        : normalizedName.contains('tett')
        ? 'TETT'
        : normalizedName.contains('skt')
        ? 'Son Kullanma Tarihi'
        : profile.defaultDateType;
    final topPrediction = predictions.isEmpty ? null : predictions.first;
    final confidence = _estimateConfidence(
      normalizedName: normalizedName,
      profile: profile,
      topPrediction: topPrediction,
      hasDate: detectedDate.isNotEmpty,
    );
    final modelSummary = topPrediction == null
        ? (_backend.availabilityNote ?? 'Gercek TFLite tahmini alinamadi.')
        : 'Gercek TFLite etiketi: ${topPrediction.label} (${_scoreLabel(topPrediction.score)}).';
    final ocrSummary = detectedDate.isNotEmpty
        ? 'OCR tarihi: $detectedDateType $detectedDate.'
        : recognizedText.trim().isNotEmpty
        ? 'OCR metni urun ustundeki yazilari okudu ama tarih secemedi.'
        : (ocrAvailabilityNote ?? 'OCR tarih bulamadi.');
    final dateSummary = detectedDate.isEmpty
        ? 'Tarih alani otomatik okunamadi, giriste kontrol et.'
        : '$detectedDateType icin $detectedDate onerildi.';

    return TensorFlowProductScanResult(
      productName: profile.name,
      category: profile.category,
      dateText: detectedDate,
      dateType: detectedDateType,
      quickSuggestions: profile.quickSuggestions,
      summaryTitle: topPrediction == null
          ? 'TFLite yedek modda devam etti'
          : 'Gercek TFLite analizi hazir',
      summaryDescription:
          '$modelSummary $ocrSummary Uygulama bunu ${profile.name} olarak yorumladi. $dateSummary',
      confidence: confidence,
      insights: _buildInsights(
        profile: profile,
        topPrediction: topPrediction,
        predictions: predictions,
        detectedDate: detectedDate,
        detectedDateType: detectedDateType,
        ocrInsights: ocrInsights,
      ),
      relatedRecipes: profile.relatedRecipes,
    );
  }

  List<String> _buildInsights({
    required _ProductProfile profile,
    required TflitePrediction? topPrediction,
    required List<TflitePrediction> predictions,
    required String detectedDate,
    required String detectedDateType,
    required List<String> ocrInsights,
  }) {
    final insights = <String>[];

    if (topPrediction != null) {
      insights.add(
        'Model etiketi: ${topPrediction.label} (${_scoreLabel(topPrediction.score)})',
      );
    } else {
      insights.add(
        'Gercek model bu platformda kullanilamadi, fallback uygulandi.',
      );
    }

    if (predictions.length > 1) {
      final alternatives = predictions
          .skip(1)
          .take(2)
          .map((item) => '${item.label} (${_scoreLabel(item.score)})')
          .join(', ');
      if (alternatives.isNotEmpty) {
        insights.add('Alternatif etiketler: $alternatives');
      }
    }

    insights.add('Urun adi adayi: ${profile.name}');

    insights.addAll(ocrInsights);

    if (detectedDate.isNotEmpty) {
      insights.add('$detectedDateType algilandi: $detectedDate');
    } else {
      insights.add('Tarih otomatik okunamadi, elle kontrol gerekebilir.');
    }

    insights.add(
      '${profile.relatedRecipes.first} gibi tariflerde hizli degerlendirilebilir.',
    );

    return insights;
  }

  _ProductProfile _resolveProfile({
    required String normalizedName,
    required String normalizedOcrText,
    required List<TflitePrediction> predictions,
    required int imageByteLength,
  }) {
    if (normalizedOcrText.isNotEmpty) {
      for (final profile in _profiles) {
        if (profile.keywords.any(
          (keyword) => normalizedOcrText.contains(_normalize(keyword)),
        )) {
          return profile;
        }
      }
    }

    for (final prediction in predictions) {
      final matchedByLabel = _profiles.where(
        (profile) => profile.labelKeywords.any(
          (keyword) =>
              _normalize(prediction.label).contains(_normalize(keyword)),
        ),
      );
      if (matchedByLabel.isNotEmpty) {
        return matchedByLabel.first;
      }
    }

    for (final profile in _profiles) {
      for (final keyword in profile.keywords) {
        if (normalizedName.contains(_normalize(keyword))) {
          return profile;
        }
      }
    }

    return _profiles[(imageByteLength + normalizedName.length) %
        _profiles.length];
  }

  double _estimateConfidence({
    required String normalizedName,
    required _ProductProfile profile,
    required TflitePrediction? topPrediction,
    required bool hasDate,
  }) {
    var confidence = topPrediction?.score ?? 0.56;

    if (profile.keywords.any(
      (keyword) => normalizedName.contains(_normalize(keyword)),
    )) {
      confidence += 0.12;
    }
    if (topPrediction != null &&
        profile.labelKeywords.any(
          (keyword) =>
              _normalize(topPrediction.label).contains(_normalize(keyword)),
        )) {
      confidence += 0.1;
    }
    if (hasDate) {
      confidence += 0.06;
    }

    return confidence.clamp(0.0, 0.96).toDouble();
  }

  String _scoreLabel(double score) {
    return '%${(score * 100).round()}';
  }

  String _extractDate(String imageName) {
    final dayFirst = RegExp(r'(\d{2})[.\-_/](\d{2})[.\-_/](\d{4})');
    final yearFirst = RegExp(r'(\d{4})[.\-_/](\d{2})[.\-_/](\d{2})');

    final dayMatch = dayFirst.firstMatch(imageName);
    if (dayMatch != null) {
      return '${dayMatch.group(1)}.${dayMatch.group(2)}.${dayMatch.group(3)}';
    }

    final yearMatch = yearFirst.firstMatch(imageName);
    if (yearMatch != null) {
      return '${yearMatch.group(3)}.${yearMatch.group(2)}.${yearMatch.group(1)}';
    }

    return '';
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('\u0131', 'i')
        .replaceAll('\u0130', 'i')
        .replaceAll('\u015f', 's')
        .replaceAll('\u015e', 's')
        .replaceAll('\u011f', 'g')
        .replaceAll('\u011e', 'g')
        .replaceAll('\u00fc', 'u')
        .replaceAll('\u00dc', 'u')
        .replaceAll('\u00f6', 'o')
        .replaceAll('\u00d6', 'o')
        .replaceAll('\u00e7', 'c')
        .replaceAll('\u00c7', 'c')
        .trim();
  }
}

class _ProductProfile {
  const _ProductProfile({
    required this.name,
    required this.category,
    required this.keywords,
    required this.labelKeywords,
    required this.quickSuggestions,
    required this.relatedRecipes,
    required this.defaultDateType,
  });

  final String name;
  final String category;
  final List<String> keywords;
  final List<String> labelKeywords;
  final List<String> quickSuggestions;
  final List<String> relatedRecipes;
  final String defaultDateType;
}
