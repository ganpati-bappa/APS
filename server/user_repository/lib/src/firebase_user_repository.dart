// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'entities/entities.dart';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseUserRepository implements UserRepository {
  late final FirebaseAuth _fireBaseAuth;
  final userCollection = FirebaseFirestore.instance.collection('users');
  static final Reference firebaseStorage = FirebaseStorage.instance.ref();
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  
  FirebaseUserRepository({FirebaseAuth? fireBaseAuth})
      : _fireBaseAuth = fireBaseAuth ?? FirebaseAuth.instance;

  @override
  Future<void> logout() async {
    try {
      await _fireBaseAuth.signOut();
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _fireBaseAuth.sendPasswordResetEmail(email: email);
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _fireBaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> userSnapshot =
          await userCollection
              .where('phoneNo', isEqualTo: myUser.phoneNo)
              .limit(1)
              .get();
      if (userSnapshot.docs.isNotEmpty) {
        throw Exception("Phono No is already registered");
      }
      UserCredential user = await _fireBaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);
      myUser = myUser.copyWith(id: user.user!.uid);
      return myUser;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> getUserData([String? myUserId]) async {
    try {
      myUserId = myUserId ?? loggedInUser;
      return await userCollection.doc(myUserId).get().then((value) =>
          MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> setUserData(MyUser user) async {
    try {
      await userCollection.doc(user.id).set(user.toEntity().toDocument());
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Stream<User?> get user =>
      _fireBaseAuth.authStateChanges().map((firebaseUser) {
        final user = firebaseUser;
        return user;
      });

  DocumentReference get userRef => userCollection.doc(loggedInUser);

  String? get loggedInUser => _fireBaseAuth.currentUser!.uid;

  Future<List<DocumentReference>> userGroups() async {
    try {
      DocumentSnapshot snapshot = await userCollection.doc(loggedInUser).get();
      List<dynamic> dynamicGroups = snapshot.get('groups');
      return dynamicGroups.map((group) => group as DocumentReference).toList();
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Future<void> addGroupToUser(DocumentReference groupRef, Groups group) async {
    try {
      for (DocumentReference userRef in group.users) {
        await userRef.update({
          'groups': FieldValue.arrayUnion([groupRef])
        });
      }
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(String field, String value) async {
    try {
      await userRef.update({
        field: value
      });
    } catch (ex) {
      log(ex.toString());
    }
  }

  Future<String?> getLocalFilePath() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      return "${directory.path}/${Timestamp.now()}";
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<String> uploadImage(String path) async {
    try {
      File imageFile = File(path);
      Reference imageFolderRef = firebaseStorage.child("images");
      await imageFolderRef.putFile(imageFile);
      String url = await imageFolderRef.getDownloadURL();
      await userRef.update({'picture': url});
      return url;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Future<Map<String, String?>>  uploadImageChat(String path) async {
    try { 
      File imageFile = File(path);
      String? localFilePath = await getLocalFilePath();
      if (localFilePath != null) {
        imageFile.copySync(localFilePath);
      }
      Reference messageFolderRef =
          firebaseStorage.child("messages/${Timestamp.now()}");
      await messageFolderRef.putFile(imageFile);
      String url = await messageFolderRef.getDownloadURL();
      return {
        "url": url,
        "localFilePath": localFilePath
      };
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

   Future<String> uploadDocChat(String path) async {
    try {
      File docPath = File(path);
      Reference messageFolderRef =
          firebaseStorage.child("messages/${Timestamp.now()}");
      await messageFolderRef.putFile(docPath);
      String url = await messageFolderRef.getDownloadURL();
      return url;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<String> uploadUserProfileImage(String path) async {
    try {
      File imageFile = File(path);
      Reference usersFolderRef = firebaseStorage.child('users/$loggedInUser');
      await usersFolderRef.putFile(imageFile);
      String url = await usersFolderRef.getDownloadURL();
      await userCollection.doc(loggedInUser).update({
        "picture": url,
      });
      return url;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true
    );

    await firebaseMessaging.getToken().then((token) {
      if (token != null) {
        userCollection.doc(loggedInUser).update({
          "pushToken": token
        });
      }
    });
  }
}
