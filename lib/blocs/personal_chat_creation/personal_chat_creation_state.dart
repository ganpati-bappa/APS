part of 'personal_chat_creation_bloc.dart';

sealed class PersonalChatCreationState extends Equatable {
  const PersonalChatCreationState();
  
  @override
  List<Object> get props => [];
}

final class PersonalChatCreationLoading extends PersonalChatCreationState {}

final class PersonalChatCreationLoaded extends PersonalChatCreationState {
  final Map<String,List<MyUser>> users;
  final MyUser curUser;
  const PersonalChatCreationLoaded({required this.users, required this.curUser});
}

final class PersonalChatCreationError extends PersonalChatCreationState {
  final String message;
  const PersonalChatCreationError({required this.message});
}

final class PersonalChatGroupFetched extends PersonalChatCreationState {
  final Groups groups;
  const PersonalChatGroupFetched({required this.groups});
}

final class FetchingPersonalChat extends PersonalChatCreationState {
}
