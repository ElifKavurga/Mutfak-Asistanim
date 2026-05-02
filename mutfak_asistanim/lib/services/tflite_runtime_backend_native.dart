import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'tflite_runtime_backend.dart';

TfliteRuntimeBackend createTfliteRuntimeBackend() {
  return _NativeTfliteRuntimeBackend();
}

class _NativeTfliteRuntimeBackend implements TfliteRuntimeBackend {
  static const String _modelAssetPath =
      'assets/models/mobilenet_v1_1.0_224_quant.tflite';
  static const String _labelsAssetPath =
      'assets/models/labels_mobilenet_quant_v1_224.txt';

  Interpreter? _interpreter;
  List<String>? _labels;
  String? _availabilityNote;
  bool _hasLoadAttempt = false;

  @override
  String? get availabilityNote => _availabilityNote;

  @override
  Future<List<TflitePrediction>> classify(Uint8List imageBytes) async {
    await _ensureLoaded();
    if (_interpreter == null || _labels == null) {
      return const <TflitePrediction>[];
    }

    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      _availabilityNote = 'Gorsel cozulemedi.';
      return const <TflitePrediction>[];
    }

    final interpreter = _interpreter!;
    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final inputShape = inputTensor.shape;
    final outputShape = outputTensor.shape;
    final inputType = inputTensor.type;
    final outputType = outputTensor.type;

    if (inputShape.length < 4 || outputShape.length < 2) {
      _availabilityNote = 'Beklenmeyen model tensor boyutu.';
      return const <TflitePrediction>[];
    }

    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];
    final resizedImage = img.copyResize(
      decodedImage,
      width: inputWidth,
      height: inputHeight,
    );

    final input = _buildInputTensor(
      image: resizedImage,
      inputType: inputType,
      inputHeight: inputHeight,
      inputWidth: inputWidth,
    );
    final outputLength = outputShape.fold<int>(
      1,
      (value, item) => value * item,
    );
    final output = _buildOutputBuffer(
      outputType: outputType,
      outputLength: outputLength,
    );

    interpreter.run(input, output);

    final rawScores = _extractScores(output: output);
    if (rawScores.isEmpty) {
      return const <TflitePrediction>[];
    }

    final labels = _labels!;
    final scoreCount = rawScores.length < labels.length
        ? rawScores.length
        : labels.length;
    final indices = List<int>.generate(scoreCount, (index) => index)
      ..sort((left, right) => rawScores[right].compareTo(rawScores[left]));

    return indices
        .take(5)
        .map(
          (index) =>
              TflitePrediction(label: labels[index], score: rawScores[index]),
        )
        .toList(growable: false);
  }

  Future<void> _ensureLoaded() async {
    if (_hasLoadAttempt) {
      return;
    }

    _hasLoadAttempt = true;
    try {
      _labels = await rootBundle
          .loadString(_labelsAssetPath)
          .then(
            (content) => content
                .split('\n')
                .map((label) => label.trim())
                .where((label) => label.isNotEmpty)
                .toList(growable: false),
          );

      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        _modelAssetPath,
        options: options,
      );
    } catch (error) {
      _availabilityNote = 'TFLite modeli yuklenemedi: $error';
      _interpreter = null;
      _labels = null;
    }
  }

  Object _buildInputTensor({
    required img.Image image,
    required TensorType inputType,
    required int inputHeight,
    required int inputWidth,
  }) {
    if (inputType == TensorType.float32) {
      return List<List<List<List<double>>>>.generate(
        1,
        (_) => List<List<List<double>>>.generate(
          inputHeight,
          (y) => List<List<double>>.generate(inputWidth, (x) {
            final pixel = image.getPixel(x, y);
            return <double>[pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          }, growable: false),
          growable: false,
        ),
        growable: false,
      );
    }

    return List<List<List<List<int>>>>.generate(
      1,
      (_) => List<List<List<int>>>.generate(
        inputHeight,
        (y) => List<List<int>>.generate(inputWidth, (x) {
          final pixel = image.getPixel(x, y);
          return <int>[pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
        }, growable: false),
        growable: false,
      ),
      growable: false,
    );
  }

  Object _buildOutputBuffer({
    required TensorType outputType,
    required int outputLength,
  }) {
    if (outputType == TensorType.float32) {
      return List<List<double>>.generate(
        1,
        (_) => List<double>.filled(outputLength, 0),
        growable: false,
      );
    }

    return List<List<int>>.generate(
      1,
      (_) => List<int>.filled(outputLength, 0),
      growable: false,
    );
  }

  List<double> _extractScores({required Object output}) {
    if (output is List<List<double>> && output.isNotEmpty) {
      return output.first
          .map((value) => value.clamp(0.0, 1.0))
          .toList(growable: false);
    }

    if (output is List<List<int>> && output.isNotEmpty) {
      return output.first
          .map((value) => (value / 255.0).clamp(0.0, 1.0))
          .toList(growable: false);
    }

    return const <double>[];
  }
}
