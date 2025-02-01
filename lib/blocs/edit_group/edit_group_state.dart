part of 'edit_group_bloc.dart';

sealed class EditGroupState extends Equatable {
  const EditGroupState();
  
  @override
  List<Object> get props => [];
}

final class EditGroupInitial extends EditGroupState {}
final class EditGroupUserLoading extends EditGroupState {}
final class EditGroupUserLoaded extends EditGroupState {
  final List<MyUser> users;
  const EditGroupUserLoaded({required this.users});
}

final class GroupsIsEdited extends EditGroupState {
  final Groups groups;
  const GroupsIsEdited({required this.groups});
}

final class EditingInProgress extends EditGroupState {
}

final class GroupEditingFailedState extends EditGroupState {
  final String message;
  const GroupEditingFailedState({required this.message});

  @override
  List<Object> get props => [message];
}