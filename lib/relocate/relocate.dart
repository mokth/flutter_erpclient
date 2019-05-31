import 'package:erpclient/lookup/lookup-scoremodel.dart';
import 'package:erpclient/lookup/whlookup.dart';
import 'package:erpclient/model/relocate.dart';
import 'package:erpclient/model/warehouse.dart';
import 'package:erpclient/repository/inventoryrepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class RelocateEntry extends StatefulWidget {
  final Relocate relocate;
  final String editmode;
  RelocateEntry(this.relocate, this.editmode, {Key key}) : super(key: key);

  _RelocateState createState() => _RelocateState();
}

class _RelocateState extends State<RelocateEntry> {
  final InventoryRepository repo = new InventoryRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _partController = TextEditingController();
  final _cartonController = TextEditingController();
  final _qtyController = TextEditingController();
  final _recqtyController = TextEditingController();
  final _frwhController = TextEditingController();
  final _towhController = TextEditingController();

  ScopedLookup<Warehouse> scopefrwh;
  ScopedLookup<Warehouse> scopetowh;
  String barcode = "";
  String _partname;
  List<Warehouse> _warehouses;
  bool _isWhfound = false;
  Relocate _relocate;
  int _noOfCarton;
  int _cartonPackSize;
  int _totalQty;
  bool _editMode;

  @override
  void initState() {
    super.initState();
    _editMode = widget.editmode == "EDIT";
    if (_editMode) {
      _relocate = widget.relocate;
      loadData();
    }
    scopefrwh = ScopedLookup(_frwhController);
    scopetowh = ScopedLookup(_towhController);
    onFrWhCodeChanged();
    onToWhCodeChanged();
    onQtyControllerChanged();
    repo.getWarehouse().then((resp) {
      setState(() {
        this._warehouses = resp;
        print(this._warehouses.length);
        _isWhfound = true;
      });
    }, onError: (e) {
      print(e.toString());
    });
  }

  loadData() {
    _partController.text = _relocate.icode;
    _cartonController.text = _relocate.packsize.toString() + " PCS";
    _cartonPackSize = _relocate.packsize;
    _frwhController.text = _relocate.fromwh;
    _towhController.text = _relocate.towh;
    _partname = _relocate.idesc;
    _qtyController.text = _relocate.qty.toString();
    _recqtyController.text = _relocate.stdqty.toString();
  }

  onFrWhCodeChanged() {
    _frwhController.addListener(() {
      if (_frwhController.text != "") Navigator.pop(context);
    });
  }

  onToWhCodeChanged() {
    _towhController.addListener(() {
      if (_towhController.text != "") Navigator.pop(context);
    });
  }

  onQtyControllerChanged() {
    _qtyController.addListener(() {
      if (_qtyController.text == "") {
        return false;
      }
      List<String> _temp = _cartonController.text.trim().split(' ');
      if (_temp.length <= 1) {
        return false;
      }
      _cartonPackSize = int.tryParse(_temp[0]);
      if (_cartonPackSize == null) {
        return false;
      }
      _noOfCarton = int.tryParse(_qtyController.text);
      if (_noOfCarton == null) {
        return false;
      }
      int ttlqty= (_noOfCarton * _cartonPackSize);
      _recqtyController.text= ttlqty.toString();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Relocate'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Center(child: scanner()),
                //Divider(),
                inputForm(),
                actionButtons(),
                Divider(),
                dispScanResult(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget scanner() {
    return new RawMaterialButton(
      onPressed: () {
        if (!_editMode) {
          scan();
        }
      },
      child: new Icon(
        Icons.scanner,
        color: (_editMode) ? Theme.of(context).disabledColor : Colors.blue,
        size: 50.0,
      ),
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.white,
      padding: const EdgeInsets.all(15.0),
    );
  }

  Widget inputForm() {
    return Container(
      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Column(
        children: <Widget>[
          TextFormField(
            enabled: false,
            decoration: InputDecoration(
                labelText: 'Part Number (PN)',
                filled: true,
                fillColor: Colors.white),
            controller: _partController,
          ),
          TextFormField(
            enabled: false,
            decoration: InputDecoration(
                labelText: 'Qty Per Carton (C)',
                filled: true,
                fillColor: Colors.white),
            controller: _cartonController,
          ),
          TextFormField(
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: false),
            decoration: InputDecoration(
                labelText: 'Number of Carton (D)',
                filled: true,
                fillColor: Colors.white),
            controller: _qtyController,
          ),
          TextFormField(
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: false),
            decoration: InputDecoration(
                labelText: 'Total Qty (PCS)',
                filled: true,
                fillColor: Colors.white),
            controller: _recqtyController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'From Warehouse (F)',
                      filled: true,
                      fillColor: Colors.white),
                  controller: _frwhController,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_isWhfound) {
                    showfrWhLookup();
                  }
                },
                child: Icon(
                  Icons.arrow_drop_down_circle,
                  size: 32,
                  color: _isWhfound
                      ? Theme.of(context).accentColor
                      : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'To Warehouse (G)',
                      filled: true,
                      fillColor: Colors.white),
                  controller: _towhController,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_isWhfound) {
                    showtoWhLookup();
                  }
                },
                child: Icon(
                  Icons.arrow_drop_down_circle,
                  size: 32,
                  color: _isWhfound
                      ? Theme.of(context).accentColor
                      : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Row(children: <Widget>[
        Expanded(
          child: RaisedButton(
            color: Color(0xff5DADE2),
            onPressed: saveRelocate,
            child: Text(
              'Save',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Text(' '),
        Expanded(
          child: RaisedButton(
            color: Colors.redAccent,
            onPressed: () {
              if (_editMode) {
                Navigator.pop(context);
              } else {
                resetForm();
              }
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ]),
    );
  }

  showfrWhLookup() {
    WHouseLookupDialog.showWarehouse(context, scopefrwh, _warehouses);
  }

  showtoWhLookup() {
    WHouseLookupDialog.showWarehouse(context, scopetowh, _warehouses);
  }

  Widget dispScanResult() {
    return Container(
      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Text(
        barcode,
        style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontSize: 18.0,
            fontFamily: 'OpenSans',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      print('print result');

      setState(() {
        this.barcode = barcode;
        print(this.barcode);
        extractBarcode(this.barcode);
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
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void extractBarcode(String result) {
    List<String> arr = result.split('\n');
    for (int i = 0; i < arr.length; i++) {
      List<String> text = arr[i].split(':');
      print(text[1].trim());
      switch (i) {
        case 0:
          _partname = text[1].trim();
          break;
        case 1:
          _partController.text = text[1].trim();
          break;
        case 6:
          _cartonController.text = text[1].trim();
          break;
        default:
          break;
      }
    }
    // arr.map((str){
    //     List<String> text = str.split(':');
    //     print(text[1]);
    // });
  }

  bool validateInputs() {
    if (_partController.text == "") {
      showSnackBar('Invalid Part number...');
      return false;
    }
    if (_cartonController.text == "") {
      showSnackBar('Qty Per Carton is require...');
      return false;
    }
    List<String> _temp = _cartonController.text.trim().split(' ');
    if (_temp.length <= 1) {
      showSnackBar('Invalid Qty Per Carton value...');
      return false;
    }
    _cartonPackSize = int.tryParse(_temp[0]);
    if (_cartonPackSize == null) {
      showSnackBar('Invalid Qty Per Carton value...');
      return false;
    }

    if (_qtyController.text == "") {
      showSnackBar('Number of Carton is require...');
      return false;
    }

    if (_recqtyController.text == "") {
      showSnackBar('Total Qty is invalid...');
      return false;
    }
    _totalQty = int.tryParse(_recqtyController.text);
    if (_totalQty == null) {
      showSnackBar('Total Qty is invalid...');
      return false;
    }

    _noOfCarton = int.tryParse(_qtyController.text);
    if (_noOfCarton == null) {
      showSnackBar('Invalid Number of Carton value...');
      return false;
    }
    if (_frwhController.text == "") {
      showSnackBar('From Warehouse is require...');
      return false;
    }
    if (_towhController.text == "") {
      showSnackBar('To Warehouse is require...');
      return false;
    }
    return true;
  }

  void saveRelocate() {
    if (!validateInputs()) return;
     
   
    _relocate = new Relocate(
      icode: _partController.text,
      idesc: _partname,
      packsize: _cartonPackSize,
      qty: _noOfCarton,
      stdqty:_totalQty,// (_noOfCarton * _cartonPackSize),
      fromwh: _frwhController.text,
      towh: _towhController.text,
      userid: '',
      trxdate: DateTime.now(),
      status: 'NEW',
      id: (_editMode) ? _relocate.id : 0,
    );
    if (_editMode) {
      saveEdit();
    } else {
      saveNew();
    }
  }

  saveNew() {
    repo.postRelocate(_relocate).then((resp) {
      showSnackBar(resp);
      resetForm();
    }, onError: (e) {
      showSnackBar("Error submitting data....");
    });
  }

  saveEdit() {
    repo.putRelocate(_relocate).then((resp) {
      showSnackBar(resp);
      resetForm();
      Navigator.pop(context);
    }, onError: (e) {
      showSnackBar("Error updating data....");
    });
  }

  void resetForm() {
    setState(() {
      _partController.text = "";
      _cartonController.text = "";
      _frwhController.text = "";
      _towhController.text = "";
      _qtyController.text = "";
      _recqtyController.text = "";
      barcode = "";
      _partname = "";
      _noOfCarton = null;
      _cartonPackSize = null;
      _relocate = null;
    });
  }

  showSnackBar(String msg) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}
