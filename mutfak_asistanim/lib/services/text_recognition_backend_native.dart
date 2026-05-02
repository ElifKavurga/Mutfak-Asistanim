import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'text_recognition_backend.dart';

TextRecognitionBackend createTextRecognitionBackend() {
  return const _NativeTextRecognitionBackend();
}

class _NativeTextRecognitionBackend implements TextRecognitionBackend {
  const _NativeTextRecognitionBackend();

  @override
  String? get availabilityNote {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return 'OCR yalnizca Android ve iOS tarafinda calisir.';
    }

    return null;
  }

  @override
  Future<String> recognizeText(String imagePath) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return '';
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      await recognizer.close();
    }
  }
}
