import 'package:equatable/equatable.dart';
import 'package:tuanhoai01/features/auth/data/models/auth_response.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  LoginSuccess(this.auth);

  final AuthResponse auth;

  @override
  List<Object?> get props => [auth];
}

class LoginFailure extends LoginState {
  LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
