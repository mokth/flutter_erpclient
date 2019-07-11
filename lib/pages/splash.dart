import 'package:flutter/material.dart';

import 'package:erpclient/blog/auth/authbloc.dart';
import 'package:erpclient/blog/auth/authevent.dart';
import 'package:erpclient/pages/showup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  //final AuthenticationBloc bloc;
  SplashPage();//this.bloc);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  AuthenticationBloc bloc; 
  @override
  void initState() {
    super.initState();
    //get bloc from Parent
    bloc = BlocProvider.of<AuthenticationBloc>(context); 
    controller = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    controller.forward();

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        bloc.dispatch(CheckAuth());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: new BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              ShowUp(
                child: Center(
                  child: Text(
                    "Wincom Solution",
                    style:
                        TextStyle(fontSize: 40.0, 
                        color: Theme.of(context).canvasColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                delay: 500,
              ),
                ShowUp(
                child:
                Container(
                  margin: EdgeInsets.only(top:60.0),
                 child:              
                 Center(
                  child: Text(
                    "No More Painful Intergration",
                    style:
                        TextStyle(fontSize: 20.0,
                          color: Colors.white70,
                         fontWeight: FontWeight.w700),
                  ),
                ),),
                delay: 1000,
              ),
            ],
          )),
    );
  }
}
