import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'content.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Home extends StatelessWidget {
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    _checkForUser().then((FirebaseUser user) {
      if (user != null) {
        loadContent(context);
      }
    });

    return Center(
        child: RaisedButton(
            child: Text(
              'login',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              _email = '';
              _password = '';

              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new SimpleDialog(
                    children: <Widget>[
                      new SimpleDialogOption(
                        onPressed: null,
                        child: TextField(
                          autofocus: true,
                          onChanged: (text) => _email = text,
                          decoration:
                          new InputDecoration(labelText: 'Email Address'),
                        ),
                      ),
                      new SimpleDialogOption(
                        key: Key('password'),
                        onPressed: null,
                        child: TextField(
                          obscureText: true,
                          onChanged: (text) => _password = text,
                          decoration:
                          new InputDecoration(labelText: 'Password'),
                        ),
                      ),
                      new SimpleDialogOption(
                        onPressed: () async {
                          _handleAuth().then((user) {
                            if (user != null) {
                              loadContent(context);
                            }
                          }).catchError((error) {
                            print('Error: $error');
                          });
                        },
                        child: Text('Login'),
                      ),
                    ],
                  );
                },
              );
            }
      ),
    );
  }

  Future<FirebaseUser> _checkForUser() async {
    return await _auth.currentUser();
  }

  Future<FirebaseUser> _handleAuth() async {
    return await _auth.signInWithEmailAndPassword(
      email: _email,
      password: _password,
    );
  }

  void loadContent(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Content()),
    );
  }
}
