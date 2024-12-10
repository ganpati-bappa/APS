import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  HomeBloc({required this.userRepository}) : super(HomeInitial()) {

    on<HomeLoadingRequired>((event, emit) {
      // TODO: implement event handler
    });
  }
}
