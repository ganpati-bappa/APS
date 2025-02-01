import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'add_user_event.dart';
part 'add_user_state.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  final ChatGroupsRepository chatGroupsRepository;
  List<MyUser> users = [];

  ChatGroupsRepository get myChatGroupsRepostiory => chatGroupsRepository;

  AddUserBloc({required this.chatGroupsRepository}) : super(AddUserInitial()) {
   
    on<UsersLoadingRequirred>((event, emit) async {
      emit(UsersLoading());
      try { 
        if (users.isNotEmpty) {
          emit(AddUsersLoaded(users: users));
        }
        else {
          users = await chatGroupsRepository.getAllUsers();
          emit(AddUsersLoaded(users: users));
        }
      } catch (ex) {
        emit(UsersLoadingFailure(message: ex.toString()));
        rethrow;
      }
    });

    on<UsersLoadingError>((event, emit) {
      emit(UsersLoadingFailure(message: event.message));
    });
  }
}
