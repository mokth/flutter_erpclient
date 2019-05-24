import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

// LoginInitial is the initial state of the LoginForm.
// LoginLoading is the state of the LoginForm when we are validating credentials
// LoginFailure is the state of the LoginForm when a login attempt has failed.

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginInitial extends LoginState {
  @override
  String toString() => 'LoginInitial';
}

class LoginLoading extends LoginState {
  @override
  String toString() => 'LoginLoading';
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'LoginFailure { error: $error }';
}