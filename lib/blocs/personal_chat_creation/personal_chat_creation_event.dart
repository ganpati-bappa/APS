part of 'personal_chat_creation_bloc.dart';

sealed class PersonalChatCreationEvent extends Equatable {
  const PersonalChatCreationEvent();

  @override
  List<Object> get props => [];
}

class PersonalChatFetchUsers extends PersonalChatCreationEvent {
  final Groups? groups;
  final MyUser user;
  const PersonalChatFetchUsers({required this.groups, required this.user});
}

class FetchPersonalChat extends PersonalChatCreationEvent {
  final MyUser curUser;
  final MyUser sender;
  const FetchPersonalChat({required this.curUser, required this.sender});
}