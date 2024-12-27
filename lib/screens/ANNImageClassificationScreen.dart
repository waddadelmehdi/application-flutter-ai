import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ANNImageClassificationScreen extends StatefulWidget {
  @override
  _ANNImageClassificationScreenState createState() =>
      _ANNImageClassificationScreenState();
}

class _ANNImageClassificationScreenState
    extends State<ANNImageClassificationScreen> {
  File? _selectedImage;
  String? _classificationResult;
  tfl.Interpreter? _interpreter;
  ImageProcessor? _imageProcessor;
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      // Load the TFLite model
      _interpreter = await tfl.Interpreter.fromAsset('ann_model.tflite');

      // Load labels from a file (assumes labels.txt exists in assets)
      final labelsData = await DefaultAssetBundle.of(context)
          .loadString('assets/labels.txt');
      _labels = labelsData.split('\n');
    } catch (e) {
      print('Error loading model or labels: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Perform image classification
      _classifyImage();
    }
  }

  Future<void> _classifyImage() async {
    if (_selectedImage == null || _interpreter == null) return;

    try {
      // Preprocess the image to match the model input
      final imageInput = _preprocessImage(_selectedImage!);

      // Perform inference
      final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
      _interpreter!.run(imageInput, output);

      // Find the label with the highest confidence score
      final confidences = output[0];
      final maxConfidenceIndex = confidences.indexWhere((value) =>
      value == confidences.reduce((value1, value2) => value1 > value2 ? value1 : value2));

      setState(() {
        _classificationResult = _labels[maxConfidenceIndex];
      });
    } catch (e) {
      print('Error classifying image: $e');
    }
  }

  ByteBuffer _preprocessImage(File imageFile) {
    final image = FileImage(imageFile);
    final imageSize = 224; // Adjust based on your model's input size

    _imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(imageSize, imageSize, ResizeMethod.BILINEAR))
        .build();

    final inputTensor = TensorImage.fromFile(imageFile);
    return _imageProcessor!.process(inputTensor).buffer;
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ANN Image Classification'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? Image.file(
              _selectedImage!,
              width: 200,
              height: 200,
            )
                : Text(
              'Select an image to classify',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            if (_classificationResult != null)
              Text(
                'Result: $_classificationResult',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
