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

  String _addName = '';
  String _addDescription = '';
  String _editName = '';
  String _editDescription = '';

  String _addUID = '';

  @override
  State<StatefulWidget> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  List<Fridge> _fridges = new List();
  FirebaseUser _user;

  int findFridge(String key) {
    if (_fridges.length == 0) {
      return -1;
    }

    return _fridges.indexWhere((Fridge fridge) {
      return fridge.key == key;
    });
  }

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
            .onValue
            .listen((Event event) {
          if (event.snapshot.value != null) {
            var index = findFridge(key);
            if (index == -1) {
              Fridge newFridge = new Fridge(key: key);

              event.snapshot.value.forEach((k, v) {
                if (k == 'name') {
                  newFridge.name = v;
                } else if (k == 'description') {
                  newFridge.description = v;
                } else if (k == 'users') {
                  widget.database
                      .reference()
                      .child('fridges')
                      .child(key)
                      .child('users')
                      .child(_user.uid)
                      .child('permissions')
                      .once()
                      .then((DataSnapshot snapshot) {
                    newFridge.permissions = snapshot.value;
                  });
                }
              });

              setState(() {
                _fridges.add(newFridge);
                _fridges.sort((Fridge a, Fridge b) {
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });
              });
            } else {
              event.snapshot.value.forEach((k, v) {
                if (k == 'name') {
                  setState(() {
                    _fridges[index].name = v;
                  });
                } else if (k == 'description') {
                  setState(() {
                    _fridges[index].description = v;
                  });
                }
              });
            }
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
      this.getData();
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
                widget._editName = '';
                widget._editDescription = '';
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
                          onChanged: (value) {
                            widget._editName = value;
                          },
                          decoration: InputDecoration(
                              labelText: _fridges[index].name,
                              hintText: 'New Name'),
                        ),
                        TextField(
                          onChanged: (value) {
                            widget._editDescription = value;
                          },
                          decoration: InputDecoration(
                              labelText: _fridges[index].description,
                              hintText: 'New Description'),
                        ),
                        new Center(
                          child: new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: RaisedButton(
                              child: const Text('Save'),
                              onPressed: () {
                                var _name = widget._editName.length > 0
                                    ? widget._editName
                                    : _fridges[index].name;
                                var _description =
                                    widget._editDescription.length > 0
                                        ? widget._editDescription
                                        : _fridges[index].description;
                                widget.database
                                    .reference()
                                    .child('fridges')
                                    .child(_fridges[index].key)
                                    .update({
                                  'name': _name,
                                  'description': _description
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        new Center(
                          child: new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: RaisedButton(
                              child: const Text('Add Person To Fridge'),
                              onPressed: () {
                                showDialog<Null>(
                                  context: context,
                                  barrierDismissible:
                                      false, // user must tap button!
                                  builder: (BuildContext context) {
                                    return new AlertDialog(
                                      title: new Text('Add Person to Fridge'),
                                      content: new SingleChildScrollView(
                                        child: new ListBody(
                                          children: <Widget>[
                                            new Text(
                                                'Please provide the UID of the user you would like to add to your fridge.'),
                                            new TextField(
                                              onChanged: (value) {
                                                widget._addUID = value;
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
                                          child: new Text('Add'),
                                          onPressed: () {
                                            if (widget._addUID.length > 0) {
                                              widget._addUID = '';
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            } else {
                                              showDialog<Null>(
                                                context: context,
                                                barrierDismissible:
                                                    false, // user must tap button!
                                                builder:
                                                    (BuildContext context) {
                                                  return new AlertDialog(
                                                    title: new Text('Error'),
                                                    content:
                                                        new SingleChildScrollView(
                                                      child: new ListBody(
                                                        children: <Widget>[
                                                          new Text(
                                                              'A UID is required!'),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      new FlatButton(
                                                        child: new Text('Ok'),
                                                        onPressed: () {
                                                          Navigator
                                                              .pop(context);
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
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 10,
                        ),
                      ],
                    ),
                  );
                });
              },
              onDelete: () {
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text('Delete ${_fridges[index].name}?'),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text(
                                'Are you sure you want to delete this fridge list?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text('Delete'),
                          onPressed: () {
                            widget.database
                                .reference()
                                .child('fridges')
                                .child(_fridges[index].key)
                                .remove();
                            widget.database
                                .reference()
                                .child('users')
                                .child(_user.uid)
                                .child('fridges')
                                .child(_fridges[index].key)
                                .remove();

                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  },
                );
              },
              onLeave: () {
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text('Leave ${_fridges[index].name}?'),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text(
                                'Are you sure you want to leave this fridge list?'),
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
                          child: new Text('Leave'),
                          onPressed: () {
                            widget.database
                                .reference()
                                .child('fridges')
                                .child(_fridges[index].key)
                                .child('users')
                                .child(_user.uid)
                                .remove();
                            widget.database
                                .reference()
                                .child('users')
                                .child(_user.uid)
                                .child('fridges')
                                .child(_fridges[index].key)
                                .remove();

                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
        itemCount: _fridges.length,
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          onPressed: () {
            Scaffold.of(context).showBottomSheet((context) {
              return Container(
                padding: EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Add Fridge',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextField(
                      onChanged: (value) {
                        widget._addName = value;
                      },
                      decoration: InputDecoration(hintText: 'Name'),
                    ),
                    TextField(
                      onChanged: (value) {
                        widget._addDescription = value;
                      },
                      decoration: InputDecoration(hintText: 'Description'),
                    ),
                    new Center(
                      child: new Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RaisedButton(
                          child: const Text('Add'),
                          onPressed: () {
                            if (widget._addName.length > 0) {
                              var key = widget.database.reference().push().key;
                              widget.database
                                  .reference()
                                  .child("fridges")
                                  .child(key)
                                  .set({
                                'name': widget._addName,
                                'description': widget._addDescription,
                                'users': {
                                  _user.uid: {'permissions': 2}
                                }
                              });
                              widget.database
                                  .reference()
                                  .child("users")
                                  .child(_user.uid)
                                  .child("fridges")
                                  .child(key)
                                  .set(key);

                              widget._addName = '';
                              widget._addDescription = '';

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
                                          new Text('A name is required!'),
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
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 10,
                    ),
                  ],
                ),
              );
            });
          },
          child: Icon(Icons.add),
        );
      }),
    );
  }

  Future<FirebaseUser> _getUser() async {
    return await widget.auth.currentUser();
  }
}
