import 'package:erpclient/utilities/snackbarutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:erpclient/repository/inventoryrepo.dart';
import 'package:erpclient/model/relocate.dart';

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
  
  String barcode = "";
  String _docId;  
  bool isPosting;
  // Relocate _relocate;
   int _noOfCarton;
   int _cartonPackSize;
  

  @override
  void initState() {
    super.initState();  
    isPosting =false;
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
      onPressed:(){ 
            scan();          
        },
      child: new Icon(
        Icons.scanner,
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
            decoration: InputDecoration(
                labelText: 'Ref Number',
                filled: true,
                fillColor: Colors.white),
            controller: _refController,
          ),
           TextFormField(
            enabled: false,
            decoration: InputDecoration(
                labelText: 'Part Number',
                filled: true,
                fillColor: Colors.white),
            controller: _partController,
          ),
          TextFormField(
            enabled: false,
            decoration: InputDecoration(
                labelText: 'Receiv Qty PCS',
                filled: true,
                fillColor: Colors.white),
            controller: _qtyController,
          ),
          TextFormField(
            keyboardType: TextInputType.numberWithOptions(signed: false,decimal: false),
            decoration: InputDecoration(
                labelText: 'Number of Carton',
                filled: true,
                fillColor: Colors.white),
            controller: _cartonController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'From Warehouse',
                      filled: true,
                      fillColor: Colors.white),
                  controller: _frwhController,
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
                      labelText: 'To Warehouse',
                      filled: true,
                      fillColor: Colors.white),
                  controller: _towhController,
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
            color: (isPosting)?Theme.of(context).disabledColor:Color(0xff5DADE2),
            onPressed: (){
               if (!isPosting){
                   saveRelocate();
               }
            },
            child: Text(
              'Receive',
              style: TextStyle(
                  color:Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Text(' '),
        Expanded(
          child: RaisedButton(
            color: (isPosting)?Theme.of(context).disabledColor:Colors.redAccent,
            onPressed: (){
               if (!isPosting){
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
            _cartonPackSize =  int.tryParse(text[1].trim());
          break;
        case 7:
            _qtyController.text =  text[1].trim();
          break;
        default:
          break;
      }
    }
    arr.map((str){
        List<String> text = str.split(':');
        print(text[1]);
    });
  }

  bool validateInputs(){
    if (_partController.text==""){
      SnackBarUtil.showSnackBar('Invalid Part number...',_scaffoldKey);
      return false;
    }
       
    if (_qtyController.text==""){
      SnackBarUtil.showSnackBar('Invalid qty...',_scaffoldKey);
      return false;
    }
       
    if (_frwhController.text==""){
       SnackBarUtil.showSnackBar('From Warehouse is require...',_scaffoldKey);
      return false;
    }
    if (_towhController.text==""){
      SnackBarUtil.showSnackBar('To Warehouse is require...',_scaffoldKey);
      return false;
    }
    return true;
  }
  
  void saveRelocate(){
    if (!validateInputs())
      return;
     setSaveButtonState(true);    
     testReceive(_docId).then((msg) {
       SnackBarUtil.showSnackBar(msg,_scaffoldKey);
       resetForm(); 
       setSaveButtonState(false);
     },
     onError: (e){
        SnackBarUtil.showSnackBar("Error receiving...",_scaffoldKey);
        setSaveButtonState(false);
     });     
   
  }

  setSaveButtonState(bool posting){
    setState(() {
        isPosting = posting;
    });
  }

   Future<String> testReceive(String id) async{
     var msg =await repo.postReceive(id);
     return msg;
  }

  
  void resetForm(){
    setState(() {
        _partController.text="";
        _cartonController.text ="";
        _frwhController.text ="";
        _towhController.text ="";
        _qtyController.text ="";
        _refController.text ="";
        barcode ="";
        _docId ="";
        //_partname="";
        _noOfCarton=null;
        _cartonPackSize = null;
       // _relocate = null;
    });
  }
 
}
