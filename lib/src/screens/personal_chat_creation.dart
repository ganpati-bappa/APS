import 'dart:io';

import 'package:aps/blocs/groups_bloc/groups_bloc.dart';
import 'package:aps/blocs/personal_chat_creation/personal_chat_creation_bloc.dart';
import 'package:aps/main.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/styles.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:lottie/lottie.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalChatCreation extends StatefulWidget {
  final Groups? group;
  final MyUser user;
  const PersonalChatCreation(
      {required this.group, required this.user, super.key});

  @override
  State<PersonalChatCreation> createState() => _PersonalChatCreationState();
}

class _PersonalChatCreationState extends State<PersonalChatCreation> {
  late final PersonalChatCreationBloc personalChatCreationbloc;

  @override
  void initState() {
    super.initState();
    personalChatCreationbloc = context.read<PersonalChatCreationBloc>();
    personalChatCreationbloc
        .add(PersonalChatFetchUsers(groups: widget.group, user: widget.user));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalChatCreationBloc, PersonalChatCreationState>(
      listener: (context, state) {
        if (state is PersonalChatGroupFetched) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => openPage(
                  Pages.chatsPage,
                  context.read<GroupsBloc>().chatGroupsRepository,
                  null,
                  null,
                  {"groups": state.groups, "user": widget.user}),
            ),
          );
        }
      },
      child: BlocBuilder<PersonalChatCreationBloc, PersonalChatCreationState>(
        builder: (context, state) {
          if (state is FetchingPersonalChat) {
            return loadingPage(context, "Fetching Your Personal Chat",
                "Our hamster is overworked, Please wait patiently");
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: backgroundColor,
                title: Text(
                  "Personal Chat",
                  style: pageHeadingStyle,
                ),
              ),
              body: BlocBuilder<PersonalChatCreationBloc,
                  PersonalChatCreationState>(builder: (context, state) {
                if (state is PersonalChatCreationLoaded) {
                  bool isNotEmpty = false;
                  state.users.forEach((key, value) {
                    isNotEmpty |= value.isNotEmpty;
                  });
                  if (!isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(emptyChat, width: 200, height: 200),
                          const SizedBox(
                            height: defaultColumnSpacing,
                          ),
                          Text(
                            classroomGroupsLoadingHeading,
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            classroomGroupsLoadingSubheading,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    List<dynamic> users = [];
                    state.users.forEach((key, value) {
                      if (key == "Student" && value.isNotEmpty) {
                        users.add({"type": "Student"});
                        users.addAll(value);
                      }
                      if (key == "Parent" && value.isNotEmpty) {
                        users.add({"type": "Parent"});
                        users.addAll(value);
                      }
                      if (key == "Teacher" && value.isNotEmpty) {
                        users.add({"type": "Teacher"});
                        users.addAll(value);
                      }
                    });
                    return Padding(
                        padding: const EdgeInsets.only(
                            left: defaultColumnSpacing,
                            bottom: defaultColumnSpacing,
                            top: defaultColumnSpacing),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                              itemCount: users.length,
                              itemBuilder: (context, index) => buildUserChatRow(
                                  users[index], context, widget.user)),
                        ));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
            );
          }
        },
      ),
    );
  }
}

Widget buildUserChatRow(dynamic user, BuildContext context, MyUser curUser) {
  if (user is MyUser) {
    return InkWell(
      onTap: () {
        context
            .read<PersonalChatCreationBloc>()
            .add(FetchPersonalChat(curUser: curUser, sender: user));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: defaultColumnSpacingSm),
        child: Row(
          children: [
            getUserDp(user, context),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width-100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.labelMedium),
                  Text(user.email, style: Theme.of(context).textTheme.labelSmall)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: defaultColumnSpacingMd, top: defaultColumnSpacing),
      child: Text(
        '${user["type"]}s',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

Widget getUserDp(MyUser user, BuildContext context) {
  if (user.picture == null || user.picture!.trim().isEmpty) {
    return ProfilePicture(
      radius: 20,
      name: user.name.trim(),
      fontsize: 12,
    );
  } else {
    return GestureDetector(
      onTap: () =>
          openFullPageImageViewer(context, CachedNetworkImageProvider(user.picture!)),
      child: ClipOval(
        child: CachedNetworkImage(
            height: 40, width: 40, fit: BoxFit.cover, imageUrl: user.picture!,),
      ),
    );
  }
}
