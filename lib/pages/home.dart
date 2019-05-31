import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:erpclient/pages/Settings/setting.dart';
import 'package:erpclient/relocate/receive-list.dart';
import 'package:flutter/material.dart';

import 'package:erpclient/base/connectionStatusSingleton.dart';
import 'package:erpclient/blog/auth/authevent.dart';
import 'package:erpclient/blog/auth/authbloc.dart';
import 'package:erpclient/model/user.dart';
import 'package:erpclient/base/customroute.dart';
import 'package:erpclient/relocate/relocate-list.dart';

class HomePage extends StatefulWidget {
  final AuthenticationBloc authenticationBloc;
  HomePage(this.authenticationBloc, {Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Connectivity _connectivity = Connectivity();
  AuthenticationBloc authenticationBloc;
  String _connectionStatus;
  StreamSubscription<ConnectivityResult> _connectionChangeStream;
  User _user;
  String _usrImgae;
  bool hasConnection = false;

  @override
  void initState() {
    super.initState();
    _connectionChangeStream =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
        //just to refresh the UI
        checkConnection().then((val) => setState(() {}));
      });
    });

    authenticationBloc = widget.authenticationBloc;
    _user = this.authenticationBloc.userRepository.getAuthUserInfo();
    if (_user != null) {
      _usrImgae = "admin/images/" +
          _user.compCode +
          "-" +
          _user.branchCode +
          "-" +
          _user.id +
          ".png";
    } else {
      _usrImgae = "admin/images/noimage.png";
    }
    _usrImgae = this.authenticationBloc.userRepository.erpURL + _usrImgae;
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      print(result.toString());
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }
    print('check connection....' + hasConnection.toString());
    return hasConnection;
  }

  // void connectionChanged(dynamic hasConnection) {
  //   setState(() {
  //     print(hasConnection.toString());
  //     isOffline = !hasConnection;
  //   });
  // }

  @override
  void dispose() {
    _connectionChangeStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: <Widget>[
          Expanded(child: Text('Moble ERP')),
          Icon((!hasConnection) ? Icons.signal_wifi_off : Icons.wifi,
              color: (!hasConnection) ? Colors.redAccent : Colors.white)
        ],
      )),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: new BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/erplogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height * 0.4 ,
              ),
            ),
            Center(
              child: Text('Wincom Solution',
                  style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
            Center(
              child: Text("(c) by 2019 WinCom Solution all right reserved.",
                  style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.normal,
                      fontSize: 15.0,
                      color: Colors.black)),
            ),
            Divider(),
          ],
        ),
      ),
      drawer: displayDrawer(context),
    );
  }

  Widget displayDrawer(BuildContext context) {
    return Drawer(
        child: Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(color: Colors.blue[50]),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Text(''),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      new CustomRoute(builder: (context) => new SettingPage(null)),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.settings,
                        size: 24,
                        color: Colors.blueAccent,
                      ),
                      Text(
                        'Setting',
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    authenticationBloc.dispatch(LoggedOut());
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.arrow_right,
                        size: 24,
                        color: Colors.redAccent,
                      ),
                      Text(
                        'Log out',
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
                Divider()
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              menuHeader(),
              Divider(),
              menuItem('Relocate', () {
                Navigator.push(
                  context,
                  new CustomRoute(builder: (context) => new RelocateList()),
                );
              }),
              Divider(),
              menuItem('Recieve', () {
                Navigator.push(
                  context,
                  new CustomRoute(builder: (context) => new ReceiveList()),
                );
              }),
            ],
          ),
        ),
      ],
    ));
  }

  Widget menuHeader() {
    return Container(
        // height: 200,
        decoration: BoxDecoration(color: Colors.blueAccent),
        padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(_usrImgae),
              backgroundColor: Colors.transparent,
            ),
            displayText(_user == null ? "" : _user.name, 18, FontWeight.w700,
                italy: true),
          ],
        ));
  }

  Widget menuItem(String actionText, Function action) {
    return InkWell(
      child: Container(
        height: 35.00,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.arrow_right,
              size: 24,
              color: Colors.blueAccent,
            ),
            Text(
              actionText,
              style: TextStyle(fontSize: 20.0, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
      onTap: () => action(),
    );
  }

  Widget displayText(String text, double fontSize, FontWeight fontWeight,
      {bool italy: false, bool startRight: true}) {
    return Text(
      text,
      textAlign: TextAlign.end,
      style: TextStyle(
          fontFamily: 'OpenSans',
          fontWeight: fontWeight,
          fontStyle: italy ? FontStyle.italic : FontStyle.normal,
          fontSize: fontSize,
          color: Colors.white),
    );
  }
}
