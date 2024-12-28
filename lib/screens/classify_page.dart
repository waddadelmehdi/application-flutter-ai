import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/model_service.dart';
import 'dart:typed_data';

class ClassifyPage extends StatefulWidget {
  @override
  _ClassifyPageState createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  final ImagePicker _picker = ImagePicker();
  final ModelService _modelService = ModelService();
  String _classification = "Classify Images";
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _modelService.loadModel();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isLoading = true; // Start loading before classification
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
      final result = await _modelService.classifyImage(imageBytes); // Ensure async handling
      setState(() {
        _classification = result as String;
        _isLoading = false; // Stop loading after classification
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
        title: Text('Image Classifier'),
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
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.image),
            label: Text('Gallery'),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
