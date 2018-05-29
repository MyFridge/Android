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

  @override
  State<StatefulWidget> createState() => _SubContentState();
}

class _SubContentState extends State<SubContent> {
  List<Item> _items = new List();

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
    this.getData();
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
            ),
        itemCount: _items.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.add),
      ),
    );
  }
}
