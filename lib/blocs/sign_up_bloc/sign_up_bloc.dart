import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository userRepository;
  SignUpBloc({
    required UserRepository myUserRepostiory
  }) : userRepository = myUserRepostiory, super(SignUpInitial()) {
    
    on<SignUpRequired>((event, emit) async {
      emit(SignUpProcess());
      try {
        MyUser user = await userRepository.signUp(event.user, event.password);
        await userRepository.setUserData(user);
        emit(SignUpSuccess());
      } catch(ex) {
        emit(SignUpFailure(message: ex.toString()));
      }
    });

    on<SignUpWrongFields>((event, emit) {
      emit(SignUpProcess());
      emit(SignUpFailure(message: event.message));
    });
    
  }
}
