import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:developer';
part 'create_group_event.dart';
part 'create_group_state.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final ChatGroupsRepository chatGroupsRepository;

  CreateGroupBloc({required this.chatGroupsRepository}) : super(CreateGroupInitial()) {
    
    on<CreateNewGroup>((event, emit) async {
      try {
        emit(GroupCreationInProgress());
        if (event.groupName.isEmpty) {
          throw Exception("Group Name can not be empty");
        }
        final List<DocumentReference> userDocumentReference = await chatGroupsRepository.getDocumentReferenceOfUsers(event.users);
        final DocumentReference currentUserReference = chatGroupsRepository.getCurrentUserReference();
        await chatGroupsRepository.addGroups(
          Groups(
            id: "",
            groupName: event.groupName, 
            admin: currentUserReference, 
            users: userDocumentReference, 
            updatedTime: Timestamp.now(),
            adminName: event.admin.name,
            lastMessage: null,
            groupPhoto: event.groupPhoto
          ));
        emit(GroupSuccessfulyCreated());
      } catch (ex) {
        emit(GroupCreationFailed(message: ex.toString()));
        log(ex.toString());
        rethrow;
      }
    });

    on<ResetCreateGroupInitialState>((event, emit) {
      emit(CreateGroupInitial());
    });
  }
}
