import 'package:flutter/material.dart';
import 'package:animateon/screens/welcomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alkalmazás Neve',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(), // Itt adjuk meg az üdvözlőképernyőt kezdőképernyőként
    );
  }
}

