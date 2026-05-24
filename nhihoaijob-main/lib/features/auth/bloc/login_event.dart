import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  LoginSubmitted(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
