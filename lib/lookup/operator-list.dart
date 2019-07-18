import 'package:flutter/material.dart';

import '../model/prd-operator.dart';
import 'lookup-scoremodel.dart';

class OperatorList extends StatelessWidget {
  final List<PrdOperator> prdOperator;
  final ScopedLookup<PrdOperator> model;
  OperatorList(this.prdOperator, this.model, {Key key})
      : assert(prdOperator != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operator Listing'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: ListView.builder(
            itemCount: prdOperator.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new GestureDetector(
                onTap: () {
                  model.setResult(prdOperator[index], prdOperator[index].code);
                },
                child: ListTile(
                  contentPadding: EdgeInsets.all(2),
                  leading: Icon(Icons.store, color: Colors.blueGrey),
                  title: Text(prdOperator[index].code),
                ),
              );
            }),
      ),
    );
  }
}
