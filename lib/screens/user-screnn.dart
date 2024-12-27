import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ModelService.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();  // Corrigé les *
}

class _UserScreenState extends State<UserScreen> {
  final ImagePicker _picker = ImagePicker();  // Corrigé les *
  ModelService modelService = ModelService();
  XFile? _image;  // Supprimé late car c'est nullable, corrigé les *
  String result = "No result yet";

  @override
  void initState() {
    super.initState();
    modelService.loadModel();
  }

  @override
  void dispose() {
    modelService.closeModel();
    super.dispose();
  }

  // Function to pick an image and run inference
  void _pickImage() async {  // Corrigé les *
    try {
      final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() {
          _image = selectedImage;
        });

        // Run inference on the selected image
        var inferenceResult = await modelService.runModelInference([selectedImage.path]);
        setState(() {
          result = inferenceResult != null ? inferenceResult.toString() : "Inference failed";
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        result = "Error selecting image";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Model Inference"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,  // Ajouté une hauteur fixe
                width: 200,   // Ajouté une largeur fixe
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                width: 200,
                color: Colors.grey[300],
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick an image"),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Inference result: $result",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}