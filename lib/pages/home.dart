import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../work-order.dart/finished-good-list.dart';
import '../pages/Settings/setting.dart';
import '../relocate/barcode-scan.dart';
import '../relocate/receive-list.dart';
import '../blog/auth/authevent.dart';
import '../blog/auth/authbloc.dart';
import '../model/user.dart';
import '../base/customroute.dart';
import '../relocate/relocate-list.dart';

class HomePage extends StatefulWidget {
  //final AuthenticationBloc authenticationBloc;
  HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Connectivity _connectivity = Connectivity();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AuthenticationBloc authenticationBloc;
  //String _connectionStatus;
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
        //_connectionStatus = result.toString();
        //just to refresh the UI
        checkConnection().then((val) => setState(() {}));
      });
    });
    //get bloc from Parent
    authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
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
      key: _scaffoldKey,
      appBar: AppBar(
          title: Row(
        children: <Widget>[
          Expanded(child: Text('Mobile ERP')),
          Icon((!hasConnection) ? Icons.signal_wifi_off : Icons.wifi,
              color: (!hasConnection) ? Colors.redAccent : Colors.white)
        ],
      )),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_scaffoldKey.currentState.isDrawerOpen) {
                    _scaffoldKey.currentState.openDrawer();
                  }
                },
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
            ),
            FadeAnimatedTextKit(
                onTap: () {},
                text: ["WINCOM", "WINCOM SOLUTION", "WINCOM ERP SYSTEM"],
                textStyle: TextStyle(
                    fontSize: 24.0,
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                alignment: AlignmentDirectional.center // or Alignment.topLeft
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
                      new CustomRoute(
                          builder: (context) => new SettingPage(null)),
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
              menuItem('Issuing', () {
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
              Divider(),
              menuItem('Finished Good', () {
                Navigator.push(
                  context,
                  new CustomRoute(builder: (context) => new FinishedGoodList()),
                );
              }),
              Divider(),
              menuItem('Barcode Scan', () {
                Navigator.push(
                  context,
                  new CustomRoute(builder: (context) => new BarCodeScan()),
                );
              }),
              Divider(),
              // menuItem('Stock Balance', () {
              //   Navigator.push(
              //     context,
              //     new CustomRoute(builder: (context) => new StockBalance()),
              //   );
              // }),
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
