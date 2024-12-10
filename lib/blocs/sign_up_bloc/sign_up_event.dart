part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequired extends SignUpEvent {
  final MyUser user;
  final String password;

  const SignUpRequired({
    required this.user,
    required this.password
  });
}


class SignUpWrongFields extends SignUpEvent {
  final String message;
  const SignUpWrongFields({required this.message});

  @override
  List<Object> get props => [message];
}