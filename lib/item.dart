import 'package:flutter/material.dart';

class Item {
  Item({this.key, this.name, this.description});
  String key;
  String name;
  String description;

  @override
  String toString() {
    // ignore: unnecessary_brace_in_string_interps
    return '${key}: ${name}, ${description}';
  }
}

class ItemItem extends StatelessWidget {
  ItemItem({this.item, this.onEdit, this.onDelete});
  final Item item;
  final onEdit;
  final onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name,
                style: TextStyle(fontSize: 24.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                child: Text(
                  item.description != null ? item.description : '',
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: RaisedButton(
                      onPressed: onEdit,
                      child: const Text('Edit'),
                    ),
                  ),
                  RaisedButton(
                    onPressed: onDelete,
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
