part of 'sign_in_bloc.dart';

sealed class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

final class SignInInitial extends SignInState {}
final class SignInSuccess extends SignInState {}

final class SignInFailure extends SignInState {
  final String message;
  const SignInFailure({
    required this.message
  });
}

final class SignInProgress extends SignInState {}

final class ForgotPasswordLoading extends SignInState {}

final class ForgotPasswordEmailSent extends SignInState {}
