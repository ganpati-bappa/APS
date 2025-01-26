part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
}

final class NoMoreMessagesToLoad extends ChatState {
}

final class ChatLoaded extends ChatState {
  final List<Messages> messages;
  const ChatLoaded({required this.messages});

   @override
  List<Object> get props => [messages];
}


final class SendingMessage extends ChatState {
  final List<Messages> messages;
  const SendingMessage({required this.messages});
}

final class ChatLoadFailure extends ChatState {}

final class ChatImageLoaded extends ChatState {
  final String imagePath;
  const ChatImageLoaded({required this.imagePath});
}

final class MoreChatLoading extends ChatState {}

final class ChatGroupUpdated extends ChatState {
  final Groups group;
  const ChatGroupUpdated({required this.group});
}

final class GroupDeletionInProgress extends ChatState {}

final class GroupDeleted extends ChatState {}

final class DocLoadingMessages extends ChatState {
  final String message;
  const DocLoadingMessages({required this.message});

   @override
  List<Object> get props => [message]; 
}

final class DocLoaded extends ChatState {}