part of 'edit_group_bloc.dart';

sealed class EditGroupEvent extends Equatable {
  const EditGroupEvent();

  @override
  List<Object> get props => [];
}

final class GroupUsersLoadingRequired extends EditGroupEvent {
  final String groupId;
  const GroupUsersLoadingRequired({required this.groupId});
}

final class EditGroupsRequired extends EditGroupEvent {
  final String groupName;
  final List<String> users;
  final Groups group;
  final bool isGroupDpUpdated;
  const EditGroupsRequired({required this.groupName, required this.users, required this.group, required this.isGroupDpUpdated});
}