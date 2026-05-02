import 'text_recognition_backend.dart';
import 'text_recognition_backend_stub.dart'
    if (dart.library.io) 'text_recognition_backend_native.dart'
    as ocr_backend;

class ProductTextOcrResult {
  const ProductTextOcrResult({
    required this.recognizedText,
    required this.dateText,
    required this.dateType,
    required this.insights,
    this.availabilityNote,
  });

  final String recognizedText;
  final String dateText;
  final String dateType;
  final List<String> insights;
  final String? availabilityNote;
}

class ProductTextOcrService {
  ProductTextOcrService._();

  static final ProductTextOcrService instance = ProductTextOcrService._();

  final TextRecognitionBackend _backend = ocr_backend
      .createTextRecognitionBackend();

  Future<ProductTextOcrResult> readProductText({
    required String imagePath,
  }) async {
    if (imagePath.trim().isEmpty) {
      return ProductTextOcrResult(
        recognizedText: '',
        dateText: '',
        dateType: '',
        insights: const <String>['OCR icin dosya yolu alinmadi.'],
        availabilityNote: 'Bos dosya yolu nedeniyle OCR calismadi.',
      );
    }

    try {
      final recognizedText = await _backend.recognizeText(imagePath);
      final normalizedText = _normalize(recognizedText);
      final dateType = _detectDateType(normalizedText);
      final dateText = _extractDate(recognizedText);
      final insights = <String>[
        if (recognizedText.trim().isNotEmpty)
          'OCR metni algilandi: ${_firstUsefulLine(recognizedText)}'
        else
          'OCR metin bulamadi.',
        if (dateText.isNotEmpty)
          '${dateType.isEmpty ? 'Tarih' : dateType} bulundu: $dateText'
        else
          'SKT/TETT benzeri tarih OCR ile bulunamadi.',
      ];

      if (_backend.availabilityNote != null &&
          _backend.availabilityNote!.isNotEmpty) {
        insights.add(_backend.availabilityNote!);
      }

      return ProductTextOcrResult(
        recognizedText: recognizedText,
        dateText: dateText,
        dateType: dateType,
        insights: insights,
        availabilityNote: _backend.availabilityNote,
      );
    } catch (error) {
      return ProductTextOcrResult(
        recognizedText: '',
        dateText: '',
        dateType: '',
        insights: <String>['OCR calisamadi: $error'],
        availabilityNote: 'OCR hatasi: $error',
      );
    }
  }

  String _detectDateType(String normalizedText) {
    if (normalizedText.contains('son kullanma') ||
        normalizedText.contains('skt') ||
        normalizedText.contains('use by') ||
        normalizedText.contains('expires')) {
      return 'Son Kullanma Tarihi';
    }
    if (normalizedText.contains('tett') ||
        normalizedText.contains('tavsiye edilen tuketim') ||
        normalizedText.contains('best before')) {
      return 'TETT';
    }
    return '';
  }

  String _extractDate(String recognizedText) {
    final sameLinePatterns = <RegExp>[
      RegExp(
        r'(?:tett|skt|son\s*kullanma|best\s*before|use\s*by)[^\d]{0,12}(\d{2}[./-]\d{2}[./-]\d{2,4})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:tett|skt|son\s*kullanma|best\s*before|use\s*by)[^\d]{0,12}(\d{2}[./-]\d{4})',
        caseSensitive: false,
      ),
    ];

    for (final pattern in sameLinePatterns) {
      final match = pattern.firstMatch(recognizedText);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }

    final genericPatterns = <RegExp>[
      RegExp(r'(\d{2}[./-]\d{2}[./-]\d{4})'),
      RegExp(r'(\d{2}[./-]\d{2}[./-]\d{2})'),
      RegExp(r'(\d{4}[./-]\d{2}[./-]\d{2})'),
      RegExp(r'(\d{2}[./-]\d{4})'),
      RegExp(r'(\d{2}[./-]\d{2})'),
    ];

    for (final pattern in genericPatterns) {
      final match = pattern.firstMatch(recognizedText);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }

    return '';
  }

  String _firstUsefulLine(String recognizedText) {
    final lines = recognizedText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty) {
      return 'metin yok';
    }

    return lines.first.length > 80
        ? '${lines.first.substring(0, 80)}...'
        : lines.first;
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
