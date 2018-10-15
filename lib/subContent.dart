import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'fridge.dart';
import 'item.dart';
import 'settings.dart';

class SubContent extends StatefulWidget {
  SubContent({this.fridge});
  final Fridge fridge;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  String _addName = '';
  String _addDescription = '';
  String _editName = '';
  String _editDescription = '';

  @override
  State<StatefulWidget> createState() => _SubContentState();
}

class _SubContentState extends State<SubContent> {
  List<Item> _items = new List();
  FirebaseUser _user;

  void getData() {
    print(_items);
    widget.database
        .reference()
        .child('fridges')
        .child(widget.fridge.key)
        .child('items')
        .onValue
        .listen((Event event) {
      _items.clear();

      event.snapshot.value.forEach((k, v) {
        var newItem = new Item(key: k);

        v.forEach((k, v) {
          if (k == 'name') {
            newItem.name = v;
          } else if (k == 'description') {
            newItem.description = v;
          }
        });

        this.setState(() {
          _items.add(newItem);
          _items.sort((Item a, Item b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
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
        title: Text(widget.fridge.name),
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
        itemBuilder: (BuildContext context, int index) => new ItemItem(
              item: _items[index],
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
                          'Edit Item',
                          style: TextStyle(fontSize: 24.0),
                        ),
                        TextField(
                          onChanged: (value) {
                            widget._editName = value;
                          },
                          decoration: InputDecoration(
                              labelText: _items[index].name,
                              hintText: 'New Name'),
                        ),
                        TextField(
                          onChanged: (value) {
                            widget._editDescription = value;
                          },
                          decoration: InputDecoration(
                              labelText: _items[index].description,
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
                                    : _items[index].name;
                                var _description =
                                widget._editDescription.length > 0
                                    ? widget._editDescription
                                    : _items[index].description;
                                widget.database
                                    .reference()
                                    .child('fridges')
                                    .child(widget.fridge.key)
                                    .child("items")
                                    .child(_items[index].key)
                                    .update({
                                  'name': _name,
                                  'description': _description
                                });
                                Navigator.pop(context);
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
                      title: new Text('Delete ${_items[index].name}?'),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text(
                                'Are you sure you want to delete this item?'),
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
                          child: new Text('Delete'),
                          onPressed: () {
                            widget.database
                                .reference()
                                .child('fridges')
                                .child(widget.fridge.key)
                                .child('items')
                                .child(_items[index].key)
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
        itemCount: _items.length,
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
                      'Add Item',
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
                                  .child('fridges')
                                  .child(widget.fridge.key)
                                  .child('items')
                                  .child(key)
                                  .set({
                                'name': widget._addName,
                                'description': widget._addDescription
                              });

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
