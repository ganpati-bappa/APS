part of 'authentication_bloc_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, unknown }

class AuthenticationBlocState extends Equatable {
  
  final AuthenticationStatus status;
  final User? user;

  const AuthenticationBlocState._({
    this.status = AuthenticationStatus.unauthenticated,
    this.user,
  });
  
  @override
  List<Object?> get props => [status, user];

  const AuthenticationBlocState.unknown() : this._();
  const AuthenticationBlocState.authenticated(User user) : this._(status: AuthenticationStatus.authenticated, user: user);
  const AuthenticationBlocState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);
}