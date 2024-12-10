import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';

class MessagesEntity extends Equatable {

  final String? id;
  final String message;
  final List<dynamic>? readBy;
  final Timestamp? time;
  final DocumentReference? sender;
  final String? messageType;
  final DocumentReference? groupId;
  final String senderName;
  final String? url;

  const MessagesEntity({
     this.groupId,
    required this.message,
    this.time,
    this.sender,
    this.messageType,
    this.id,
    this.readBy = const [],
    required this.senderName,
    this.url
  });

  @override
  List<Object?> get props => [id, message, readBy, time, sender, messageType, groupId, url];

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'message': message,
      'readBy': readBy,
      'time': time,
      'sender': sender,
      'messageType': messageType,
      'groupId': groupId,
      'senderName': senderName,
      'url': url
    };
  }

  static MessagesEntity fromDocument(Map<String, dynamic> doc) {
    return MessagesEntity(
      id: doc['id'] as String,
      message: doc['message'] as String,
      readBy: doc['readBy'],
      sender: doc['sender'] as DocumentReference,
      time: doc['time'] as Timestamp,
      messageType: doc['messageType'] as String,
      groupId: doc['groupId'] as DocumentReference<Map<String, dynamic>>,
      senderName: doc['senderName'] as String,
      url: doc['url'] as String,
    );
  }

  static Map<String, Object?> toJSON(Messages message) {
    return {
      'id': message.id,
      'message': message.message,
      'readBy': message.readBy,
      'time': message.time,
      'sender': message.sender,
      'messageType': message.messageType,
      'groupId': message.groupId,
      'senderName': message.senderName,
      'url': message.url
    };
  }

}