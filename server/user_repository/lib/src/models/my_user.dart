import 'package:equatable/equatable.dart';
import '../entities/my_user_entity.dart';

class MyUser extends Equatable {
  
  @override
  List<Object?> get props => [id, email, name, phoneNo, picture, groups, persona];
  
  final String id;
  final String email;
  final String name;
  final String? picture;
  final String phoneNo;
  final List<dynamic>? groups;
  final bool? appAdmin;
  final String? pushToken;
  final String? persona;

  MyUser(
    {required this.id,
      required this.email,
      required this.name,
      required this.picture,
      required this.phoneNo,
      List<dynamic>? groups,
      bool? appAdmin,
      this.pushToken,
      this.persona
    } 
  ) : appAdmin = appAdmin ?? false, groups = groups ?? [];

  static final empty = MyUser(
    id: '',
    email: '',
    name: '',
    picture: '',
    phoneNo: '',
    groups: const [],
    appAdmin: false,
    pushToken: '',
    persona: 'student'
  );

  MyUser copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    String? phoneNo,
    List<dynamic>? groups,
    String? pushToken,
    String? persona
  }) {
    return MyUser(id: id ?? this.id, email: email ?? this.email, name: name ?? this.name, picture: picture ?? this.picture, phoneNo: phoneNo ?? this.phoneNo, groups: groups ?? this.groups, pushToken: pushToken ?? this.pushToken, persona: persona ?? this.persona);
  }

  bool get isEmpty =>  this == MyUser.empty;

MyUserEntity toEntity() {
    return MyUserEntity(
      id: id,
      email: email,
      name: name,
      phoneNo: phoneNo,
      picture: picture,
      groups: groups,
      appAdmin: appAdmin,
      pushToken: pushToken,
      persona: persona
    );
  }

static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phoneNo: entity.phoneNo,
      picture: entity.picture,
      groups: entity.groups,
      appAdmin: entity.appAdmin,
      pushToken: entity.pushToken,
      persona: entity.persona
    );
  }
}
