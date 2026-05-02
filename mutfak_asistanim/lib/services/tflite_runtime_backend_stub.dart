import 'dart:typed_data';

import 'tflite_runtime_backend.dart';

TfliteRuntimeBackend createTfliteRuntimeBackend() {
  return const _StubTfliteRuntimeBackend();
}

class _StubTfliteRuntimeBackend implements TfliteRuntimeBackend {
  const _StubTfliteRuntimeBackend();

  @override
  String get availabilityNote => 'TFLite bu platformda etkin degil.';

  @override
  Future<List<TflitePrediction>> classify(Uint8List imageBytes) async {
    return const <TflitePrediction>[];
  }
}
