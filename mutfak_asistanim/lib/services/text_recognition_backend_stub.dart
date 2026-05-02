import 'text_recognition_backend.dart';

TextRecognitionBackend createTextRecognitionBackend() {
  return const _StubTextRecognitionBackend();
}

class _StubTextRecognitionBackend implements TextRecognitionBackend {
  const _StubTextRecognitionBackend();

  @override
  String get availabilityNote => 'OCR bu platformda etkin degil.';

  @override
  Future<String> recognizeText(String imagePath) async {
    return '';
  }
}
