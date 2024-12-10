import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'edit_group_event.dart';
part 'edit_group_state.dart';

class EditGroupBloc extends Bloc<EditGroupEvent, EditGroupState> {
  final ChatGroupsRepository chatGroupsRepository;
  EditGroupBloc({required this.chatGroupsRepository}) : super(EditGroupInitial()) {
    
    on<GroupUsersLoadingRequired>((event, emit) async {
      emit(EditGroupUserLoading());
      try {
        List<MyUser> users = await chatGroupsRepository.getAllUsers();
        emit(EditGroupUserLoaded(users: users));
      } catch (ex) {
        log(ex.toString());
        rethrow;
      }
    });

    on<EditGroupsRequired>((event, emit) async {
      try {
        emit(EditingInProgress());
        List<DocumentReference> selectedUsersList = chatGroupsRepository.getUsers(event.users);
        Map<String, DocumentReference> selectedUsersMap = {};
        for (DocumentReference user in selectedUsersList) {
          selectedUsersMap[user.id] = user;
        }
        Map<String, DocumentReference> currentUsersMap = {};
        for (DocumentReference user in event.group.users) {
          currentUsersMap[user.id] = user;
        }
        List<DocumentReference> usersToRemove = [];
        currentUsersMap.forEach((key, value) {
          if (!selectedUsersMap.containsKey(key)) {
            usersToRemove.add(value);
          }
        });
        List<DocumentReference> usersToAdd = [];
        selectedUsersMap.forEach((key, value) {
          if (!currentUsersMap.containsKey(key)) {
            usersToAdd.add(value);
          }
        });
        Groups updatedGroup = event.group.copyWith(
          users: selectedUsersList,
          groupName: event.groupName,
        );
        updatedGroup = await chatGroupsRepository.editGroup(updatedGroup, usersToAdd, usersToRemove, event.isGroupDpUpdated);
        emit(GroupsIsEdited(groups: updatedGroup));
      } catch (ex) {
        log(ex.toString());
      }
    });
  }
}


