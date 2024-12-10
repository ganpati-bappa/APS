import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/src/entities/messages_entity.dart';

class Messages extends Equatable {

  @override
  List<Object?> get props => [];

  final String? id;
  final String message;
  final List<dynamic>? readBy;
  final Timestamp? time;
  final DocumentReference? sender;
  final String? messageType;
  final DocumentReference? groupId;
  final String senderName;
  final String? url;

  const Messages({
    required this.groupId,
    required this.message,
    required this.time,
    required this.sender,
    required this.messageType,
    required this.id,
    required this.senderName,
    this.url,
    this.readBy = const [],
  });

static Messages empty() {
  return const Messages(
    groupId: null,
    message: '',
    time: null,
    sender: null,
    id: '',
    messageType: '',
    senderName: '',
    url: '',
  );
}

  Messages copyWith({
    String? id,
    DocumentReference? groupId,
    Timestamp? time,
    DocumentReference? sender,
    String? messageType,
    List<String>? readBy,
    String? message,
    String? senderName,
    String? url,
  }) {
    return Messages(id: id ?? this.id, groupId: groupId ?? this.groupId, time: time ?? this.time, sender: sender ?? this.sender, readBy: readBy ?? this.readBy, messageType: messageType ?? this.messageType, message: message ?? this.message, senderName: senderName ?? this.senderName, url: url ?? this.url);
  }


  MessagesEntity toEntity() {
    return MessagesEntity(
      id: id,
      groupId: groupId,
      time: time,
      sender: sender,
      message: message,
      messageType: messageType,
      readBy: readBy,
      senderName: senderName,
      url: url
    );
  }

static Messages fromEntity(MessagesEntity entity) {
    return Messages(
      id: entity.id,
      groupId: entity.groupId,
      time: entity.time,
      sender: entity.sender,
      message: entity.message,
      messageType: entity.messageType,
      readBy: entity.readBy,
      senderName: entity.senderName,
      url: entity.url
    );
  }

}