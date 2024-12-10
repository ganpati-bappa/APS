import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'my_user_bloc_event.dart';
part 'my_user_bloc_state.dart';

class MyUserBlocBloc extends Bloc<MyUserBlocEvent, MyUserBlocState> {
  final UserRepository _userRepository;

  MyUserBlocBloc({
    required UserRepository myUserRepository
  }) : _userRepository = myUserRepository, super(const MyUserBlocState.loading()) {

    on<GetMyUser>((event, emit) async {
      try {
        MyUser user = await _userRepository.getUserData(event.myUserId);
        emit(MyUserBlocState.success(user));
      } catch (ex) {
        emit(const MyUserBlocState.failure());
      }
    });
  }
}
