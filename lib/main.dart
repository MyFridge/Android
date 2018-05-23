import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home.dart';
import 'firebase.dart';

const _canvas = const Color.fromARGB(255, 213, 197, 200);
const _primary = const Color.fromARGB(255, 219, 127, 142);
const _accent = const Color.fromARGB(255, 136, 204, 241);
const _secondary = const Color.fromARGB(255, 255, 219, 218);
const _extraColor = const Color.fromARGB(255, 157, 163, 164);

Future<void> main() async {
  final FirebaseApp app = await initializeFirebase();
  runApp(MaterialApp(
    theme: ThemeData(
      canvasColor: _canvas,
      primaryColor: _primary,
      accentColor: _accent,
      cardColor: _secondary,
    ),
    debugShowCheckedModeBanner: false,
    home: new MyFridge(
      app: app,
    ),
  ));
}

class MyFridge extends StatefulWidget {
  MyFridge({this.app});
  final FirebaseApp app;

  @override
  _MyFridgeState createState() => _MyFridgeState();
}

class _MyFridgeState extends State<MyFridge> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseDatabase database = new FirebaseDatabase(app: widget.app);

    return Scaffold(
      appBar: AppBar(
        title: Text('MyFridge'),
      ),
      body: Home(
        auth: auth,
        database: database,
      ),
    );
  }
}
