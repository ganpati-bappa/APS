// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable{
  final String id;
  final String email;
  final String name;
  final String? picture;
  final String phoneNo;
  final List<dynamic>? groups;
  final bool? appAdmin;
  final String? pushToken;
  final String? persona;

  const MyUserEntity({
      required this.id,
      required this.email,
      required this.name,
      required this.picture,
      required this.phoneNo,
      this.groups,
      this.appAdmin,
      this.pushToken,
      this.persona
    }
  );
  
  @override
  List<Object?> get props => [id, email, name, phoneNo, picture, groups, pushToken, persona];

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNo': phoneNo,
      'picture': picture,
      'groups': groups,
      'appAdmin': appAdmin,
      'pushToken': pushToken,
      'persona': persona
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      id: doc['id'] as String,
      email: doc['email'] as String,
      name: doc['name'] as String,
      phoneNo: doc['phoneNo'] as String,
      picture: doc['picture'] as String,
      groups: doc['groups'] as List<dynamic>,
      appAdmin: doc['appAdmin'] as bool,
      pushToken: doc["pushToken"] as String,
      persona: doc["persona"] as String
    );
  }

  
}