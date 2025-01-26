part of 'chat_bloc.dart';

class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

final class GroupDeletionRequired extends ChatEvent {
  final Groups group;
  const GroupDeletionRequired({required this.group});
}

final class ChatLoadingRequired extends ChatEvent {
  final DocumentReference groupId;
  const ChatLoadingRequired({required this.groupId});
}

final class SendMessage extends ChatEvent {
  final String message;
  const SendMessage({required this.message});
}

final class SendFailure extends ChatEvent {}

final class ChatUpdate extends ChatEvent {
  final List<Messages> message;
  const ChatUpdate({required this.message});

  @override
  List<Object> get props => [message];
}

final class NoMoreMessagesToLoadRequired extends ChatEvent {}

final class SendImage extends ChatEvent {
  final String imagePath;
  const SendImage({required this.imagePath});
}


final class UpdateMessageReadBy extends ChatEvent {
  final String messageId;
  final List<dynamic> users;
  const UpdateMessageReadBy({required this.messageId, required this.users});
}

// ignore: must_be_immutable
class LoadMoreMessageRequired extends ChatEvent {
  List<Messages>? message;
  LoadMoreMessageRequired({this.message});
}

final class StoreImageLocally extends ChatEvent {
  final String filePath;
  final String messageId;
  const StoreImageLocally({required this.filePath, required this.messageId});
}

class ChatGroupObjectUpdateRequired extends ChatEvent {
  final Groups group;
  const ChatGroupObjectUpdateRequired({required this.group});
}

class SendPDF extends ChatEvent {
  final String filePath;
  final String fileName;
  final String type;
  const SendPDF({required this.filePath, required this.fileName, required this.type});
}

class DocDownloadRequired extends ChatEvent {
  final String url;
  final String name;
  const DocDownloadRequired({required this.url, required this.name});
}