part of 'groups_bloc.dart';

sealed class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object> get props => [];
}

final class ChatGroupsLoadingRequired extends GroupsEvent {}

final class GroupsUpdateRequired extends GroupsEvent {
  final List<Groups> groups;

  const GroupsUpdateRequired({required this.groups});

   @override
  List<Object> get props => [groups];
}

final class GetLastMessage extends GroupsEvent {
  final String groupId;
  const GetLastMessage({required this.groupId});
}
