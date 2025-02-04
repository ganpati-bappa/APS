import 'package:aps/blocs/authentication_bloc/authentication_bloc_bloc.dart';
import 'package:aps/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aps/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:aps/src/constants/styles.dart';
import 'package:aps/src/screens/guestHome.dart';
import 'package:aps/src/screens/sign_up.dart';
import 'package:aps/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<StatefulWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  String errorMessage = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late final Bloc signInBloc;
  late final UserRepository userRepository;

  @override
  void initState() {
    super.initState();
    signInBloc = context.read<SignInBloc>();
    userRepository = context.read<SignInBloc>().myUserRepository;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(listener: (context, state) {
      if (state is SignInSuccess) {
        while (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        openPage(Pages.homePage, FirebaseChatGroupRepository(), userRepository,
            context.read<AuthenticationBlocBloc>().state.user);
      } else if (state is SignInFailure) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: customSnackbar(context, state.message)));
      }
    }, child: BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        if (state is SignInProgress) {
          return loadingPage(context, "Logging you in !!",
              "Even the best password needs a moment");
        } else {
          return Scaffold(
              body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(defaultPaddingXs),
              child: Column(
                children: [
                  const Image(image: AssetImage(loginPageImg)),
                  Text(
                    loginPageWelcomeTitle,
                    style: signUpPageHeadingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: defaultColumnSpacingXs),
                  Text(
                    loginPageWelcomeSubtitle,
                    style: homePageSubheadingStyle,
                    textAlign: TextAlign.center,
                  ),
                  Form(
                    key: _formKey,
                    child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Column(
                          children: [
                            const SizedBox(height: defaultColumnSpacingSm),
                            TextFormField(
                              style: Theme.of(context).textTheme.bodyMedium,
                              controller: emailController,
                              decoration: const InputDecoration(
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.email),
                                labelText: loginEmail,
                                hintText: loginEmail,
                                // constraints: BoxConstraints(maxHeight: 45),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(inputBorderRadius)),
                              ),
                            ),
                            const SizedBox(height: defaultColumnSpacingMd),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.fingerprint),
                                  labelText: loginPassword,
                                  // constraints: const BoxConstraints(maxHeight: 45),
                                  hintText: loginPassword,
                                  border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(inputBorderRadius)),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                    icon: (obscurePassword)
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(
                                            Icons.remove_red_eye_rounded),
                                  )),
                            ),
                            // const SizedBox(height: defaultColumnSpacingSm),
                            // const Align(
                            //     alignment: Alignment.centerRight,
                            //     child: TextButton(
                            //         onPressed: null,
                            //         child: Text(forgotPassword,
                            //             style: TextStyle(
                            //                 color: Colors.blueAccent,
                            //                 fontSize: 12)))),
                            const SizedBox(height: defaultColumnSpacing),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    signInBloc.add(SignInRequired(
                                        email: emailController.text,
                                        password: passwordController.text));
                                  },
                                  child: Text(
                                    login.toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )),
                                const SizedBox(height: defaultColumnSpacingSm),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const GuestHome()));
                              },
                              child: Text.rich(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  const TextSpan(children: [
                                    TextSpan(text: checkOut),
                                    TextSpan(
                                        text: keyFeatures,
                                        style: TextStyle(color: Colors.blue)), 
                                    TextSpan(text: "and "),
                                    TextSpan(
                                        text: allCourses,
                                        style: TextStyle(color: Colors.blue))
                                  ])),
                            ),
                            const SizedBox(height: defaultColumnSpacingXXL),
                            TextButton(
                              onPressed: () {
                                if (signInBloc.state is SignInProgress) {
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) => SignUpBloc(
                                                myUserRepostiory:
                                                    userRepository),
                                            child: const SignUp(),
                                          )),
                                );
                              },
                              child: Text.rich(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  const TextSpan(children: [
                                    TextSpan(text: noAccount),
                                    TextSpan(
                                        text: createAccount,
                                        style: TextStyle(color: Colors.blue))
                                  ])),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
          ));
        }
      },
    ));
  }
}
