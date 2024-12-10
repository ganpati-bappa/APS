import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';
part 'authentication_bloc_event.dart';
part 'authentication_bloc_state.dart';

class AuthenticationBlocBloc extends Bloc<AuthenticationBlocEvent, AuthenticationBlocState> {
  final UserRepository userRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthenticationBlocBloc({
    required UserRepository myUserRepository
  }) : userRepository = myUserRepository,  super(const AuthenticationBlocState.unknown()) {
    
    _userSubscription = userRepository.user.listen((authUser) {
      add(AuthenticationUserChanged(authUser));
    });
    
    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != null) {
        emit(AuthenticationBlocState.authenticated(event.user!));
      }
      else {
        emit(const AuthenticationBlocState.unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
