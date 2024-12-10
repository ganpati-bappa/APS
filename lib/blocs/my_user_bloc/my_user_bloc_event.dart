part of 'my_user_bloc_bloc.dart';

sealed class MyUserBlocEvent extends Equatable {
  const MyUserBlocEvent();

  @override
  List<Object> get props => [];
}

class GetMyUser extends MyUserBlocEvent {
  final String myUserId;

  const GetMyUser({required this.myUserId});

  @override
  List<Object> get props => [myUserId];
}