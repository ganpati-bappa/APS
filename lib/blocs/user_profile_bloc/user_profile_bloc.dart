import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  MyUser user;
  final UserRepository userRepository;
  final ChatGroupsRepository chatGroupsRepository;

  UserProfileBloc({required this.userRepository, required this.chatGroupsRepository})
      : user = MyUser.empty,
        super(UserProfileInitial()) {
    on<UserProfileLoadingRequired>((event, emit) async {
      emit(UserProfileLoading());
      try {
        if (user.id == "") {
          user = await userRepository.getUserData();
        }
        emit(UserProfileLoaded(user: user));
      } catch (ex) {
        emit(UserProfileError());
        log(ex.toString());
        rethrow;
      }
    });

    on<SignOutRequired>((event, emit) async {
      emit(UserProfileLoading());
      try {
        await userRepository.logout();
        emit(UserLoggedOut());
      } catch (ex) {
        log(ex.toString());
      }
    });

    on<UpdateUserProfileRequired>((event, emit) async {
      try {
        if (event.field == "phoneNo") {
          RegExp phoneNoValidator = RegExp(r"^\+[1-9]{1}[0-9]{3,14}$");
          if (phoneNoValidator.hasMatch(event.value)) {
            user = user.copyWith(phoneNo: event.value);
            emit(UserProfileLoaded(user: user));
          } else {
            throw Exception("Invalid Mobile No");
          }
        } else if (event.field == "name") {
          if (event.value.isEmpty) {
            throw Exception("Name can not be empty");
          } else {
            user = user.copyWith(name: event.value);
            emit(UserProfileLoaded(user: user));
          }
        }
        await userRepository.updateUserProfile(event.field, event.value);
      } catch (ex) {
        add(FieldUpdationFailing(message: ex.toString()));
        log(ex.toString());
      }
    });

    on<UploadImageRequired>((event, emit) async {
      try {
        String imagePath =
            await userRepository.uploadUserProfileImage(event.imagePath);
        MyUser updatedUser = user.copyWith(picture: imagePath);
        user = updatedUser;
        emit(UserProfileLoaded(user: updatedUser));
      } catch (ex) {
        log(ex.toString());
      }
    });

    on<FieldUpdationFailing>((event,emit) {
      emit(FieldUpdationFailed(message: event.message));
    });

    on<UserProfileDeletionRequired>((event,emit) async {
      try {
        await userRepository.reAuthenticateUser(event.user.email, event.password);
        emit(UserDeletionInProgress());
        await chatGroupsRepository.deleteUserGroups(event.user);
        await userRepository.deleteAccount(event.user, event.password);
        emit(UserLoggedOut());
      } catch(ex) {
        emit(FieldUpdationFailed(message: ex.toString()));
        log(ex.toString());
      }
    });
  }
}
