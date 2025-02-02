// ignore_for_file: unnecessary_import, depend_on_referenced_packages

import 'dart:io';

import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer';

import 'package:user_repository/user_repository.dart';

class FirebaseChatGroupRepository extends FirebaseUserRepository implements ChatGroupsRepository {
  final groupsCollection = FirebaseFirestore.instance.collection('groups');
  final messagesCollection = FirebaseFirestore.instance.collection('messages');
  final Reference firebaseStorage = FirebaseStorage.instance.ref();
  final batch = FirebaseFirestore.instance.batch();

  FirebaseChatGroupRepository();

  @override
  Future<DocumentReference> addGroups(Groups group) async {
    try {
      DocumentReference groupRef = groupsCollection.doc();
      group = group.copyWith(id: groupRef.id);
      await groupRef.set(group.toEntity().toDocument());
      if (group.groupPhoto != null && group.groupPhoto!.isNotEmpty) {
        if (!group.groupPhoto!.contains("https://firebasestorage.googleapis.com")) {
          String imageUrl = await _uploadGroupDp(group.groupPhoto!, group.id);
          group = group.copyWith(groupPhoto: imageUrl);
        }
      }
      await groupRef.set(group.toEntity().toDocument());
      await addGroupToUser(groupRef, group);
      return groupRef;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteGroups(Groups group) async {
    final DocumentReference groupRef = groupsCollection.doc(group.id);
   try {
    // Removing groups from users
    for (DocumentReference userRef in group.users) {
      userRef.update({
        "groups": FieldValue.arrayRemove([groupRef]),
      });
    }

    // Deleting group photo
    try {
      if (group.groupPhoto != null && group.groupPhoto!.isNotEmpty) {
      String filePath = Uri.decodeComponent(group.groupPhoto!.split("/o/")[1].split("?")[0]);
      Reference fileRef = firebaseStorage.child(filePath);
      await fileRef.delete();
    }
    } catch (ex) {
      log(ex.toString());
    }

    // Deleting Messages
    try {
      await messagesCollection.where('groupId', isEqualTo: groupRef).get().then((snapshot) async {
      final batch = FirebaseFirestore.instance.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
         Messages message = Messages.fromEntity(
                  MessagesEntity.fromDocument(doc.data() as Map<String, dynamic>));
        if (message.messageType != "text") {
          String filePath = Uri.decodeComponent(message.url!.split("/o/")[1].split("?")[0]);
          Reference fileRef = firebaseStorage.child(filePath);        
          await fileRef.delete();
        }
        batch.delete(doc.reference);
      }
      await batch.commit();
     });
    } catch (ex) {
      log(ex.toString());
    }
    await groupsCollection.doc(group.id).delete();
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  List<DocumentReference<Object?>> getUsers(List<String> userIds) {
    try {
      if (userIds.isEmpty) {
        return [];
      } else {
        List<DocumentReference> users =  userIds.map((userId) => userCollection.doc(userId)).toList();
        return users;
      }
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<Groups> editGroup(Groups group, List<DocumentReference> newUsers, List<DocumentReference> removeUsers, bool isPhotoChanged) async {
    try {
      DocumentReference groupRef = groupsCollection.doc(group.id);
      String? groupPhotoUrl;
      if (isPhotoChanged) {
        groupPhotoUrl = await _uploadGroupDp(group.groupPhoto!, group.id);
      }
      groupRef.update({
        "users": group.users,
        "groupName": group.groupName,
        "groupPhoto" : groupPhotoUrl ?? group.groupPhoto,
        "updatedTime": Timestamp.now()
      });
      if (newUsers.isNotEmpty) {
        await _addUsersToGroup(groupRef, newUsers);
      }
      if (removeUsers.isNotEmpty) {
        await _removeUsersFromGroup(groupRef, removeUsers);
      }
      Groups updatedGroup = Groups.fromEntity(GroupsEntity.fromDocument(await groupRef.get().then((doc) => doc.data() as Map<String, dynamic>)));
      return updatedGroup;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Future<String> _uploadGroupDp(String imagePath, String groupId) async {
    try {
      File image = File(imagePath);
      Reference groupRef = firebaseStorage.child("groups/$groupId");
      await groupRef.putFile(image);
      String url = await groupRef.getDownloadURL();
      return url;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Future<void> _addUsersToGroup(DocumentReference groupId, List<DocumentReference> users) async {
    try {
      // ignore: avoid_function_literals_in_foreach_calls
      users.forEach((user) async => await user.update({
          "groups": FieldValue.arrayUnion([groupId])
        })
      );
    } catch (ex) {
      log(ex.toString());
    }
  }

  Future<void> _removeUsersFromGroup(DocumentReference groupId, List<DocumentReference> users) async {
    try {
      // ignore: avoid_function_literals_in_foreach_calls
      users.forEach((user) async => await user.update({
          "groups": FieldValue.arrayRemove([groupId])
        })
      );
    } catch (ex) {
      log(ex.toString());
    }
  }

  @override
  CollectionReference getGroupsCollectionReference() {
    return groupsCollection;
  }

  @override
  Future<List<DocumentReference>> getUserGroups() async {
    return await userGroups();
  }

  @override
  Future<List<Future<Groups>>> getGroups(List<DocumentReference> userGroups)  async {
    try {
      return userGroups.map((groupsRef) async {
       return await groupsRef.get().then((doc) => Groups.fromEntity(GroupsEntity.fromDocument(doc.data() as Map<String,dynamic>)));
      }).toList();
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  CollectionReference getMessages() {
    try {
      return messagesCollection;
    } catch (ex) { 
      log(ex.toString());
      rethrow;
    }
  }

  @override
  void sendMessage(String message, DocumentReference senderRef, DocumentReference groupRef) async {
    try {
      final DocumentReference messageRef = messagesCollection.doc();
      Messages messages = Messages(
      message: message, time: Timestamp.now(),url: "", messageType: "text", id: messageRef.id, sender: senderRef, groupId: groupRef, senderName: await senderRef.get().then((doc) => doc.get('name')));
      messageRef.set(messages.toEntity().toDocument());
      await groupRef.update({
        'updatedTime': messages.time,
        'lastMessage': messageRef
      });
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser?> getUser(DocumentReference<Object?> userRef) async {
    DocumentSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      return await getUserData(userRef.id);
    } else {
      return null;
    }
  }

  @override
  Future<Groups?> getPersonalGroup(MyUser curUser, MyUser sender) async {
    try {
      Groups? group;
      bool isPersonalGroup = false;
      for (DocumentReference groupRef in curUser.groups!) {
        if (sender.groups!.contains(groupRef)) {
          DocumentSnapshot snapshot = await groupRef.get();
          if (snapshot.exists) {
            group = Groups.fromEntity(GroupsEntity.fromDocument(snapshot.data() as Map<String, dynamic>));
            if (group.type == "Personal") {
              isPersonalGroup = true;
              break;
            }
          }
        }
      }
      if (!isPersonalGroup) {
        DocumentReference curUserRef = userCollection.doc(curUser.id);
        DocumentReference senderRef = userCollection.doc(sender.id);
        String groupName = "${curUser.name.split(" ")[0]} - ${sender.name.split(" ")[0]}";
        DocumentReference groupRef = await addGroups(Groups(
          id: "", 
          groupName: groupName, 
          admin: curUserRef, 
          users: [curUserRef, senderRef], 
          updatedTime: Timestamp.now(), 
          adminName: curUser.name, 
          lastMessage: null,
          groupPhoto: sender.picture,
          type: "Personal"
        ));
        group = await groupRef.get().then((doc) => Groups.fromEntity(GroupsEntity.fromDocument(doc.data() as Map<String, dynamic>)));
      }
      return group;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }
  
  @override
  Future<List<MyUser>> getAllUsers() async {
    try {
      return await userCollection.orderBy('name').get().then((users) {
        return users.docs.map((doc) => MyUser.fromEntity(MyUserEntity.fromDocument(doc.data()))).toList();
      });
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<List<DocumentReference>> getDocumentReferenceOfUsers(List<MyUser> users) async {
    try {
      return users.map((user) => userCollection.doc(user.id)).toList();
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> getCurrentUser() async {
    try {
      DocumentSnapshot doc = await userCollection.doc(loggedInUser!).get();
      return MyUser.fromEntity(MyUserEntity.fromDocument(doc.data() as Map<String, dynamic>));
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<List<MyUser>> getMembersOfGroup(String groupId) async {
   try {
      return await userCollection.where('groups', arrayContains: 'groups/$groupId').get().then((snapshot) {
        return snapshot.docs.map((doc) => MyUser.fromEntity(MyUserEntity.fromDocument(doc.data()))).toList();
      });
   } catch (ex) {
      log(ex.toString());
      rethrow;
   }
  }

  @override
  DocumentReference getUserReference(String? id)  {
    try {
      id ??= loggedInUser!;
      return userCollection.doc(id);
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }
  
  @override
  DocumentReference getGroupsReference(String id) {
    return groupsCollection.doc(id);
  } 

  @override
  Future<void> uploadChatImage(String path,  DocumentReference userRef, DocumentReference groupRef) async {
    try {
     Map<String, String?> imagePaths = await uploadImageChat(path);
     late final String url, localFilePath;
     if (imagePaths["url"] != null) {
      url = imagePaths["url"]!;
     }
     if (imagePaths["localFilePath"] != null) {
      localFilePath = imagePaths["localFilePath"]!;
     }
     final DocumentReference messageRef = messagesCollection.doc();
     Messages messages = Messages(groupId: groupRef, message: localFilePath, url: url, time: Timestamp.now(), sender: userRef, messageType: "image", id: messageRef.id, senderName: await userRef.get().then((doc) => doc.get('name')));
     await messageRef.set(messages.toEntity().toDocument());
     await groupRef.update({
        'updatedTime': messages.time,
        'lastMessage': messageRef
      });
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  } 

  @override
  Future<void> uploadChatDocs(String path,String fileName, DocumentReference<Object?> senderRef, DocumentReference<Object?> groupRef, String type) async {
    try {
      String fileUrl = await uploadDocChat(path);
      final DocumentReference messageRef = messagesCollection.doc();
      Messages messages = Messages(groupId: groupRef,url: fileUrl, message: fileName, time: Timestamp.now(), sender: userRef, messageType: type, id: messageRef.id, senderName: await userRef.get().then((doc) => doc.get('name')));
      await messageRef.set(messages.toEntity().toDocument());
      await groupRef.update({
        'updatedTime': messages.time,
        'lastMessage': messageRef
      });
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> chatUpdateReadBy(String messageId, List<dynamic> users) async {
    try {
      List<dynamic> readBy = await messagesCollection.doc(messageId).get().then((snapshot) => snapshot.data()!["readBy"]);
      readBy.add(getUserReference(null));
      await messagesCollection.doc(messageId).update({
        'readBy': readBy
      });
    } catch (ex) {
      log(ex.toString());
    }
  }
  
  @override
  Future<Messages> getLastMessage(String? groupId) async {
    try {
      DocumentReference? groupsRef = groupsCollection.doc(groupId);
      Groups group = await groupsRef.get().then((doc) => Groups.fromEntity(GroupsEntity.fromDocument(doc.data() as Map<String, dynamic>)));
      DocumentReference? messageRef = group.lastMessage;
      if (messageRef == null) {
        return Messages.empty();
      }
      return await messageRef.get().then((doc) {
        if (doc.data() != null) {
          return Messages.fromEntity(MessagesEntity.fromDocument(doc.data() as Map<String, dynamic>));
        } else {
          return Messages.empty();
        }
      });
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> storeImageLocally(responseFile , String messageId) async {
    try {
      final String? localFilePath = await getLocalFilePath();
      if (localFilePath != null) {
        final File file = File(localFilePath);
        file.writeAsBytesSync(responseFile.bodybytes);
        messagesCollection.doc(messageId).update({
          "message": localFilePath 
        });
      }
    } catch (ex) {
      log(ex.toString());      
    }
  }

  @override
  Future<void> deleteUserGroups(MyUser user) async {
    try {
      DocumentReference userRef = userCollection.doc(user.id);
      for (DocumentReference groupRef in user.groups!) {
        groupRef.update({
          "users": FieldValue.arrayRemove([userRef])
        });
      }
    } catch (ex) {
      log(ex.toString());
    }
  }
} 