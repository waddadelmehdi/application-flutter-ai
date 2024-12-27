import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;  // Import the image package
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class ModelService {
  Interpreter? _interpreter;
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;
  List<String> _labels = [];

  // Load the model and labels
  Future<void> loadModel() async {
    try {
      print('Loading model...');
      final asset = await rootBundle.load('assets/cnn_fruits_model.tflite');
      print('Model loaded successfully: ${asset.lengthInBytes} bytes');
      _interpreter = await Interpreter.fromAsset('assets/cnn_fruits_model.tflite');
      print('Model loaded successfully.');
    } catch (e) {
      print('Error loading model: $e');
    }
  }


  // Load the labels from labels.txt
  Future<List<String>> _loadLabels() async {
    final labelsData = await rootBundle.loadString('labels.txt');
    return labelsData.split('\n'); // Assuming each label is on a new line
  }

  // Classify the image and return the label with the highest confidence
  Future<String> classifyImage(Uint8List imageData) async {
    if (_interpreter == null) {
      print('Model not loaded.');
      return 'Model not loaded.';
    }

    try {
      // Preprocess the image
      _inputImage = _preprocessImage(imageData);

      // Prepare the output buffer
      _outputBuffer = TensorBuffer.createFixedSize([1, _labels.length], TfLiteType.float32);

      // Run inference
      _interpreter!.run(_inputImage.buffer, _outputBuffer.buffer);

      // Get the highest confidence index
      final probabilities = _outputBuffer.getDoubleList();
      final classIndex = probabilities.indexWhere(
            (val) => val == probabilities.reduce((a, b) => a > b ? a : b),
      );

      return _getClassLabel(classIndex);
    } catch (e) {
      print('Error during inference: $e');
      return 'Error during classification.';
    }
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
    inputImage.loadImage(image);  // Load the decoded image into TensorImage

    // Resize the image to the model's expected input size (adjust if needed)
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(224, 224, ResizeMethod.BILINEAR)) // Assuming 224x224 for fruit images
        .add(NormalizeOp(0.0, 255.0))  // Normalizing pixel values
        .build();

    return imageProcessor.process(inputImage);
  }

  // Get the class label from the index
  String _getClassLabel(int index) {
    if (index < 0 || index >= _labels.length) {
      return 'Unknown';
    }
    return _labels[index];
  }

  // Dispose the interpreter
  void dispose() {
    _interpreter?.close();
    print('Model interpreter closed.');
  }
}
