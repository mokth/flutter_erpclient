import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../lookup/lookup-scoremodel.dart';
import '../lookup/whlookup.dart';
import '../model/warehouse.dart';
import '../model/prd-operator.dart';
import '../repository/inventoryrepo.dart';
import '../utilities/button-util.dart';
import '../utilities/snackbarutil.dart';
import '../utilities/textstyle-util.dart';
import '../base/datahelper.dart';
import '../lookup/oprLookup.dart';
import '../model/prschmasfg.dart';
import '../model/setting.dart';

class FinishedGood extends StatefulWidget {
 final PrSchMasFG fnGood;
 final String editmode;
  FinishedGood(this.fnGood,this.editmode,{Key key}) : super(key: key);

  _FinishGoodState createState() => _FinishGoodState();
}

class _FinishGoodState extends State<FinishedGood>
    with SingleTickerProviderStateMixin {
  final InventoryRepository repo = new InventoryRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _workorderController = TextEditingController();
  final _prodCodeController = TextEditingController();
  final _prodDescController = TextEditingController();
  final _qtyController = TextEditingController();
  final _scrapController = TextEditingController();
  final _rejectController = TextEditingController();
  final _operatorController = TextEditingController();
  final _uomController = TextEditingController();
  final _frwhController = TextEditingController();
  final _towhController = TextEditingController();
  final _lotNoController = TextEditingController();

  final DataHelperSingleton _datahlp = DataHelperSingleton.getInstance();
  ScopedLookup<Warehouse> scopefrwh;
  ScopedLookup<Warehouse> scopetowh;
  ScopedLookup<PrdOperator> scopeOpr;

  String barcode = "";
  List<Warehouse> _warehouses;
  List<PrdOperator> _operators;
  PrSchMasFG _prSchMas;
  List<Setting> _setts;
  Setting _setting;
  String defWarehouse = "";
  int _relNo=1;

  bool _isWhfound = false;
  bool _isOprfound = false;  
  bool _editMode = false;
  bool _dontPop = false;
  PrSchMasFG _fnGood;

  @override
  void initState() {
    super.initState();
    _editMode = widget.editmode == "EDIT";
    if (_editMode) {
      _fnGood = widget.fnGood;
      loadData();
    }

    scopefrwh = ScopedLookup(_frwhController);
    scopetowh = ScopedLookup(_towhController);
    scopeOpr = ScopedLookup(_operatorController);
    

    onFrWhCodeChanged();
    onToWhCodeChanged();
    onOperatorChanged();
    repo.getWarehouse().then((resp) {
      setState(() {
        this._warehouses = resp;
        print(this._warehouses.length);
        _isWhfound = true;
      });
    }, onError: (e) {
      print(e.toString());
    });
    repo.getOperator().then((resp) {
      setState(() {
        this._operators = resp;
        _isOprfound = true;
      });
    }, onError: (e) {
      print(e.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadData() {
    _workorderController.text = _fnGood.scheCode+"/"+_fnGood.relNo.toString();
    _prodCodeController.text = _fnGood.icode;
    _prodDescController.text = _fnGood.idesc;
    _frwhController.text = _fnGood.frWH;
    _towhController.text = _fnGood.toWH;
    _lotNoController.text = _fnGood.fgLotNo;
    _uomController.text = _fnGood.stdUOM;
    _qtyController.text = _fnGood.fgQty.toString();
    _scrapController.text = (_fnGood.scrap==null)?"":_fnGood.scrap.toString();
    _rejectController.text = (_fnGood.reject==null)?"":_fnGood.reject.toString();
  }

  onFrWhCodeChanged() {
    _frwhController.addListener(() {
      print(!_dontPop);
      if (_frwhController.text != "") {
        if (!_dontPop) Navigator.pop(context);
      } else
        _dontPop = false;
    });
  }

  onToWhCodeChanged() {
    _towhController.addListener(() {
      if (_towhController.text != "") Navigator.pop(context);
    });
  }

  onOperatorChanged() {
    _operatorController.addListener(() {
      if (_operatorController.text != "") Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('FINISHED GOODS'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(5.0),
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
    return RawMaterialButton(
      onPressed: () {
        if (!_editMode) {
          scan();
        }
      },
      child: new Icon(
        Icons.camera_alt,
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
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Flexible(
              child: TextFormField(
                enabled: false,
                decoration:
                    TextStyleUtil.getFormFieldInputDecoration('Work Order'),
                controller: _workorderController,
              ),
            ),
            Flexible(
              child: TextFormField(
                enabled: false,
                decoration:
                    TextStyleUtil.getFormFieldInputDecoration('Product Code'),
                controller: _prodCodeController,
              ),
            ),
          ]),
          TextFormField(
            enabled: false,
            decoration: TextStyleUtil.getFormFieldInputDecoration(
                'Product Description'),
            controller: _prodDescController,
          ),
          Row(children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                decoration:
                    TextStyleUtil.getFormFieldInputDecoration('Good Qty'),
                controller: _qtyController,
              ),
            ),
            Flexible(
              child: TextFormField(
                enabled: false,
                decoration:
                    TextStyleUtil.getFormFieldInputDecoration('STD UOM'),
                controller: _uomController,
              ),
            ),
          ]),
          Row(children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                decoration:
                    TextStyleUtil.getFormFieldInputDecoration('Reject Qty'),
                controller: _rejectController,
              ),
            ),
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                decoration:
                    TextStyleUtil.getFormFieldInputDecoration('Scrap Qty'),
                controller: _scrapController,
              ),
            ),
          ]),
          Row(
            children: <Widget>[
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        enabled: false,
                        decoration: TextStyleUtil.getFormFieldInputDecoration(
                            'Operator'),
                        controller: _operatorController,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isOprfound) {
                          showOperatorLookup();
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
              ),
              Flexible(
                child: TextFormField(
                  enabled: true,
                  decoration:
                      TextStyleUtil.getFormFieldInputDecoration('FG Lot No.'),
                  controller: _lotNoController,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        enabled: false,
                        decoration: TextStyleUtil.getFormFieldInputDecoration(
                            'From WH'),
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
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        enabled: false,
                        decoration:
                            TextStyleUtil.getFormFieldInputDecoration('To WH'),
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
          child: ButtonUtil.getRaiseButton(
              saveRelocate, "Save",Theme.of(context).primaryColor ),
        ),
        Text(' '),
        Expanded(
          child: ButtonUtil.getRaiseButton(
              onCancelHandler, "Cancel", Colors.redAccent),
        ),
      ]),
    );
  }

  onCancelHandler() {
    if (_editMode) {
      Navigator.pop(context);
    } else {
      resetForm();
    }
  }

  showfrWhLookup() {
    _dontPop = false;
    WHouseLookupDialog.showWarehouse(context, scopefrwh, _warehouses);
  }

  showtoWhLookup() {
    WHouseLookupDialog.showWarehouse(context, scopetowh, _warehouses);
  }

  showOperatorLookup() {
    OperatorLookupDialog.showPrdOperator(context, scopeOpr, _operators);
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
        if (i==0){
          _workorderController.text = arr[i];
        }
        if (i==1){
          _relNo = int.tryParse(arr[i]);
        }
        if (i==2){
          _prodCodeController.text =arr[i];
        }
        if (i==3){
          _prodDescController.text =arr[i];
        } 
        if (i==4){
          _uomController.text =arr[i];
        }
    }
  }

  bool validateInputs() {
    if (_workorderController.text == "") {
      SnackBarUtil.showSnackBar('Invalid Work Order...', _scaffoldKey);
      return false;
    }

    if (_prodCodeController.text == "") {
      SnackBarUtil.showSnackBar('Invalid Prod Code...', _scaffoldKey);
      return false;
    }

    if (_qtyController.text == "") {
      SnackBarUtil.showSnackBar('Invalid qty...', _scaffoldKey);
      return false;
    }

    double keyqty = double.tryParse(_qtyController.text);
    if (keyqty <= 0) {
      SnackBarUtil.showSnackBar('Invalid qty...', _scaffoldKey);
      return false;
    }

    // if (_frwhController.text == "") {
    //   SnackBarUtil.showSnackBar('From Warehouse is require...', _scaffoldKey);
    //   return false;
    // }

    if (_towhController.text == "") {
      SnackBarUtil.showSnackBar('To Warehouse is require...', _scaffoldKey);
      return false;
    }

    return true;
  }

  void saveRelocate() {
    if (!validateInputs()) return;

    double qty = double.tryParse(_qtyController.text);
    double scrap = double.tryParse(_scrapController.text);
    double reject = double.tryParse(_rejectController.text);

    _prSchMas = new PrSchMasFG(
      uid: (_editMode) ? _fnGood.uid : 0,
      scheCode: (_editMode) ?_fnGood.scheCode:_workorderController.text,
      relNo:  (_editMode) ?_fnGood.relNo:_relNo,
      icode:  (_editMode) ?_fnGood.icode:_prodCodeController.text,
      idesc:  (_editMode) ?_fnGood.idesc:_prodDescController.text,
      stdUOM: (_editMode) ?_fnGood.stdUOM: _uomController.text,
      trxDate: (_editMode) ?_fnGood.trxDate:DateTime.now(),
      frWH: (_frwhController.text == null) ?"": _frwhController.text,
      toWH: (_towhController.text==null)?"":_towhController.text,
      prdOperator: (_operatorController.text==null)?"":_operatorController.text,
      fgLotNo: (_lotNoController.text==null)?"":_lotNoController.text,
      userid: '',
      status: 'NEW',      
      fgQty: qty,
      reject: (reject == null) ? 0 : reject,
      scrap: (scrap == null) ? 0 : scrap,      
    );
    if (_editMode) {
      saveEdit();
    } else {
      saveNew();
    }
  }

  saveNew() {
    repo.postPrSchMas(_prSchMas).then((resp) {
      SnackBarUtil.showSnackBar(resp, _scaffoldKey);
      resetForm();
    }, onError: (e) {
      SnackBarUtil.showSnackBar("Error submitting data....", _scaffoldKey);
    });
  }

  saveEdit() {
    repo.putFinisedGood(_prSchMas).then((resp) {
      SnackBarUtil.showSnackBar(resp, _scaffoldKey);
      resetForm();
      Navigator.pop(context);
    }, onError: (e) {
      SnackBarUtil.showSnackBar("Error updating data....", _scaffoldKey);
    });
  }

  void resetForm() {
    setState(() {
      _workorderController.text = "";
      _prodCodeController.text = "";
      _prodDescController.text = "";
      _frwhController.text = "";
      _towhController.text = "";
      _qtyController.text = "";
      _rejectController.text = "";
      _scrapController.text = "";
      _uomController.text = "";
      _operatorController.text = "";
      _lotNoController.text="";
      _dontPop = true;
      barcode = "";
      _prSchMas = null;
    });
  }
}
