// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';

abstract class ChatGroupsRepository {
  CollectionReference getMessages();
  CollectionReference getGroupsCollectionReference();
  void sendMessage(String message, DocumentReference senderRef, DocumentReference groupRef);
  Future<List<Future<Groups>>> getGroups(List<DocumentReference> userGroups);
  Future<Messages> getLastMessage(String ? groupId);
  Future<List<DocumentReference>> getUserGroups();
  Future<DocumentReference> addGroups(Groups group);
  Future<Groups> editGroup(Groups group, List<DocumentReference> newUsers, List<DocumentReference> removeUsers, bool isPhotoChanged);
  Future<void> deleteGroups(Groups group);
  Future<List<MyUser>> getAllUsers();
  Future<List<DocumentReference>> getDocumentReferenceOfUsers(List<MyUser> users);
  DocumentReference getUserReference(String? id);
  Future<MyUser> getCurrentUser();
  DocumentReference getGroupsReference(String id);
  Future<void> uploadChatImage(String path,DocumentReference senderRef, DocumentReference groupId);
  Future<void> uploadChatDocs(String path,String filename, DocumentReference senderRef, DocumentReference groupId, String type);
  Future<void> chatUpdateReadBy(String groupId, List<dynamic> users);
  Future<List<MyUser>> getMembersOfGroup(String groupId);
  List<DocumentReference> getUsers(List<String> groupIds);
  Future<void> storeImageLocally(dynamic image, String messageId);
  Future<MyUser?> getUser(DocumentReference userRef);
  Future<Groups?> getPersonalGroup(MyUser curUser, MyUser sender);
  Future<void> deleteUserGroups(MyUser user);
}