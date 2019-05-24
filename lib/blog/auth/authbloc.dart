import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:erpclient/repository/userreposity.dart';
import 'authevent.dart';
import 'authstate.dart';


class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {

    print("event " + event.toString());

    if (event is AppStarted) {
      yield AuthenticationUninitialized();
      return;
    }

     if (event is CheckSetting) {
      yield AuthenticationNoSetting();
       return;
    }

    if (event is CheckAuth) {
      print('event is CheckAuth');
      final String hasToken = await userRepository.getTokenOnly();
      userRepository.authToken ="";
     // print("hasToken "+hasToken.length.toString());
      if (hasToken!=""){
        if (userRepository.decodeToken(hasToken)==0){
            userRepository.authToken =hasToken;
            yield AuthenticationAuthenticated();  
             return;
        }else{
            await userRepository.deleteToken();
            yield AuthenticationUnauthenticated();    
             return;
        }
      }else {
        yield AuthenticationUnauthenticated();
         return;
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistToken(event.token);
      userRepository.authToken =event.token;
      yield AuthenticationAuthenticated();
       return;
    }

    if (event is LoggedOut) {
       userRepository.authToken ="";
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
       return;
    }
  }
}
