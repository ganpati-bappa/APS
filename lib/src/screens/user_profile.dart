import 'package:aps/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/styles.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:user_repository/user_repository.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfile();
}

class _UserProfile extends State<StatefulWidget> {
  bool obscurePassword = true;
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obscurePassword = true;
    context.read<UserProfileBloc>().add(const UserProfileLoadingRequired());
  }

  RegExp phoneNoValidator = RegExp(r"^\+[1-9]{1}[0-9]{3,14}$");

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listenWhen: (previous, state) =>
          (state is UserLoggedOut || state is FieldUpdationFailed),
      listener: (context, state) {
        if (state is UserLoggedOut) {
          dynamic localRepo = (context).read<UserProfileBloc>().userRepository;
          while (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  openPage(Pages.loginPage, null, localRepo, null)));
        } else if (state is FieldUpdationFailed) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: customSnackbar(context, state.message)));
          context
              .read<UserProfileBloc>()
              .add(const UserProfileLoadingRequired());
        }
      },
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        buildWhen: (previous, current) => true,
        builder: (context, state) {
          if (state is UserDeletionInProgress) {
            return loadingPage(context, "GoodBye user👋",
                "Your account is being deleted by a hamster. Don’t worry, he’s a professional, and he’s got this covered!");
          } else {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: backgroundColor,
                centerTitle: false,
                title: Padding(
                  padding: const EdgeInsets.all(defaultPaddingXs),
                  child: Text(userProfile, style: pageHeadingStyle),
                ),
              ),
              body: BlocBuilder<UserProfileBloc, UserProfileState>(
                buildWhen: (context, state) => state is UserProfileLoaded,
                builder: (context, state) {
                  if (state is UserProfileLoaded) {
                    String phoneNo = state.user.phoneNo;
                    String name = state.user.name;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              getUserProfileDp(context, state.user, 25),
                              Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: InkWell(
                                    onTap: () {
                                      openBottomSheetImagePicker(context,
                                          (params) {
                                        if (params["image"] != null) {
                                          context.read<UserProfileBloc>().add(
                                              UploadImageRequired(
                                                  imagePath: params["image"]
                                                      as String));
                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 253, 120, 129),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: defaultPaddingSm,
                              right: defaultPaddingSm,
                              bottom: defaultPaddingSm,
                              top: defaultPaddingSm),
                          margin: const EdgeInsets.all(defaultPaddingXs),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 1.0))),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_2_rounded,
                                size: 30,
                                color: Color.fromARGB(255, 127, 127, 127),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(signUpName,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                    Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    )
                                  ],
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    openBottomSheetFieldEditor({
                                      "context": context,
                                      "field": signUpName,
                                      "value": name,
                                      "type": TextInputType.text
                                    }, (params) {
                                      if (params["text"] != null) {
                                        context.read<UserProfileBloc>().add(
                                            UpdateUserProfileRequired(
                                                field: "name",
                                                value: params["text"]));
                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: defaultPaddingSm,
                              right: defaultPaddingSm,
                              bottom: defaultPaddingSm,
                              top: defaultPaddingSm),
                          margin: const EdgeInsets.all(defaultPaddingXs),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 1.0))),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_box,
                                size: 30,
                                color: Color.fromARGB(255, 127, 127, 127),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Persona",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                    Text(
                                      state.user.persona!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: defaultPaddingSm,
                              right: defaultPaddingSm,
                              bottom: defaultPaddingSm,
                              top: defaultPaddingSm),
                          margin: const EdgeInsets.all(defaultPaddingXs),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 1.0))),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone_rounded,
                                size: 30,
                                color: Color.fromARGB(255, 127, 127, 127),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(signUpPhoneNo,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                    Text(
                                      phoneNo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    )
                                  ],
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    openBottomSheetFieldEditor({
                                      "context": context,
                                      "field": signUpPhoneNo,
                                      "value": phoneNo,
                                      "type": TextInputType.phone
                                    }, (params) {
                                      if (params["text"] != null) {
                                        phoneNo = params["text"];
                                        context.read<UserProfileBloc>().add(
                                            UpdateUserProfileRequired(
                                                field: "phoneNo",
                                                value: phoneNo));
                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: defaultPaddingSm,
                              right: defaultPaddingSm,
                              bottom: defaultPaddingSm,
                              top: defaultPaddingSm),
                          margin: const EdgeInsets.all(defaultPaddingXs),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email_rounded,
                                size: 30,
                                color: Color.fromARGB(255, 127, 127, 127),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(loginEmail,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                    Text(
                                      state.user.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  left: defaultPaddingSm,
                                  right: defaultPaddingSm,
                                  bottom: defaultPaddingSm,
                                  top: defaultPaddingSm),
                              margin: const EdgeInsets.all(defaultPaddingXs),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    size: 20,
                                    color: Color.fromARGB(255, 240, 74, 62),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        context
                                            .read<UserProfileBloc>()
                                            .add(const SignOutRequired());
                                      },
                                      child: Text(
                                        signOut,
                                        style: GoogleFonts.crimsonText(
                                            color: const Color.fromARGB(
                                                255, 240, 74, 62),
                                            fontSize: 16),
                                      ))
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: defaultPaddingSm,
                                  right: defaultPaddingSm,
                                  bottom: defaultPaddingSm,
                                  top: defaultPaddingSm),
                              margin: const EdgeInsets.all(defaultPaddingXs),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Color.fromARGB(255, 240, 74, 62),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext _) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                backgroundColor:
                                                    backgroundColor,
                                                actionsPadding: const EdgeInsets
                                                    .only(
                                                    right: defaultPaddingMd,
                                                    bottom:
                                                        defaultColumnSpacingSm,
                                                    left: defaultPaddingMd),
                                                title: Text(
                                                  "Delete ${state.user.name}'s Profile",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: pageHeadingStyle,
                                                ),
                                                content: SizedBox(
                                                  height: 150,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        const Text(
                                                            "Are you sure you want to delete your account. As all the personal information will be wiped out and can't be retrieved later"),
                                                        const SizedBox(height: 20,),
                                                        TextFormField(
                                                          controller:
                                                              passwordController,
                                                          obscureText:
                                                              obscurePassword,
                                                          decoration:
                                                              const InputDecoration(
                                                                  prefixIcon:
                                                                       Icon(Icons
                                                                          .fingerprint),
                                                                  labelText:
                                                                      retypePassword,
                                                                  constraints:  BoxConstraints(maxHeight: 100),
                                                                  hintText:
                                                                      retypePassword,
                                                                  border:  OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                                  inputBorderRadius)),
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(_);
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 16),
                                                      )),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(_);
                                                        context
                                                            .read<
                                                                UserProfileBloc>()
                                                            .add(
                                                                UserProfileDeletionRequired(
                                                                    user: state
                                                                        .user, password: passwordController.text));
                                                      },
                                                      child: const Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    223,
                                                                    86,
                                                                    76)),
                                                      ))
                                                ],
                                              );
                                            });
                                      },
                                      child: Text(
                                        deleteUser,
                                        style: GoogleFonts.crimsonText(
                                            color: const Color.fromARGB(
                                                255, 240, 74, 62),
                                            fontSize: 16),
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  } else if (state is UserProfileLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(loadingAnimation,
                              width: 200, height: 200),
                          const SizedBox(
                            height: defaultColumnSpacing,
                          ),
                          Text(
                            userProfileLoadingHeading,
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            userProfileLoadingSubheading,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(loadingAnimation,
                              width: 200, height: 200),
                          const SizedBox(
                            height: defaultColumnSpacing,
                          ),
                          Text(
                            userProfileLoadingHeading,
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            userProfileLoadingSubheading,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

Widget getUserProfileDp(BuildContext context, MyUser user, double size) {
  if (user.picture == null || user.picture!.trim().isEmpty) {
    return ProfilePicture(
      fontsize: size,
      name: user.name.trim(),
      radius: size * 2,
    );
  } else {
    return GestureDetector(
      onTap: () {
        CachedNetworkImageProvider image =
            CachedNetworkImageProvider(user.picture!);
        openFullPageImageViewer(context, image);
      },
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: user.picture!,
          height: size * 4,
          fit: BoxFit.cover,
          width: size * 4,
        ),
      ),
    );
  }
}
