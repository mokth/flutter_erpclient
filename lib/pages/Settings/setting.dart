import '../../base/datahelper.dart';
import '../../blog/auth/authbloc.dart';
import '../../blog/auth/authevent.dart';
import '../../model/setting.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  final AuthenticationBloc authenticationBloc;
  SettingPage(this.authenticationBloc,{Key key}) : super(key: key);

  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _urlController = TextEditingController();
  final _whController = TextEditingController();
  final DataHelperSingleton _datahlp = DataHelperSingleton.getInstance();
  AuthenticationBloc authenticationBloc;
  List<Setting> _setts;
  Setting _setting;

  @override
  void initState() {
    super.initState();
    authenticationBloc =widget.authenticationBloc;
    _datahlp.getSettings().then((val) {
      _setts =val;
      if (_setts.length>0){
         _setting = _setts[0]; 
         print("found seting "+_setting.url);
         _urlController.text = _setting.url;
         _whController.text = _setting.defwh;
      }else {
        //test only        
        //_urlController.text= "http://localhost:50383/api/";

        //_urlController.text="http://10.1.8.15/erpapi_prod/api/";
        _urlController.text="http://wincom2cloud.com/mytechapi/api/";
        print("NOT found seting ");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
            child: Column(
          children: <Widget>[
            TextFormField(
              enabled: true,
              decoration: InputDecoration(
                  labelText: 'ERP Client URL',
                  filled: true,
                  fillColor: Colors.white),
              controller: _urlController,
            ),
            Divider(),
             TextFormField(
              enabled: true,
              decoration: InputDecoration(
                  labelText: 'DEFAULT WAREHOUSE',
                  filled: true,
                  fillColor: Colors.white),
              controller: _whController,
            ),
            Divider(),
            actionButtons(),
          ],
        )),
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
            onPressed: saveSetting,
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
                Navigator.pop(context);
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

  saveSetting() async {
    bool isAddMode =false;
    String msg ="";
    if (_setting==null){
       _setting = new Setting();
       isAddMode =true;
    }
    try{
     _setting.url = _urlController.text.trim().toLowerCase();
     _setting.defwh = _whController.text.trim().toUpperCase();
     if(isAddMode){
       _setting.id=0;
      await _datahlp.insertSetting(_setting);
      msg ="Setting added.";
      if(this.authenticationBloc!=null){
        this.authenticationBloc.dispatch(CheckAuth());
      }
     }else {
      await  _datahlp.updateSetting(_setting);
      msg ="Setting updated.";
     }
    }catch (e){
        msg ="Error updating setting...";
    }
    finally{
      showSnackBar(msg);
    }
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
