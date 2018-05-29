import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'home.dart';

const _canvas = const Color.fromARGB(255, 27, 27, 30);
const _primary = const Color.fromARGB(255, 55, 63, 81);
const _accent = const Color.fromARGB(255, 88, 164, 176);
const _secondary = const Color.fromARGB(255, 169, 188, 208);
const _extraColor = const Color.fromARGB(255, 157, 163, 164);

void main() => runApp(MaterialApp(
      theme: ThemeData(
        canvasColor: _canvas,
        primaryColor: _primary,
        accentColor: _accent,
        cardColor: _secondary,
        textTheme: Typography(
                platform: Platform.isIOS
                    ? TargetPlatform.iOS
                    : TargetPlatform.android)
            .white,
      ),
      debugShowCheckedModeBanner: false,
      home: MyFridge(),
    ));

class MyFridge extends StatefulWidget {
  @override
  _MyFridgeState createState() => _MyFridgeState();
}

class _MyFridgeState extends State<MyFridge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFridge'),
      ),
      body: Home(),
    );
  }
}
