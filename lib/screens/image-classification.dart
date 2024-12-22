import 'package:flutter/material.dart';

class ImageClassificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Classification'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'Image Classification Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
