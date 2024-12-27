import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue.shade50,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildUserHeader(user),
              _buildDrawerItem(
                context,
                title: 'Home',
                icon: Icons.home,
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              _buildImageClassificationMenu(context),
              _buildDrawerItem(
                context,
                title: 'Vocal Assistance',
                icon: Icons.volume_up,
                onTap: () {
                  Navigator.pushNamed(context, '/assistenvocal');
                },
              ),
              // New "Stock Price Prediction" Menu Item
              _buildDrawerItem(
                context,
                title: 'Stock Price Prediction',
                icon: Icons.show_chart,
                onTap: () {
                  Navigator.pushNamed(context, '/stock-price');
                },
              ),
              _buildDrawerItem(
                context,
                title: 'Sign Out',
                icon: Icons.exit_to_app,
                onTap: () async {
                  await _auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(user),
    );
  }

  Widget _buildUserHeader(User? user) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
      ),
      accountName: Text(
        user?.email?.split('@')[0] ?? 'Guest',
        style: TextStyle(color: Colors.white),
      ),
      accountEmail: Text(
        user?.email ?? 'guest@example.com',
        style: TextStyle(color: Colors.white70),
      ),
      currentAccountPicture: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              backgroundColor: Colors.white,
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data?.exists == false) {
            return CircleAvatar(
              backgroundImage: NetworkImage(
                'https://www.example.com/default_profile_picture.png', // Replace with your default image URL
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final profileImage = data?['profileImage'];
          return CircleAvatar(
            backgroundImage: NetworkImage(
              profileImage ?? 'https://www.example.com/default_profile_picture.png',
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageClassificationMenu(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.image, color: Colors.blueAccent),
      title: Text(
        'Image Classification',
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
      ),
      children: [
        _buildDrawerItem(
          context,
          title: 'ANN',
          icon: Icons.adjust,
          onTap: () {
            Navigator.pushNamed(context, '/ann');
          },
        ),
        _buildDrawerItem(
          context,
          title: 'CNN',
          icon: Icons.apps,
          onTap: () {
            Navigator.pushNamed(context, '/image-classification');
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required String title, required IconData icon, required Function onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
      ),
      onTap: () => onTap(),
    );
  }

  Widget _buildBody(User? user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(
                Icons.home,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Welcome, ${user?.email ?? 'Guest'}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'We’re glad to see you back!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
