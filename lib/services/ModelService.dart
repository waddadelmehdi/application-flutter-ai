import 'package:tflite/tflite.dart';

class ModelService {
  // Load the TFLite model
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: 'cnn_fruits_model.tflite',
        labels: 'labels.txt',
      );
      print("Model loading result: $res");
    } catch (e) {
      print("Error loading model: $e");
      throw Exception("Failed to load TFLite model");
    }
  }

  // Run inference
  Future<List?> runModelInference(List inputData) async {
    try {
      if (inputData.isEmpty || inputData[0] == null) {
        throw Exception("Invalid input data");
      }

      var recognition = await Tflite.runModelOnImage(
        path: inputData[0],
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      print("Recognition result: $recognition");
      return recognition;
    } catch (e) {
      print("Error running inference: $e");
      return null;
    }
  }

  // Close the model
  Future<void> closeModel() async {
    try {
      await Tflite.close();
    } catch (e) {
      print("Error closing model: $e");
    }
  }
}