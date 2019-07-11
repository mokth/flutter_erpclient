import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:erpclient/pages/home.dart';
import 'package:erpclient/pages/loading_indicator.dart';
import 'package:erpclient/pages/login_page.dart';
import 'package:erpclient/pages/splash.dart';
import 'package:erpclient/repository/userreposity.dart';

import 'base/datahelper.dart';
import 'blog/auth/authbloc.dart';
import 'blog/auth/authevent.dart';
import 'blog/auth/authstate.dart';


// class SimpleBlocDelegate extends BlocDelegate {
//   @override
//   void onTransition(Transition transition) {
//     // print("transition : "+ transition.toString());
//   }
// }

void main() async {
  //BlocSupervisor().delegate = SimpleBlocDelegate();
  DataHelperSingleton datahlp = DataHelperSingleton.getInstance();
  await datahlp.iniSettingDB();  
  runApp(App(userRepository: UserRepository()));  
}

class App extends StatefulWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc authenticationBloc;
  UserRepository get userRepository => widget.userRepository;
  //final DataHelperSingleton _datahlp = DataHelperSingleton.getInstance();
  //bool _noSetting = false;

  @override
  void initState() {
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    //authenticationBloc.dispatch(AppStarted());    
    super.initState();
  }

  @override
  void dispose() {
    authenticationBloc.dispose();
   
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //this BLoC is global and unique for the whole application
    //this BLoC will be available from EVERYWHERE in the application 
    //since it will be an ancestor of almost all widgets.
    // use this to acces this Bloc from children
    //    BlocProvider.of<AuthenticationBloc>(context);
    return BlocProvider<AuthenticationBloc>(
      bloc: authenticationBloc,
      child: MaterialApp(
        debugShowCheckedModeBanner:false,
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            print("main loop ==> " + state.toString());
            if (state is AuthenticationUninitialized) {
              return SplashPage();//authenticationBloc);
            }
            if (state is AuthenticationAuthenticated) {
              if (!userRepository.isAuthenticated())
               return LoginPage(userRepository: userRepository);
              return HomePage();
            }

            if (state is AuthenticationUnauthenticated) {
              return LoginPage(userRepository: userRepository);
            }
            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }
          },
        ),
      ),
    );
  }
}
