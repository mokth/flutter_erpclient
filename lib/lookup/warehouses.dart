import 'package:erpclient/model/warehouse.dart';
import 'package:flutter/material.dart';

import 'lookup-scoremodel.dart';

class WarehouseList extends StatelessWidget {
  final List<Warehouse> warehouse;
  final ScopedLookup<Warehouse> model;
  WarehouseList(this.warehouse, this.model, {Key key})
      : assert(warehouse != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse Listing'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: ListView.builder(
            itemCount: warehouse.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new GestureDetector(
                onTap: () {
                  model.setResult(warehouse[index], warehouse[index].code);
                },
                child: ListTile(
                  contentPadding: EdgeInsets.all(2),
                  leading: Icon(Icons.store, color: Colors.blueGrey),
                  title: Text(warehouse[index].code),
                ),
              );
            }),
      ),
    );
  }
}
