import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'add_user_event.dart';
part 'add_user_state.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  final ChatGroupsRepository chatGroupsRepository;

  ChatGroupsRepository get myChatGroupsRepostiory => chatGroupsRepository;

  AddUserBloc({required this.chatGroupsRepository}) : super(AddUserInitial()) {
   
    on<UsersLoadingRequirred>((event, emit) async {
      emit(UsersLoading());
      try {
        List<MyUser> users = await chatGroupsRepository.getAllUsers();
        emit(AddUsersLoaded(users: users));
      } catch (ex) {
        emit(UsersLoadingFailure(ex.toString()));
        rethrow;
      }
    });
  }
}
