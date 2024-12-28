import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

class ModelService {
  Interpreter? _interpreter;
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;
  bool _isModelLoaded = false;

  // Hardcoded labels list
  final List<String> _labels = [
    'Apple Golden 1', 'Apple Red 1', 'Apricot', 'Avocado', 'Banana',
    'Beetroot', 'Blueberry', 'Cactus fruit', 'Cantaloupe', 'Carambula',
    'Cauliflower', 'Cherry 1', 'Clementine', 'Cocos', 'Corn',
    'Cucumber Ripe', 'Eggplant', 'Fig', 'Ginger Root', 'Granadilla',
    'Grape Blue', 'Grape White 1', 'Grape White 2', 'Guava', 'Hazelnut',
    'Huckleberry', 'Kaki', 'Kiwi', 'Kohlrabi', 'Kumquat',
    'Lemon', 'Limes', 'Lychee', 'Mango', 'Mangostan',
    'Maracuja', 'Melon Piel de Sapo', 'Mulberry', 'Nectarine', 'Onion Red',
    'Onion White', 'Orange', 'Papaya', 'Passion Fruit', 'Peach',
    'Pear', 'Pepino', 'Physalis', 'Pineapple', 'Pitahaya Red',
    'Plum', 'Pomegranate', 'Pomelo Sweetie', 'Potato Red', 'Potato White',
    'Quince', 'Rambutan', 'Raspberry', 'Redcurrant', 'Salak',
    'Strawberry', 'Tamarillo', 'Tangelo', 'Tomato 1', 'Tomato Cherry Red',
    'Tomato Maroon', 'Tomato Yellow', 'Walnut', 'Watermelon', 'Zucchini'
  ];

  // Check if model is loaded
  bool get isModelLoaded => _isModelLoaded;

  // Load the model
  Future<void> loadModel() async {
    try {
      print('Loading model...');

      // Try loading with and without 'assets/' prefix
      try {
        _interpreter = await Interpreter.fromAsset('models/cnn_fruits_model.tflite');
      } catch (e) {
        print('Trying alternative path...');
        _interpreter = await Interpreter.fromAsset('models/cnn_fruits_model.tflite');
      }

      // Verify interpreter is properly initialized
      if (_interpreter == null) {
        throw Exception('Failed to initialize interpreter');
      }

      // Check input and output shapes
      var inputShape = _interpreter!.getInputTensor(0).shape;
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      print('Model input shape: $inputShape');
      print('Model output shape: $outputShape');

      // Verify output shape matches number of labels
      if (outputShape[1] != _labels.length) {
        throw Exception('Model output size (${outputShape[1]}) does not match number of labels (${_labels.length})');
      }

      _isModelLoaded = true;
      print('Model loaded successfully.');
    } catch (e) {
      _isModelLoaded = false;
      print('Error loading model: $e');
      rethrow;
    }
  }

  // Classify the image and return both label and confidence
  Future<Map<String, dynamic>> classifyImage(Uint8List imageData) async {
    if (!_isModelLoaded || _interpreter == null) {
      throw Exception('Model not loaded. Please call loadModel() first.');
    }

    try {
      // Preprocess the image
      _inputImage = _preprocessImage(imageData);

      // Prepare the output buffer
      _outputBuffer = TensorBuffer.createFixedSize([1, _labels.length], TfLiteType.float32);

      // Run inference
      _interpreter!.run(_inputImage.buffer, _outputBuffer.buffer);

      // Get the probabilities and apply softmax
      final List<double> probabilities = _outputBuffer.getDoubleList();
      final processedProbabilities = _applySoftmax(probabilities);

      // Find the highest confidence
      int classIndex = 0;
      double maxConfidence = 0.0;

      for (int i = 0; i < processedProbabilities.length; i++) {
        if (processedProbabilities[i] > maxConfidence) {
          maxConfidence = processedProbabilities[i];
          classIndex = i;
        }
      }

      // Get top 3 predictions
      List<Map<String, dynamic>> top3Predictions = [];
      var sortedIndices = List.generate(processedProbabilities.length, (i) => i)
        ..sort((a, b) => processedProbabilities[b].compareTo(processedProbabilities[a]));

      for (var i = 0; i < 3 && i < sortedIndices.length; i++) {
        var idx = sortedIndices[i];
        top3Predictions.add({
          'label': _labels[idx],
          'confidence': processedProbabilities[idx],
        });
      }

      return {
        'topPrediction': {
          'label': _labels[classIndex],
          'confidence': maxConfidence,
        },
        'top3Predictions': top3Predictions,
      };
    } catch (e) {
      print('Error during inference: $e');
      rethrow;
    }
  }

  // Apply softmax to the output probabilities
  List<double> _applySoftmax(List<double> inputs) {
    double max = inputs.reduce((curr, next) => curr <= next ? next : curr);
    List<double> exp = inputs.map((e) => math.exp(e - max)).toList();
    double sum = exp.reduce((curr, next) => curr + next);
    return exp.map((e) => e / sum).toList();
  }

  // Preprocess the image: resize and normalize it to match model input
  TensorImage _preprocessImage(Uint8List imageData) {
    // Decode the image data into an Image object
    img.Image? image = img.decodeImage(imageData);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Convert the image into a TensorImage object
    TensorImage inputImage = TensorImage(TfLiteType.uint8);
    inputImage.loadImage(image);

    // Resize the image to the model's expected input size
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(224, 224, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0.0, 255.0))  // Normalize to [0,1]
        .add(NormalizeOp(127.5, 127.5)) // Normalize to [-1,1]
        .build();

    return imageProcessor.process(inputImage);
  }

  // Dispose the interpreter
  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
    print('Model interpreter closed.');
  }
}
