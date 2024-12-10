import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:developer';
part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  UserRepository get myUserRepository => _userRepository;

  SignInBloc({
    required UserRepository myUserRepository,
  }) : _userRepository = myUserRepository  , super(SignInInitial()) {

    on<SignInRequired>((event, emit) async{ 
      emit(SignInProgress());
      try {
        if (event.email.isEmpty || event.password.isEmpty) {
          throw Exception("Email and password field can not be empty");
        }
        await _userRepository.signIn(event.email, event.password);
        emit(SignInSuccess());
      } catch (ex) {
        log(ex.toString());
        emit(SignInFailure(message: ex.toString()));
      }
    });

    on<SignOutRequired>((event,emit) async {
      try {
        await _userRepository.logout();
      } catch (ex) {
        log(ex.toString());
      }
    });
  }
}
