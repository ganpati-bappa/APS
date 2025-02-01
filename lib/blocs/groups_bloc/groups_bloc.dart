import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:developer';
part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final ChatGroupsRepository chatGroupsRepository;
  final User? user;
  List<Groups> groups = [];
  List<DocumentReference> groupsRef = [];
  Map<String, Messages> lastMessages = {};
  int offset = 0,limit = 10;
  StreamSubscription? _groupSubscription;
  MyUser? currentUser;

  DocumentReference get userRef  => chatGroupsRepository.getUserReference(null);

  DocumentReference groupRef(String id) => chatGroupsRepository.getGroupsReference(id);

  GroupsBloc({required this.chatGroupsRepository, this.user}) : super(GroupsInitial()) {

    on<ChatGroupsLoadingRequired>((event, emit) async {
      try {
        if (groups.isNotEmpty) {
          emit(GroupsLoaded(groups: groups));
        }
        else {
          emit(GroupsLoading());
        }
        currentUser = await chatGroupsRepository.getCurrentUser();
        lastMessages = {};
        groupsRef = await chatGroupsRepository.getUserGroups();
        _groupSubscription = chatGroupsRepository.getGroupsCollectionReference().orderBy("updatedTime",descending: true).snapshots().listen((snapshot) {
          List<Groups> newGroups = snapshot.docs.where((doc){
             return groupsRef.any((groupRef) => groupRef.id == doc.id);
          }).map((doc) => Groups.fromEntity(GroupsEntity.fromDocument(doc.data() as Map<String,dynamic>))
          ).toList();
          if (!isClosed) {
            add(GroupsUpdateRequired(groups: newGroups));
          }
        });
      } catch (ex) {
        log(ex.toString());
        emit(GroupsLoadError());
        rethrow;
      }
    });   

    on<GroupsUpdateRequired>((event, emit) {
      groups = event.groups;
      emit(GroupsLoaded(groups: event.groups));
    });

    on<GetLastMessage>((event, emit) async {
      final Messages lastMessage = await chatGroupsRepository.getLastMessage(event.groupId!);
      emit(LastMessageFetched(lastMessage: lastMessage, groupId: event.groupId));
    });
  }

  @override
  Future<void> close() {
    _groupSubscription!.cancel();
    return super.close();
  }
}
