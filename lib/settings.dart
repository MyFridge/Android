import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _database = FirebaseDatabase.instance.reference();

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _database.child('fridges').once().then((DataSnapshot snapshot) {
      print(snapshot.value);
    }).catchError((DatabaseError error) {
      print(error.message);
    });
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Settings'),
      ),
      body: new Container(
        padding: EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new Text(
                  'Settings',
                  style: new TextStyle(
                    fontSize: 24.0,
                  ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
