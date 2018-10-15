import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'content.dart';

final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
bool _hasLoaded = false;

class Home extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  String _email = '';
  String _password = '';
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    if (!_hasLoaded) {
      _hasLoaded = true;
      database.setPersistenceEnabled(true);
      _checkForUser().then((user) {
        if (user != null) {
          _loadContent(context);
        }
      });
    }

    var emailFormField = TextFormField(
      decoration: const InputDecoration(labelText: 'Email Address'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value.isEmpty ||
            !value.contains('@') ||
            !value.contains('.')) {
          _email = '';
          return 'A valid email address is required.';
        } else {
          _email = value;
        }
      },
    );

    var passwordFormField = TextFormField(
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          _password = '';
          return 'A password is required.';
        } else {
          _password = value;
        }
      },
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  emailFormField,
                  passwordFormField,
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: const Text('Logging in...')));

                          _handleAuth(_email, _password)
                              .then((FirebaseUser user) {
                            Scaffold.of(context).hideCurrentSnackBar();
                            _loadContent(context);
                          }).catchError((error) {
                            Scaffold.of(context).showSnackBar(const SnackBar(
                                content: const Text(
                                    'The email address or password are incorrect.')));
                          });
                        }
                      },
                      child: const Text('login'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(const SnackBar(
                              content: const Text('Creating account...')));

                          _handleRegister(_email, _password)
                              .then((FirebaseUser user) {
                            Scaffold.of(context).hideCurrentSnackBar();
                            _loadContent(context);
                          }).catchError((error) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                duration: Duration(seconds: 10),
                                content: Text(error.toString())));
                          });
                        }
                      },
                      child: const Text('register'),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: RaisedButton(
                  onPressed: () {
                    showDialog<Null>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: new Text('Login With Your Phone Number'),
                          content: new SingleChildScrollView(
                            child: new ListBody(
                              children: <Widget>[
                                new Text('Please enter your phone number.'),
                                new TextField(
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    _phoneNumber = value;
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
                              child: new Text('Login'),
                              onPressed: () {
                                if (_phoneNumber.length > 0) {
                                  Navigator.pop(context);
                                  _handlePhoneAuth(context, _phoneNumber);
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
                                                  'A phone number is required!'),
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
                  child: const Text('login with phone number'),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Future<FirebaseUser> _checkForUser() async {
    return await auth.currentUser();
  }

  Future<FirebaseUser> _handleAuth(String email, String password) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void _handlePhoneAuth(BuildContext context, String phoneNumber) {
    auth.verifyPhoneNumber(
        phoneNumber: '+1$phoneNumber',
        timeout: const Duration(seconds: 300),
        verificationCompleted: (FirebaseUser user) {
          print('fart');
        },
        verificationFailed: (AuthException exception) {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: const Text('Unable to log in with your phone number.')));
        },
        codeSent: (String verificationId, [int]) {
          _handleSMSVerification(context, verificationId);
        },
        codeAutoRetrievalTimeout: null);
  }

  void _handleSMSVerification(BuildContext context, String verificationId) {
    String _smsCode = '';
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Verify Your Phone Number'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Please enter the code sent to your phone.'),
                new TextField(
                  onChanged: (value) {
                    _smsCode = value;
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
              child: new Text('Login'),
              onPressed: () {
                if (_smsCode.length > 0) {
                  auth.signInWithPhoneNumber(
                      verificationId: verificationId,
                      smsCode: _smsCode
                  ).then((FirebaseUser user) {
                    _loadContent(context);
                  }).catchError((error) {
                    Scaffold.of(context).showSnackBar(const SnackBar(
                        content: const Text('There was an unexpected error.')));
                  });
                  _smsCode = '';
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
                                  'The sms code is required!'),
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
  }

  Future<FirebaseUser> _handleRegister(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password
    );
  }

  void _loadContent(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new Content(),
      ),
    );
  }
}
