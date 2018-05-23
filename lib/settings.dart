import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

String _name = '';

class Settings extends StatefulWidget {
  Settings({this.auth, this.user, this.database});
  final FirebaseAuth auth;
  final FirebaseUser user;
  final FirebaseDatabase database;

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    _getInfo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8.0),
              child: new Text(
                'Name: ${_name}',
                style: new TextStyle(
                  fontSize: 24.0,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: new Text(
                'UID: ${widget.user.uid.substring(0, 6)}',
                style: new TextStyle(
                  fontSize: 24.0,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            RaisedButton(
              onPressed: () {
                widget.auth.signOut();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('logout'),
            )
          ],
        ),
      ),
    );
  }

  Future _getInfo() async {
    return await widget.database
        .reference()
        .child('users')
        .child(widget.user.uid)
        .once()
        .then((DataSnapshot snapshot) {
      snapshot.value.forEach((k, v) {
        if (k == 'name' && _name != v) {
          setState(() {
            _name = v;
          });
        }
      });
    });
  }
}
