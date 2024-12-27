import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Model Load Test')),
        body: ModelTestScreen(),
      ),
    );
  }
}

class ModelTestScreen extends StatefulWidget {
  @override
  _ModelTestScreenState createState() => _ModelTestScreenState();
}

class _ModelTestScreenState extends State<ModelTestScreen> {
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      print('Loading model...');
      final asset = await rootBundle.load('cnn_fruits_model.tflite');
      print('Model loaded successfully: ${asset.lengthInBytes} bytes');
      _interpreter = await Interpreter.fromAsset('cnn_fruits_model.tflite');
      print('Model loaded successfully.');
    } catch (e) {
      print('Error loading model: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _interpreter == null
          ? CircularProgressIndicator()
          : Text('Model Loaded Successfully'),
    );
  }
}
