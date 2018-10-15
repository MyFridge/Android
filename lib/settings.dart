import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share/share.dart';

class Settings extends StatefulWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  String _name = '';
  String _uid = '';

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
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Text(
                      'Name: ${widget._name}',
                      style: new TextStyle(
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      showDialog<Null>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return new AlertDialog(
                            title: new Text('Change Display Name'),
                            content: new SingleChildScrollView(
                              child: new ListBody(
                                children: <Widget>[
                                  new Text('Please enter a new display name.'),
                                  new TextField(
                                    onChanged: (value) {
                                      widget._name = value;
                                    },
                                  )
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              new FlatButton(
                                child: new Text('Save'),
                                onPressed: () {
                                  if (widget._name.length > 0) {
                                    widget.database
                                        .reference()
                                        .child("users")
                                        .child(widget._uid)
                                        .update({
                                          'name': widget._name
                                        });
                                    widget._name = '';
                                    Navigator.pop(context);
                                  } else {
                                    showDialog<Null>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return new AlertDialog(
                                          title: new Text('Error'),
                                          content: new SingleChildScrollView(
                                            child: new ListBody(
                                              children: <Widget>[
                                                new Text(
                                                    'A display name is required!'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('Ok'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('edit'),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Text(
                      'UID: ${widget._uid.substring(0, widget._uid.length > 6 ? 6 : 0)}',
                      style: new TextStyle(
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      Share.share('Here is my Fridge List UID: ${widget._uid}');
                    },
                    child: const Text('share'),
                  ),
                ],
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
    return await widget.auth.currentUser().then((FirebaseUser user) {
      if (user != null) {
        widget.database
            .reference()
            .child('users')
            .child(user.uid)
            .once()
            .then((DataSnapshot snapshot) {
          snapshot.value.forEach((k, v) {
            if (k == 'name' && widget._name != v) {
              setState(() {
                widget._name = v;
                widget._uid = user.uid;
              });
            }
          });
        });
      }
    });
  }
}
