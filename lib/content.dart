import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'settings.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _database = FirebaseDatabase.instance.reference();

class Content extends StatefulWidget {
  Content();
  @override
  State<StatefulWidget> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  List _fridgeIds = new List();

  @override
  void initState() {
    super.initState();
    _getUser().then((FirebaseUser user) {
      _database
          .child('users')
          .child(user.uid)
          .child('fridges')
          .once()
          .then((DataSnapshot snapshot) {
            
      });
    }).catchError((Error error) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new FlatButton(
          onPressed: null,
          child: null,
        ),
        title: new Text('Fridges'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new Settings()),
              );
            },
            child: new Text(
              'Settings',
              style: new TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new ListView(),
    );
  }

  Future<FirebaseUser> _getUser() async {
    return await _auth.currentUser();
  }
}
