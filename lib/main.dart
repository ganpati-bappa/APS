import 'package:aps/blocs/authentication_bloc/authentication_bloc_bloc.dart';
import 'package:aps/blocs/groups_bloc/groups_bloc.dart';
import 'package:aps/firebase_options.dart';
import 'package:aps/simple_bloc_observer.dart';
import 'package:aps/src/theme.dart';
import 'package:aps/src/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(FirebaseUserRepository(), FirebaseChatGroupRepository()));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final ChatGroupsRepository chatGroupsRepository;
  const MyApp(this.userRepository, this.chatGroupsRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthenticationBlocBloc>(
            create: (context) =>
                AuthenticationBlocBloc(myUserRepository: userRepository),
          ),
          RepositoryProvider<GroupsBloc>(
            create: (context) =>
                GroupsBloc(chatGroupsRepository: chatGroupsRepository),
          ),
        ],
        child: MaterialApp(
            title: 'APS',
            theme: themes.lightTheme,
            darkTheme: themes.darkTheme,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: BlocBuilder<AuthenticationBlocBloc, AuthenticationBlocState>(
              builder: (context, state) {
              if (state.status == AuthenticationStatus.authenticated) {
                return openPage(Pages.homePage, chatGroupsRepository, userRepository, state.user);
              } else if (state.status == AuthenticationStatus.unauthenticated) {
                return openPage(Pages.loginPage, null, userRepository, null);
              } else {
               return openPage(Pages.loginPage, null, userRepository, null);
              }
            })
			));
  }
}
