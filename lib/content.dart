import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'fridge.dart';
import 'settings.dart';
import 'subContent.dart';

class Content extends StatefulWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  State<StatefulWidget> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  List<Fridge> _fridges = new List();
  FirebaseUser _user;

  void getData() {
    widget.database
        .reference()
        .child('users')
        .child(_user.uid)
        .child('fridges')
        .onValue
        .listen((Event event) {
      event.snapshot.value.forEach((k, v) {
        _fridges.clear();
        var key = v;

        widget.database
            .reference()
            .child('fridges')
            .child(key)
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            Fridge newFridge = new Fridge(key: key);

            snapshot.value.forEach((k, v) {
              if (k == 'name') {
                newFridge.name = v;
              } else if (k == 'description') {
                newFridge.description = v;
              }
            });

            setState(() {
              _fridges.add(newFridge);
              _fridges.sort((Fridge a, Fridge b) {
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              });
            });
          }
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser().then((FirebaseUser user) {
      _user = user;
      getData();
    }).catchError((Error error) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: const FlatButton(
          onPressed: null,
          child: null,
        ),
        title: const Text('Fridges'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
            child: const Text(
              'Settings',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new ListView.builder(
        itemBuilder: (BuildContext context, int index) => new FridgeItem(
              fridge: _fridges[index],
              onView: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new SubContent(
                          fridge: _fridges[index],
                        ),
                  ),
                );
              },
              onEdit: () {
                Scaffold.of(context).showBottomSheet((context) {
                  return Container(
                    padding: EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Edit Fridge',
                          style: TextStyle(fontSize: 24.0),
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: _fridges[index].name,
                              hintText: 'New Name'),
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: _fridges[index].description,
                              hintText: 'New Description'),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 10,
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
        itemCount: _fridges.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<FirebaseUser> _getUser() async {
    return await widget.auth.currentUser();
  }
}
