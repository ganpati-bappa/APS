part of 'add_user_bloc.dart';

sealed class AddUserEvent extends Equatable {
  const AddUserEvent();

  @override
  List<Object> get props => [];
}

final class UsersLoadingRequirred extends AddUserEvent {}

final class UsersLoadingError extends AddUserEvent {
  final String message;
  const UsersLoadingError({required this.message});

  @override
  List<Object> get props => [message];
}