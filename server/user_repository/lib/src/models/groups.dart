import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/src/entities/groups_entity.dart';
import 'package:user_repository/src/entities/my_user_entity.dart';
import 'package:user_repository/user_repository.dart';

class Groups extends Equatable {

  @override
  List<Object?> get props => [];

  final String id;
  final String groupName;
  final DocumentReference admin;
  final String adminName;
  final List<dynamic> users;
  final Timestamp updatedTime;
  final String? groupPhoto;
  final DocumentReference? lastMessage;
  
  const Groups({
    required this.id,
    required this.groupName,
    required this.admin,
    required this.users,
    required this.updatedTime,
    required this.adminName,
    required this.lastMessage,
    groupPhoto
  }) : groupPhoto = groupPhoto ?? '';

  Groups copyWith({
    String? id,
    String? groupName,
    DocumentReference? admin,
    String? adminName,
    List<dynamic> ? users,
    String? groupPhoto,
    Timestamp? updatedTime,
    DocumentReference? lastMessage
  }) {
    return Groups(id: id ?? this.id, groupName: groupName ?? this.groupName, admin: admin ?? this.admin, users: users ?? this.users, groupPhoto: groupPhoto ?? this.groupPhoto, updatedTime: updatedTime ?? this.updatedTime, adminName: adminName ?? this.adminName, lastMessage: lastMessage ?? this.lastMessage);
  }

  GroupsEntity toEntity() {
    return GroupsEntity(
      id: id,
      groupName: groupName,
      admin: admin,
      users: users,
      groupPhoto: groupPhoto,
      updatedTime: updatedTime,
      adminName: adminName,
      lastMessage: lastMessage
    );
  }

static Groups fromEntity(GroupsEntity entity) {
    return Groups(
      id: entity.id,
      groupName: entity.groupName,
      admin: entity.admin,
      users: entity.users,
      groupPhoto: entity.groupPhoto,
      updatedTime: entity.updatedTime,
      adminName: entity.adminName,
      lastMessage: entity.lastMessage
    );
  }
}