import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class BarCodeScan extends StatefulWidget {
  BarCodeScan({Key key}) : super(key: key);

  _BarCodeScanState createState() => _BarCodeScanState();
}

class _BarCodeScanState extends State<BarCodeScan> {
  String barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scan'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(flex: 1, child: Center(child: scanner())),
              barcode == ""
                  ? Text("")
                  : Expanded(flex: 3, child: dispScanResult()),
            ],
          ),
        ),
      ),
    );
  }

  Widget dispScanResult() {
    return Container(
      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Text(
        barcode,
        style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontSize: 16.0,
            fontFamily: 'OpenSans',
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget scanner() {
    return RawMaterialButton(
      onPressed: () {
        scan();
      },
      child: new Icon(
        Icons.camera_alt,
        color: Colors.blue,
        size: 100.0,
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
      print('print result');

      setState(() {
        this.barcode = barcode;
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
}
