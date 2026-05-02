abstract class TextRecognitionBackend {
  Future<String> recognizeText(String imagePath);

  String? get availabilityNote;
}
