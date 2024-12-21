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
              UserAccountsDrawerHeader(
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
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data?.exists == false) {
                      // Use default image if there is an error or no data
                      return CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://www.example.com/default_profile_picture.png', // Replace with your default image URL
                        ),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null && data['profileImage'] != null) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(data['profileImage']),
                      );
                    }

                    // Use default image if profileImage is not available
                    return CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://www.example.com/default_profile_picture.png', // Replace with your default image URL
                      ),
                    );
                  },
                ),
              ),
              // Drawer items with blue styling
              _buildDrawerItem(
                context,
                title: 'Image Assistance',
                icon: Icons.image,
                onTap: () {
                  Navigator.pushNamed(context, '/image-assistance');
                },
              ),
              _buildDrawerItem(
                context,
                title: 'Vocal Assistance',
                icon: Icons.volume_up,
                onTap: () {
                  Navigator.pushNamed(context, '/assistenvocal');
                },
              ),
              _buildDrawerItem(
                context,
                title: 'Sign Out',
                icon: Icons.exit_to_app,
                onTap: () async {
                  await _auth.signOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
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
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required String title, required IconData icon, required Function onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => onTap(),
    );
  }
}
