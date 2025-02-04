part of 'user_profile_bloc.dart';

sealed class UserProfileState extends Equatable {
  const UserProfileState();
  
  @override
  List<Object> get props => [];
}

final class UserProfileInitial extends UserProfileState {}
final class UserProfileLoading extends UserProfileState {}
final class UserProfileError extends UserProfileState {}
final class UserProfileLoaded extends UserProfileState {
  final MyUser user;
  const UserProfileLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

final class UserLoggedOut extends UserProfileState {}

final class UserImageUploaded extends UserProfileState {
  final String imagePath;
  const UserImageUploaded({required this.imagePath});
}

final class FieldUpdationFailed extends UserProfileState {
  final String message;
  const FieldUpdationFailed({required this.message});

  @override
  List<Object> get props => [message];
}

final class UserDeletionInProgress extends UserProfileState {
}