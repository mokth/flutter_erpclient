import 'package:erpclient/model/qtybalance.dart';
import 'package:erpclient/repository/inventoryrepo.dart';
import 'package:erpclient/utilities/displayutil.dart';
import 'package:erpclient/utilities/util.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';


class StockBalance extends StatefulWidget {
  StockBalance({Key key}) : super(key: key);

  _StockBalanceState createState() => _StockBalanceState();
}

class _StockBalanceState extends State<StockBalance> {
  final InventoryRepository repo = new InventoryRepository();
  String barcode = "";
  String _partNumber = "";
  double _totalBal = 0.0;
  List<QtyBalance> _list = new List<QtyBalance>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Balance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: <Widget>[
              Center(child: scanner()),
              Expanded( child: dispScanResult()),
              Container(
                        width: MediaQuery.of(context).size.width,
                        height: 30.0,
                        decoration: BoxDecoration(
                            color:Colors.blueAccent),
                        padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: DisplayUtil.listItemText("",
                                    fontSize: 18.0)),
                            Expanded(
                                flex: 1,
                                child: DisplayUtil.listItemText("Total",
                                    fontSize: 18.0,color: Colors.white)),
                            Expanded(
                                flex: 1,
                                child: DisplayUtil.listItemText(
                                    _totalBal.toString(),
                                    fontSize: 24.0,
                                    textAlign: TextAlign.right,color: Colors.white)),
                          ],
                        ),
                      ), 
            ],
          ),
        ),
      ),
    );
  }

  Widget dispScanResult() {
    print('prepare list view');
    return ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return Container(
            decoration: BoxDecoration(
                color: (index % 2 == 0)
                    ? Colors.white
                    : Color.fromRGBO(0, 0, 255, 0.1)),
            padding: EdgeInsets.fromLTRB(20, 3, 20, 2),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: DisplayUtil.listItemText(_list[index].warehouse,
                            fontSize: 18.0)),
                    Expanded(
                        flex: 1,
                        child: DisplayUtil.listItemText(_list[index].lotno,
                            fontSize: 18.0)),
                    Expanded(
                        flex: 1,
                        child: DisplayUtil.listItemText(
                            _list[index].qty.toString(),
                            fontSize: 18.0,
                            textAlign: TextAlign.right)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: DisplayUtil.listItemText(
                            Utility.dateToString(_list[index].trxdate),
                            fontSize: 18.0)),
                    Expanded(
                        flex: 1,
                        child: DisplayUtil.listItemText(_list[index].status,
                            fontSize: 18.0)),
                    Expanded(
                        flex: 1,
                        child: DisplayUtil.listItemText(_list[index].uom,
                            fontSize: 14.0, textAlign: TextAlign.right)),
                  ],
                ),
                Divider(height: 10),
              ],
            ),
          );
        });
  }

  Widget scanner() {
    return RawMaterialButton(
      onPressed: () {
        scan();
      },
      child: new Icon(
        Icons.camera_alt,
        color: Colors.blue,
        size: 60.0,
      ),
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.white,
      padding: const EdgeInsets.all(15.0),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      var temp = await extractBarcode(barcode);
      double ttl = 0.0;
      temp.forEach((x) => ttl = ttl + x.qty);
      setState(() {
        this.barcode = barcode;
        this._totalBal = ttl;
        _list.addAll(temp);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode = '');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  Future<List<QtyBalance>> extractBarcode(String result) async {
    List<String> arr = result.split('\n');
    List<QtyBalance> temp = new List<QtyBalance>();
    _partNumber = "";
    for (int i = 0; i < arr.length; i++) {
      List<String> text = arr[i].split(':');
      print(text[1].trim());
      if (i == 7) {
        _partNumber = text[1].trim();
        break;
      }
    }

    if (_partNumber != "") {
      temp = await repo.getBalance(_partNumber);
    }
    return temp;
  }
}
