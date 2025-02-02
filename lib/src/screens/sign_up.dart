import 'package:aps/blocs/authentication_bloc/authentication_bloc_bloc.dart';
import 'package:aps/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/styles.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/screens/home.dart';
import 'package:aps/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() => _SignUp();
}

class _SignUp extends State<StatefulWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String errorMessage = "";
  RegExp emailValidator =
      RegExp(r"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$");
  RegExp passwordValidator = RegExp(
    r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&^#+=!._:;,.])[A-Za-z\d@$!%*?&^#+=!._:;,.]{8,}$");
  RegExp phoneNoValidator = RegExp(r"^\+[1-9]{1}[0-9]{3,14}$");
  late final Bloc signUpBloc;
  int selectedPersonas = 0;

  int validate(String email, String phoneNo, String password) {
    if (emailController.text.isEmpty) {
      return 0;
    } else if (!emailValidator.hasMatch(email)) {
      return 1;
    } else if (phoneNoController.text.isEmpty) {
      return 2;
    } else if (!phoneNoValidator.hasMatch(phoneNo)) {
      return 3;
    } else if (passwordController.text.isEmpty) {
      return 4;
    } else if (!passwordValidator.hasMatch(password)) {
      return 5;
    } else if (nameController.text.isEmpty) {
      return 6;
    }
    return 200;
  }

  @override
  void initState() {
    super.initState();
    signUpBloc = context.read<SignUpBloc>();
  }

  @override
  Widget build(BuildContext context) {
    const List<String> Personas = ["Student", "Parent", "Teacher"];
    return BlocListener<SignUpBloc, SignUpState>(listener: (context, state) {
      if (state is SignUpSuccess) {
        Navigator.pop(context);
        openPage(
            Pages.homePage,
            FirebaseChatGroupRepository(),
            context.read<SignUpBloc>().userRepository,
            context.read<AuthenticationBlocBloc>().state.user);
      } else if (state is SignUpFailure) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: customSnackbar(context, state.message)));
      }
    }, child: BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      if (state is SignUpProcess) {
        return loadingPage(context, "Please wait",
            "Our hamster is filling out your sign-up form");
      } else {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: backgroundColor,
            ),
            body: SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(children: [
                      const Image(image: AssetImage(loginPageImg)),
                      Text(signUpWelcomeTitle,
                          style: signUpPageHeadingStyle,
                          textAlign: TextAlign.center,),
                      const SizedBox(height: defaultColumnSpacingXs),
                      Text(signUpWelcomeSubtitle,
                          style: homePageSubheadingStyle,
                          textAlign: TextAlign.center,),
                      Form(
                        key: _formKey,
                        child: Padding(
                            padding: const EdgeInsets.all(defaultPaddingXs),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: defaultColumnSpacing),
                                TextFormField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 14.0),
                                    prefixIcon:
                                        Icon(Icons.email, size: inputIconsSize),
                                    labelText: loginEmail,
                                    hintText: loginEmail,
                                    // constraints: BoxConstraints(maxHeight: 45),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            inputBorderRadius)),
                                  ),
                                ),
                                const SizedBox(height: defaultColumnSpacingSm),
                                TextFormField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person_2_rounded),
                                    labelText: signUpName,
                                    hintText: signUpName,
                                    // constraints: BoxConstraints(maxHeight: 45),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            inputBorderRadius)),
                                  ),
                                ),
                                const SizedBox(height: defaultColumnSpacingSm),
                                TextFormField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  keyboardType: TextInputType.phone,
                                  controller: phoneNoController,
                                  decoration: const InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.phone_android_outlined),
                                    labelText: signUpPhoneNo,
                                    hintText: signUpPhoneNo,
                                    // constraints: BoxConstraints(maxHeight: 45),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            inputBorderRadius)),
                                  ),
                                ),
                                const SizedBox(height: defaultColumnSpacingSm),
                                TextFormField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.fingerprint),
                                      labelText: loginPassword,
                                      hintText: loginPassword,
                                      // constraints: const BoxConstraints(maxHeight: 45),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              inputBorderRadius)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() => obscurePassword =
                                              !obscurePassword);
                                        },
                                        icon: (obscurePassword)
                                            ? const Icon(Icons.visibility_off)
                                            : const Icon(
                                                Icons.remove_red_eye_rounded),
                                      )),
                                ),
                                const SizedBox(height: defaultColumnSpacingMd),
                                Text("Register as", style: homePageSectionParagraphStyle,),
                                const SizedBox(height: defaultColumnSpacingSm,),
                                Column(
                                  children: [
                                    Row(children: [
                                      Radio(
                                      activeColor: checkboxColor,
                                      value: 0,
                                      groupValue: selectedPersonas,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPersonas = value!;
                                        });
                                      }),
                                      Text(Personas[0], style: Theme.of(context).textTheme.bodyMedium, )
                                    ],),
                                    Row(children: [
                                      Radio(
                                      activeColor: checkboxColor,
                                      value: 1,
                                      groupValue: selectedPersonas,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPersonas = value!;
                                        });
                                      }),
                                      Text(Personas[1], style: Theme.of(context).textTheme.bodyMedium,)
                                    ],),
                                    Row(children: [
                                      Radio(
                                      activeColor: checkboxColor,
                                      value: 2,
                                      groupValue: selectedPersonas,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPersonas = value!;
                                        });
                                      }),
                                      Text(Personas[2], style: Theme.of(context).textTheme.bodyMedium,)
                                    ],)
                                  ],),
                                const SizedBox(height: defaultColumnSpacingXXL),
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          int errorStatus = validate(
                                              emailController.text,
                                              phoneNoController.text,
                                              passwordController.text);
                                          if (errorStatus != 200) {
                                            signUpBloc.add(SignUpWrongFields(
                                                message: errorMessages[
                                                    errorStatus]));
                                          } else if (signUpBloc.state
                                              is SignUpProcess) {
                                            return;
                                          } else {
                                            MyUser user = MyUser.empty;
                                            user = user.copyWith(
                                                email: emailController.text,
                                                phoneNo: phoneNoController.text,
                                                name: nameController.text.trim(),
                                                persona: Personas[selectedPersonas]
                                                );
                                            signUpBloc.add(SignUpRequired(
                                                user: user,
                                                password: passwordController.text,
                                              ));
                                          }
                                        }
                                      },
                                      child: Text(
                                        signUp.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ))
                              ],
                            )),
                      )
                    ]))));
      }
    }));
  }
}

Widget errorText(String errorMessage) {
  if (errorMessage.isEmpty) {
    return const SizedBox(height: 0);
  } else {
    return Text(errorMessage, style: const TextStyle(color: Colors.red));
  }
}
