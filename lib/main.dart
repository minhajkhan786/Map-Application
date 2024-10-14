import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vinove_demo/login_screen.dart';
import 'package:vinove_demo/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyAkTtAVOsQ_RqLSumrP1-dN_SobagvcHx4",
    appId: "1:65649670770:android:69fc814082ec26d32aa0eb",
    messagingSenderId: "65649670770",
    projectId: "person-location-dd352",
    storageBucket: "person-location-dd352.appspot.com",
  ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              backgroundColor: Color(0xff4434A7),
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.grey,
                  systemNavigationBarColor: Colors.white)),
          scaffoldBackgroundColor: Colors.white),
      home: AuthGate(),
    );
  }
}

// Create an AuthGate widget to determine the initial screen
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(), // Listen for auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }
        if (snapshot.hasData) {
          // User is signed in
          return MapScreen(); // Navigate to HomePage if logged in
        } else {
          // User is not signed in
          return LoginScreen(); // Navigate to LoginPage if not logged in
        }
      },
    );
  }
}
