part of 'create_group_bloc.dart';

sealed class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object> get props => [];
}

final class CreateNewGroup extends CreateGroupEvent {
  final String groupName;
  final List<MyUser> users;
  final MyUser admin;
  final String groupPhoto;
  const CreateNewGroup({required this.groupName, required this.users, required this.admin, required this.groupPhoto});
}

final class AddUsersToGroup extends CreateGroupEvent {}

final class AddAdminsToGroup extends CreateGroupEvent {}

final class ResetCreateGroupInitialState extends CreateGroupEvent {}