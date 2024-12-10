import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  MyUser user;
  final UserRepository userRepository;

  UserProfileBloc({required this.userRepository}) : user = MyUser.empty ,super(UserProfileInitial()) {

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
      if (event.field == "phoneNo") {
        user = user.copyWith(phoneNo: event.value);
        emit(UserProfileLoaded(user: user));
      } else if (event.field == "name") {
        user = user.copyWith(name: event.value);
        emit(UserProfileLoaded(user: user));
      }
      await userRepository.updateUserProfile(event.field, event.value);
    });

    on<UploadImageRequired>((event, emit) async {
      try {
        String imagePath = await userRepository.uploadUserProfileImage(event.imagePath);
        MyUser updatedUser = user.copyWith(picture: imagePath);
        user = updatedUser;
        emit(UserProfileLoaded(user: updatedUser));
      } catch (ex) {
        log(ex.toString());
      }
  });
  }
}
