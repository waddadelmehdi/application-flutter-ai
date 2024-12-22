import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class ModelService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('cnn_fmnist.tflite');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  String classifyImage(Uint8List imageData) {
    // Prepare input and output tensors
    final input = imageData.buffer.asUint8List();
    final output = List.filled(10, 0.0).reshape([1, 10]);

    // Run inference
    _interpreter?.run(input, output);

    // Find the highest confidence class
    final classIndex = output[0].indexWhere((val) => val == output[0].reduce((a, b) => a > b ? a : b));
    return _getClassLabel(classIndex);
  }

  String _getClassLabel(int index) {
    const labels = ['T-shirt', 'Trouser', 'Pullover', 'Dress', 'Coat', 'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot'];
    return labels[index];
  }

  void dispose() {
    _interpreter?.close();
  }
}
