import 'package:erpclient/lookup/warehouses.dart';
import 'package:erpclient/model/warehouse.dart';
import 'package:flutter/material.dart';

import 'lookup-scoremodel.dart';

class WHouseLookupDialog {

 static showWarehouse(BuildContext context,ScopedLookup<Warehouse> scopeWHouse,List<Warehouse> warehouse) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _warehouseLookup(scopeWHouse,warehouse));
  }

  static Widget _warehouseLookup(ScopedLookup<Warehouse> scopeWHouse,List<Warehouse> warehouse) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: new WarehouseList(warehouse, scopeWHouse),
    );
  }
}