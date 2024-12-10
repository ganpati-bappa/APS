part of 'create_group_bloc.dart';

sealed class CreateGroupState extends Equatable {
  const CreateGroupState();
  
  @override
  List<Object> get props => [];
}

final class CreateGroupInitial extends CreateGroupState {}

final class GroupCreationInProgress extends CreateGroupState {}

final class GroupSuccessfulyCreated extends CreateGroupState {}

final class GroupCreationFailed extends CreateGroupState {
  final String message;
  const GroupCreationFailed({required this.message});
}