import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyFridge(),
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
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
