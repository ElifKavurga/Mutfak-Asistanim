import 'dart:typed_data';

class TflitePrediction {
  const TflitePrediction({required this.label, required this.score});

  final String label;
  final double score;
}

abstract class TfliteRuntimeBackend {
  Future<List<TflitePrediction>> classify(Uint8List imageBytes);

  String? get availabilityNote;
}
