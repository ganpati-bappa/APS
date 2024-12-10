part of 'groups_bloc.dart';

sealed class GroupsState extends Equatable {
  const GroupsState();
  
  @override
  List<Object> get props => [];
}

final class GroupsInitial extends GroupsState {
}

final class GroupsLoading extends GroupsState {}
final class GroupsLoaded extends GroupsState {
  final List<Groups> groups;
  const GroupsLoaded({required this.groups});

  @override
  List<Object> get props => [groups];
}

final class GroupsLoadedByUpdating extends GroupsState {}

final class GroupsLoadError extends GroupsState {}

final class GroupsMessagesLoaded extends GroupsState {
  final Map<String,List<Messages>> messages;

  const GroupsMessagesLoaded({required this.messages});

  @override
  List<Object> get props => [messages];
}

final class LastMessageFetched extends GroupsState {
  final Messages? lastMessage;
  final String groupId;
  const LastMessageFetched({required this.lastMessage, required this.groupId});

   @override
  List<Object> get props => [lastMessage!, groupId];
}

