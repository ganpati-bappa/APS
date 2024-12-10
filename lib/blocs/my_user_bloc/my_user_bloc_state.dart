part of 'my_user_bloc_bloc.dart';

enum MyUserStatus { success, loading, failure }

class MyUserBlocState extends Equatable {
   
  final MyUserStatus status;
  final MyUser? user;

  const MyUserBlocState._({
    this.status = MyUserStatus.loading,
    this.user
  });
  
  @override
  List<Object> get props => [];

  const MyUserBlocState.loading() : this._();
  const MyUserBlocState.success(MyUser user) : this._(status: MyUserStatus.success, user: user);
  const MyUserBlocState.failure() : this._(status: MyUserStatus.failure);
}


