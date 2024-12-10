import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:developer';
import 'package:http/http.dart' as  http;

part 'chat_event.dart';
part 'chat_state.dart';

class ChatsBloc extends Bloc<ChatEvent, ChatState> {
  final ChatGroupsRepository _chatRepository;
  final DocumentReference groupRef;
  final DocumentReference senderRef;
  StreamSubscription? _subscription;
  List<Messages> messages = [];
  bool isFirstMessageLoaded = false;
  Set<String> uniqueMessage = <String>{};
  DocumentSnapshot? _lastMessageFetched;

  ChatsBloc({
    required ChatGroupsRepository myChatRepository,
    required this.groupRef,
    required this.senderRef,
  })  : _chatRepository = myChatRepository,
        super(const ChatInitial()) {

    on<ChatLoadingRequired>((event, emit) async {
      try {
        List<Messages> newMessages = [];
        if (_subscription != null) {
          await _subscription!.cancel();
        }
        final CollectionReference messagesCollection =
            _chatRepository.getMessages();
        _subscription = messagesCollection
            .where('groupId', isEqualTo: groupRef)
            .orderBy('time', descending: true)
            .limit(1)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.docChanges
              .any((change) => change.type == DocumentChangeType.added) || snapshot.docChanges.isEmpty) {
            for (var doc in snapshot.docs) {
              if (!isFirstMessageLoaded) {
                _lastMessageFetched = doc;
              }
              Messages message = Messages.fromEntity(
                  MessagesEntity.fromDocument(
                      doc.data() as Map<String, dynamic>));
              newMessages = [message] + messages;
            }
            if (!isClosed && !isFirstMessageLoaded) {
              add(LoadMoreMessageRequired(message: newMessages));
            } else {
              add(ChatUpdate(message: newMessages));
            }
          }
        });
      } catch (ex) {
        log(ex.toString());
      }
    });

    on<ChatUpdate>((event, emit) {
      messages = event.message;
      emit(ChatLoaded(messages: event.message));
    });

    on<SendMessage>((event, emit) {
      emit(SendingMessage(messages: [ Messages(groupId: groupRef, message: event.message, time: Timestamp.now(), sender: senderRef, messageType: "textLoading", id: "", senderName: ""),...messages]));
      _chatRepository.sendMessage(event.message, senderRef, groupRef);
    });

    on<SendImage>((event, emit) async {
      emit(SendingMessage(messages: [ Messages(groupId: groupRef, message: event.imagePath, time: Timestamp.now(), sender: senderRef, messageType: "imageLoading", id: "", senderName: ""),...messages]));
      try {
        await _chatRepository.uploadChatImage(
            event.imagePath, senderRef, groupRef);
      } catch (ex) {
        log(ex.toString());
        rethrow;
      }
    });

    on<UpdateMessageReadBy>((event, emit) async {
      await _chatRepository.chatUpdateReadBy(event.messageId, event.users);
    });

    on<LoadMoreMessageRequired>((event, emit) {
      if (!isFirstMessageLoaded) {
        emit(ChatLoading());
      }
      if (_lastMessageFetched == null) {
        emit(ChatLoaded(messages: messages));
        return;
      }
      final CollectionReference messagesCollection =
          _chatRepository.getMessages();
      messagesCollection
          .where("groupId", isEqualTo: groupRef)
          .orderBy("time", descending: true)
          .startAfterDocument(_lastMessageFetched!)
          .limit(30)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _lastMessageFetched = snapshot.docs.last;
          List<Messages>fetchedMessages = snapshot.docs
                  .map((doc) => Messages.fromEntity(MessagesEntity.fromDocument(
                      doc.data() as Map<String, dynamic>)))
                  .toList();
          List<Messages> oldMessages = (isFirstMessageLoaded
                  ? messages
                  : event.message)! + fetchedMessages;
              
          add(ChatUpdate(message: oldMessages));
          if (fetchedMessages.length < 30) {
            add(NoMoreMessagesToLoadRequired());
          }
        } else if (!isFirstMessageLoaded) {
          add(ChatUpdate(message: event.message!));
        } else {
          add(NoMoreMessagesToLoadRequired());
        }
        isFirstMessageLoaded = true;
      });
    });

    on<NoMoreMessagesToLoadRequired>((event, emit) {
      emit(NoMoreMessagesToLoad());
    });

    on<ChatGroupObjectUpdateRequired>((event, emit) {
      emit(ChatGroupUpdated(group: event.group));
    });

    on<SendPDF>((event, emit) async {
      emit(SendingMessage(messages: [ Messages(groupId: groupRef, message: event.fileName, time: Timestamp.now(), sender: senderRef, messageType: "pdfLoading", id: "", senderName: ""),...messages]));
      try {
          await _chatRepository.uploadChatDocs(event.filePath, event.fileName, senderRef, groupRef);
      } catch (ex) {
        log(ex.toString());
      }
    });

    on<StoreImageLocally>((event, emit) async {
      final response = await http.get(Uri.parse(event.filePath));
      if (response.statusCode == 200) {
        _chatRepository.storeImageLocally(response, event.messageId);
      }
    });

    on<GroupDeletionRequired>((event, emit) async {
      try {
        emit(GroupDeletionInProgress());
        await _chatRepository.deleteGroups(event.group);
        emit(GroupDeleted());
      } catch (ex) {
        log(ex.toString());
      }
    });
  }

  @override
  Future<void> close() async {
    await _subscription!.cancel();
    return super.close();
  }
}
