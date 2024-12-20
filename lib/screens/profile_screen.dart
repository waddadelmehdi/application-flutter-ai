import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  // Function to pick and upload an image to Firebase Storage
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        // Upload image to Firebase Storage
        final ref = _storage.ref().child('profile_pictures/${_user.uid}.jpg');
        await ref.putFile(file);

        // Get the image URL
        final imageUrl = await ref.getDownloadURL();

        // Save the image URL to Firestore
        await _firestore.collection('users').doc(_user.uid).set({
          'profileImage': imageUrl,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Profile Picture'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _uploadImage,
          child: Text('Upload Image'),
        ),
      ),
    );
  }
}
