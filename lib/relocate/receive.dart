import 'package:erpclient/model/reject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:erpclient/utilities/button-util.dart';
import 'package:erpclient/utilities/snackbarutil.dart';
import 'package:erpclient/utilities/textstyle-util.dart';
import 'package:erpclient/repository/inventoryrepo.dart';

class ReceiveEmtry extends StatefulWidget {
  ReceiveEmtry({Key key}) : super(key: key);

  _RelocateState createState() => _RelocateState();
}

class _RelocateState extends State<ReceiveEmtry> {
  final InventoryRepository repo = new InventoryRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _partController = TextEditingController();
  final _refController = TextEditingController();
  final _cartonController = TextEditingController();
  final _qtyController = TextEditingController();
  final _frwhController = TextEditingController();
  final _towhController = TextEditingController();
  final _rejectController = TextEditingController();

  String barcode = "";
  String _docId;
  bool isPosting;

  @override
  void initState() {
    super.initState();
    isPosting = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Receive Item'),
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
        scan();
      },
      child: new Icon(
        Icons.camera_alt,
        color: Colors.blue,
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
            decoration: TextStyleUtil.getFormFieldInputDecoration('Ref Number'),
            controller: _refController,
          ),
          TextFormField(
            enabled: false,
            decoration:
                TextStyleUtil.getFormFieldInputDecoration('Part Number'),
            controller: _partController,
          ),
          TextFormField(
            enabled: false,
            decoration:
                TextStyleUtil.getFormFieldInputDecoration('Receiv Qty (Pcs/Kg/M/Set)'),
            controller: _qtyController,
          ),
          TextFormField(
            enabled: false,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: false),
            decoration:
                TextStyleUtil.getFormFieldInputDecoration('Number of Carton'),
            controller: _cartonController,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextFormField(
                  enabled: false,
                  decoration: TextStyleUtil.getFormFieldInputDecoration(
                      'From Warehouse'),
                  controller: _frwhController,
                ),
              ),
              Expanded(
                flex: 1,
                child: TextFormField(
                  enabled: false,
                  decoration:
                      TextStyleUtil.getFormFieldInputDecoration('To Warehouse'),
                  controller: _towhController,
                ),
              ),
            ],
          ),
          TextFormField(
            enabled: true,           
            decoration:
                TextStyleUtil.getFormFieldInputDecoration('Reject Reason'),
            controller: _rejectController,
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
              onReceiveHandler,
              "Receive",
              (isPosting)
                  ? Theme.of(context).disabledColor
                  : Color(0xff5DADE2)),
        ),
        Text(' '),
        Expanded(
          child: ButtonUtil.getRaiseButton(onCancelHandler, "Reject",
              (isPosting) ? Theme.of(context).disabledColor : Colors.redAccent),
        ),
      ]),
    );
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
          _docId = text[1].trim();
          break;
        case 1:
          _refController.text = text[1].trim();
          break;
        case 2:
          _partController.text = text[1].trim();
          break;
        case 3:
          _frwhController.text = text[1].trim();
          break;
        case 4:
          _towhController.text = text[1].trim();
          break;
        case 5:
          _cartonController.text = text[1].trim();
          break;
        case 6:
          // _cartonPackSize =  int.tryParse(text[1].trim());
          break;
        case 7:
          _qtyController.text = text[1].trim();
          break;
        default:
          break;
      }
    }
    arr.map((str) {
      List<String> text = str.split(':');
      print(text[1]);
    });
  }
 
  onReceiveHandler() {
    if (!isPosting) {
      saveRelocate();
    }
  }

  onCancelHandler() {
    if (!isPosting) {
      //resetForm();
      saveReject();
    }
  }

 bool validateReject() {
    if ( _rejectController.text == "") {
      SnackBarUtil.showSnackBar('Reject reason is mandatory...', _scaffoldKey);
      return false;
    }
    return true;
 }

  bool validateInputs() {
    if (_partController.text == "") {
      SnackBarUtil.showSnackBar('Invalid Part number...', _scaffoldKey);
      return false;
    }

    if (_qtyController.text == "") {
      SnackBarUtil.showSnackBar('Invalid qty...', _scaffoldKey);
      return false;
    }

    if (_frwhController.text == "") {
      SnackBarUtil.showSnackBar('From Warehouse is require...', _scaffoldKey);
      return false;
    }
    if (_towhController.text == "") {
      SnackBarUtil.showSnackBar('To Warehouse is require...', _scaffoldKey);
      return false;
    }
    return true;
  }

  void saveRelocate() {
    if (!validateInputs()) return;
    setSaveButtonState(true);
    postReceive(_docId).then((msg) {
      SnackBarUtil.showSnackBar(msg, _scaffoldKey);
      resetForm();
      setSaveButtonState(false);
    }, onError: (e) {
      SnackBarUtil.showSnackBar("Error receiving...", _scaffoldKey);
      setSaveButtonState(false);
    });
  }

  void saveReject() {
    if (!validateReject()) return;
    setSaveButtonState(true);
    postReject(_docId,_rejectController.text).then((msg) {
      SnackBarUtil.showSnackBar(msg, _scaffoldKey);
      resetForm();
      setSaveButtonState(false);
    }, onError: (e) {
      SnackBarUtil.showSnackBar("Error rejecting...", _scaffoldKey);
      setSaveButtonState(false);
    });
  }

  setSaveButtonState(bool posting) {
    setState(() {
      isPosting = posting;
    });
  }

  Future<String> postReceive(String id) async {
    var msg = "";
     try{
       msg = await repo.postReceive(id);
     }catch(e){
       msg=e.toString();
     }
    return msg;
  }

  Future<String> postReject(String id,String reason) async {
    var msg = "";
     try{
       Reject reject = new Reject(id: int.parse(id),reason:reason);
       msg = await repo.postReject(reject);
     }catch(e){
       msg=e.toString();
     }
    return msg;
  }

  void resetForm() {
    setState(() {
      _partController.text = "";
      _cartonController.text = "";
      _frwhController.text = "";
      _towhController.text = "";
      _qtyController.text = "";
      _refController.text = "";
      _rejectController.text ="";
      barcode = "";
      _docId = "";
    });
  }
}
