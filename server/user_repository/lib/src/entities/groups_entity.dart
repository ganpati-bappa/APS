
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsEntity extends Equatable {

  final String id;
  final String groupName;
  final DocumentReference admin;
  final String adminName;
  final List<dynamic> users;
  final String? groupPhoto;
  final Timestamp updatedTime;
  final DocumentReference? lastMessage;
  final String? type;
  
  const GroupsEntity({
    required this.id,
    required this.groupName,
    required this.admin,
    required this.users,
    required this.updatedTime,
    required this.adminName,
    required this.lastMessage,
    this.type,
    groupPhoto
  }) : groupPhoto = groupPhoto ?? '';

  @override
  List<Object?> get props => [id, groupName, admin, users, groupPhoto, type];

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'groupName': groupName,
      'admins': admin,
      'users': users,
      'groupPhoto': groupPhoto,
      'updatedTime': updatedTime,
      'adminName': adminName,
      'lastMessage' : lastMessage,
      'type': type,
    };
  }

  static GroupsEntity fromDocument(Map<String, dynamic> doc) {
    return GroupsEntity(
      id: doc['id'] as String,
      groupName: doc['groupName'] as String,
      admin: doc['admins'] as DocumentReference,
      users: doc['users'] as List<dynamic>,
      groupPhoto: doc['groupPhoto'] as String,
      updatedTime: doc['updatedTime'] as Timestamp,
      adminName: doc['adminName'] as String,
      lastMessage: doc['lastMessage'] as DocumentReference?,
      type: doc['type'] as String
    );
  }
}