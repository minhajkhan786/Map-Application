import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vinove_demo/map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vinove_demo/models/APIs.dart';


class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  // Store user data in Firestore
  // Future<void> _storeUserData(String userId) async {
  //   await _firestore.collection('users').doc(userId).set({
  //     'email': _emailController.text,
  //     'password': _passwordController.text
  //
  //
  //   });
  // }

  Future<void> _loginWithEmailPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Call createUser to store user data in Firestore
      await APIs.createUser();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(),
        ),
      ); // Navigate to the home page on success
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _registerWithEmailPassword() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Call createUser to store user data in Firestore
      await APIs.createUser();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(),
        ),
      ); // Navigate to home page on success
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithEmailPassword,
              child: Text("Login"),
            ),
            ElevatedButton(
              onPressed: _registerWithEmailPassword,
              child: Text("Register"),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
