import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:erpclient/blog/auth/authevent.dart';
import 'package:erpclient/blog/auth/authbloc.dart';
import 'package:erpclient/repository/userreposity.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({ @required this.userRepository,
              @required this.authenticationBloc,
            })  : assert(userRepository != null),
                  assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  
  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
   
    if (event is LoginButtonPressed) {
      yield LoginLoading();
       
       try {
         final token = await userRepository.authenticate(
           username: event.username,
           password: event.password,
         );
        if (token!=""){
           authenticationBloc.dispatch(LoggedIn(token: token));
           yield LoginInitial();
        }else{
          yield LoginFailure(error: "Invalid user id / password");
        }
        
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }

}