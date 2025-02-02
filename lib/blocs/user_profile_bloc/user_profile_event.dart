part of 'user_profile_bloc.dart';

sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class UserProfileLoadingRequired extends UserProfileEvent {
  final String? userId;
  const UserProfileLoadingRequired({this.userId});
}

class SignOutRequired extends UserProfileEvent {
  const SignOutRequired();
}

final class UploadImageRequired extends UserProfileEvent {
  final String imagePath;
  const UploadImageRequired({required this.imagePath});
}

final class UpdateUserProfileRequired extends UserProfileEvent {
  final String field;
  final String value;
  const UpdateUserProfileRequired({required this.field, required this.value});
}

final class FieldUpdationFailing extends UserProfileEvent {
  final String message;
  const FieldUpdationFailing({required this.message});

   @override
  List<Object> get props => [message];
}

final class UserProfileDeletionRequired extends UserProfileEvent {
  final MyUser user;
  final String password;
  const UserProfileDeletionRequired({required this.user, required this.password});
}