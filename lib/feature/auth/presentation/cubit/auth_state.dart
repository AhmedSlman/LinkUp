import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/feature/auth/data/user_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class SignUpLoadingState extends AuthState {}

class SignUpSuccessState extends AuthState {
  final User user;
  final UserModel userData;
  SignUpSuccessState({required this.user, required this.userData});
}

class SignUpFailuerState extends AuthState {
  final String errMessage;
  SignUpFailuerState({required this.errMessage});
}

class SignInLoadingState extends AuthState {}

class SignInSuccessState extends AuthState {
  final User user;
  final UserModel userData;
  SignInSuccessState({required this.user, required this.userData});
}

class SignInFailuerState extends AuthState {
  final String errMessage;
  SignInFailuerState({required this.errMessage});
}
