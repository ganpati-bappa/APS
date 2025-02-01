import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:developer';
part 'personal_chat_creation_event.dart';
part 'personal_chat_creation_state.dart';


class PersonalChatCreationBloc extends Bloc<PersonalChatCreationEvent, PersonalChatCreationState> {
  final ChatGroupsRepository chatGroupsRepository;
  PersonalChatCreationBloc({required this.chatGroupsRepository}) : super(PersonalChatCreationLoading()) {
    
    on<PersonalChatFetchUsers>((event, emit) async {
      final MyUser user = await chatGroupsRepository.getCurrentUser();
      Map<String, List<MyUser>> userPersonaMapping = {
        "Student": [],
        "Teacher": [],
        "Parent": [],
      };
      if (user.persona == "Student" || user.persona == "Parent") {
        for (DocumentReference userRef in event.groups!.users) {
          final MyUser? curUser = await chatGroupsRepository.getUser(userRef);
          if (curUser != null && curUser.persona == "Teacher" && user.id != curUser.id) {
            userPersonaMapping["Teacher"]!.add(curUser);
          }
        }
      } else if (user.persona == "Teacher") {
        for (DocumentReference userRef in event.groups!.users) {
          final MyUser? curUser = await chatGroupsRepository.getUser(userRef);
          
          if (curUser != null && curUser.persona == "Parent" && user.id != curUser.id) {
            userPersonaMapping["Parent"]!.add(curUser);
          } else if (curUser != null && curUser.persona == "Student" && user.id != curUser.id) {
             userPersonaMapping["Student"]!.add(curUser);
          }
        }
      } else {
        for (DocumentReference userRef in event.groups!.users) {
          final MyUser? curUser = await chatGroupsRepository.getUser(userRef);
          if (curUser != null && curUser.persona != "Admin" && user.id != curUser.id) {
            userPersonaMapping[curUser.persona]!.add(curUser);
          }
        }
      }
      emit(PersonalChatCreationLoaded(users: userPersonaMapping, curUser: user));
    });

    on<FetchPersonalChat> ((event, emit) async {
      emit(FetchingPersonalChat());
      try {
        Groups? group = await chatGroupsRepository.getPersonalGroup(event.curUser, event.sender);
        if (group == null) {
          throw Exception("Group does not exists");
        }
        emit(PersonalChatGroupFetched(groups: group));
      } catch (ex) {
        emit(PersonalChatCreationError(message: ex.toString()));
        log(ex.toString());
      }
    });
  }
}
