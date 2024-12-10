import 'package:aps/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(const UserProfileLoadingRequired());
  }

  RegExp phoneNoValidator = RegExp(r"^\+[1-9]{1}[0-9]{3,14}$");

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserLoggedOut) {
          dynamic localRepo = (context).read<UserProfileBloc>().userRepository;
          while (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  openPage(Pages.loginPage, null, localRepo, null)));
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.all(defaultPaddingXs),
            child: Text(userProfile,
                style: Theme.of(context).textTheme.displayLarge),
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
                        getUserProfileDp(context,state.user, 25),
                        Positioned(
                            right: -2,
                            bottom: -2,
                            child: InkWell(
                              onTap: () {
                                openBottomSheetImagePicker(context, (params) {
                                  if (params["image"] != null) {
                                    context.read<UserProfileBloc>().add(
                                        UploadImageRequired(
                                            imagePath:
                                                params["image"] as String));
                                    Navigator.pop(context);
                                  }
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
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
                            bottom:
                                BorderSide(color: Colors.grey, width: 1.0))),
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
                                      color: Colors.black54, fontSize: 12)),
                              Text(
                                name,
                                style: Theme.of(context).textTheme.bodyMedium,
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
                                  context.read<UserProfileBloc>().add(UpdateUserProfileRequired(field: "name", value: params["text"]));
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
                            bottom:
                                BorderSide(color: Colors.grey, width: 1.0))),
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
                                      color: Colors.black54, fontSize: 12)),
                              Text(
                                phoneNo,
                                style: Theme.of(context).textTheme.bodyMedium,
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
                                "type": TextInputType.number
                              }, (params) {
                                if (params["text"] != null) {
                                  if (phoneNoValidator
                                      .hasMatch(params["text"])) {
                                        setState(() {
                                          phoneNo = params["text"];
                                          context.read<UserProfileBloc>().add(UpdateUserProfileRequired(field: "phoneNo", value: params["text"]));
                                          Navigator.pop(context);
                                        });
                                      }
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
                                      color: Colors.black54, fontSize: 12)),
                              Text(
                                state.user.email,
                                style: Theme.of(context).textTheme.bodyMedium,
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
                              style: GoogleFonts.ptSerif(
                                  color: const Color.fromARGB(255, 240, 74, 62),
                                  fontSize: 16),
                            ))
                      ],
                    ),
                  )
                ],
              );
            } else if (state is UserProfileLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(loadingAnimation, width: 200, height: 200),
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
                    Lottie.asset(loadingAnimation, width: 200, height: 200),
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
      ),
    );
  }
}

Widget getUserProfileDp(BuildContext context, MyUser user, double size) {
  if (user.picture == null || user.picture!.trim().isEmpty) {
    return ProfilePicture(
      fontsize: size,
      name: user.name,
      radius: size * 2,
    );
  } else {
    return GestureDetector(
      onTap: () {
        CachedNetworkImageProvider image = CachedNetworkImageProvider(user.picture!);
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
