import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'home.dart';
import 'firebase.dart';

Future<void> main() async {
  final FirebaseApp app = await initializeFirebase();
  runApp(new MyFridge());
}

const _canvas = const Color.fromARGB(255, 213, 197, 200);
const _primary = const Color.fromARGB(255, 219, 127, 142);
const _accent = const Color.fromARGB(255, 136, 204, 241);
const _secondary = const Color.fromARGB(255, 255, 219, 218);
const _extraColor = const Color.fromARGB(255, 157, 163, 164);

class MyFridge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: _canvas,
        primaryColor: _primary,
        accentColor: _accent,
        cardColor: _secondary,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('MyFridge'),
        ),
        body: Home(),
      ),
    );
  }
}
