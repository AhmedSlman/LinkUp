import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class SignUpLoadingState extends AuthState {}

class SignUpSuccessState extends AuthState {}

class SignUpFailuerState extends AuthState {
  final String errMessage;
  SignUpFailuerState({required this.errMessage});
}

class SignInLoadingState extends AuthState {}

class SignInSuccessState extends AuthState {
  final User user;
  SignInSuccessState({required this.user});
}

class SignInFailuerState extends AuthState {
  final String errMessage;
  SignInFailuerState({required this.errMessage});
}
