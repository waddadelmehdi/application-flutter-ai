import 'package:application/screens/ANNImageClassificationScreen.dart';
import 'package:application/screens/image-classification.dart';
import 'package:application/screens/stock_price_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assistenvocal.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
 // Ensure the correct path for your UserScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Authentication Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Dynamically decide the home screen based on the user's authentication state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While waiting for authentication state to be determined
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // If user is logged in, show HomeScreen, else show LoginScreen
          if (snapshot.hasData) {
            return HomeScreen(); // Home screen for authenticated users
          }
          return LoginScreen(); // Login screen for unauthenticated users
        },
      ),
      // Define routes to navigate between different screens
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/assistenvocal': (context) => Assistenvocal(),
        '/image-classification': (context) => ImageClassificationPage(),
        '/stock-price': (context) => StockPriceScreen(),// UserScreen route
        '/ann': (context) => ANNImageClassificationScreen(),
      },
    );
  }
}
