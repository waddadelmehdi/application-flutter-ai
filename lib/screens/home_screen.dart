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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.email?.split('@')[0] ?? 'Guest'),
              accountEmail: Text(user?.email ?? 'guest@example.com'),
              currentAccountPicture: FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(user?.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://th.bing.com/th/id/OIP.IGNf7GuQaCqz_RPq5wCkPgHaLH?w=3476&h=5214&rs=1&pid=ImgDetMain',
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final imageUrl = data['profileImage'];

                  if (imageUrl != null) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                    );
                  }

                  return CircleAvatar(
                    child: Icon(Icons.person),
                  );
                },
              ),
            ),
            // Other drawer items
            ListTile(
              title: Text('Image Assistance'),
              leading: Icon(Icons.image),
              onTap: () {
                Navigator.pushNamed(context, '/image-assistance');
              },
            ),
            ListTile(
              title: Text('Vocal Assistance'),
              leading: Icon(Icons.volume_up),
              onTap: () {
                Navigator.pushNamed(context, '/assistenvocal');
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              leading: Icon(Icons.exit_to_app),
              onTap: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.email ?? 'Guest'}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
