import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ApiService.dart';
import '../services/model_service.dart';
import 'dart:typed_data';

class ImageClassificationPage extends StatefulWidget {
  const ImageClassificationPage({super.key});

  @override
  _ImageClassificationPageState createState() => _ImageClassificationPageState();
}

class _ImageClassificationPageState extends State<ImageClassificationPage> {
  final ImagePicker _picker = ImagePicker();
  final ModelService _modelService = ModelService();
  final ApiService _apiService = ApiService(baseUrl: 'http://192.168.11.108:8089');
  List<Map<String, dynamic>> _predictions = [];
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeModel() async {
    setState(() => _isLoading = true);
    try {
      await _modelService.loadModel();
      print('Model initialized successfully');
    } catch (e) {
      setState(() => _error = 'Failed to initialize model: $e');
      print('Failed to initialize model: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isLoading = true;
          _error = '';
        });
        await _classifyImage(bytes);
      }
    } catch (e) {
      setState(() => _error = 'Error picking image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _classifyImage(Uint8List imageBytes) async {
    try {
      final result = await _apiService.classifyImage(imageBytes);
      setState(() {
        _predictions = result['top3Predictions'];
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = 'Classification error: $e';
        _predictions = [];
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
        title: const Text('Fruit Classifier'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error.isNotEmpty)
                Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _error,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
              if (_imageBytes != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      _imageBytes!,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_predictions.isNotEmpty) ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Predictions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  _predictions.length,
                      (index) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        _predictions[index]['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: LinearProgressIndicator(
                        value: _predictions[index]['confidence'] as double,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.withOpacity(
                            (_predictions[index]['confidence'] as double),
                          ),
                        ),
                      ),
                      trailing: Text(
                        '${((_predictions[index]['confidence'] as double) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}