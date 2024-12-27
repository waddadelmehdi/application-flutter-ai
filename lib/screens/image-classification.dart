import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/model_service.dart';
import 'dart:typed_data';

class ImageClassificationScreen extends StatefulWidget {
  @override
  _ClassifyPageState createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ImageClassificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final ModelService _modelService = ModelService();
  String _classification = "Classify Images";
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    print('Loading model...');
    _modelService.loadModel().then((_) {
      setState(() {
        _isModelLoaded = true;
        print('Model is loaded.');
      });
    }).catchError((error) {
      print('Error loading model: $error');
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isLoading = true;
        });
        await _classifyImage(bytes);
      }
    } catch (e) {
      setState(() {
        _classification = "Failed to pick or process image.";
        _isLoading = false;
      });
    }
  }

  Future<void> _classifyImage(Uint8List imageBytes) async {
    try {
      final result = await _modelService.classifyImage(imageBytes);
      setState(() {
        _classification = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _classification = "Failed to classify image.";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fruit Classifier'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            CircularProgressIndicator()
          else
            Column(
              children: [
                Text(
                  _classification,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_imageBytes != null)
                  Image.memory(
                    _imageBytes!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text('Camera'),
            onPressed: _isModelLoaded && !_isLoading
                ? () => _pickImage(ImageSource.camera)
                : null,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.image),
            label: Text('Gallery'),
            onPressed: _isModelLoaded && !_isLoading
                ? () => _pickImage(ImageSource.gallery)
                : null,
          ),
        ],
      ),
    );
  }
}
