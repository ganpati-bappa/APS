part of 'add_user_bloc.dart';

sealed class AddUserState extends Equatable {
  const AddUserState();
  
  @override
  List<Object> get props => [];
}

final class AddUserInitial extends AddUserState {}

final class UsersLoading extends AddUserState {}

final class AddUsersLoaded extends AddUserState {
  final List<MyUser> users;
  const AddUsersLoaded({required this.users});
}

final class UsersLoadingFailure extends AddUserState {
  final String message;
  const UsersLoadingFailure(this.message);
}
