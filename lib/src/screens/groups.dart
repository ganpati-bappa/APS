import 'dart:io';

import 'package:aps/blocs/add_user_bloc/add_user_bloc.dart';
import 'package:aps/blocs/groups_bloc/groups_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/screens/add_users.dart';
import 'package:aps/src/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:lottie/lottie.dart';
import 'package:user_repository/user_repository.dart';

class AllGroups extends StatelessWidget {
  const AllGroups({super.key});

  @override
  Widget build(BuildContext context) {
    final Bloc groupsBloc = context.read<GroupsBloc>();    
    groupsBloc.add(ChatGroupsLoadingRequired());
    Map<String, Messages?> lastMessages = {};
    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Padding(
              padding: const EdgeInsets.all(defaultPaddingXs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: defaultColumnSpacingSm),
                  Text(groupsHeading,
                      style: Theme.of(context).textTheme.labelLarge)
                ],
              )),
          actions: [
            IconButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BlocProvider(
                                create: (context) => AddUserBloc(
                                    chatGroupsRepository: (context)
                                        .read<GroupsBloc>()
                                        .chatGroupsRepository),
                                child: const AddUsers(),
                              )));
                  groupsBloc.add(ChatGroupsLoadingRequired());
                },
                icon: const Icon(
                  Icons.add,
                )),
          ],
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
            buildWhen: (context, state) => (state is GroupsLoading ||
                state is GroupsLoaded ||
                state is GroupsLoadedByUpdating),
            builder: (context, state) {
              if (state is GroupsLoading) {
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
              } else if (state is GroupsLoaded) {
                if (state.groups.isNotEmpty) {
                  state.groups.map((group) {
                    lastMessages[group.id] = Messages.empty();
                  });
                  return Container(
                    margin: const EdgeInsets.only(top: defaultPaddingXs),
                    child: ListView.builder(
                        itemCount: state.groups.length,
                        itemBuilder: (context, index) =>
                            chatGroups(index, state.groups[index], context, groupsBloc, lastMessages)),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(emptyGroup,
                            height: 200, width: 200, repeat: false),
                        const SizedBox(
                          height: defaultColumnSpacing,
                        ),
                        Text(
                          classroomGroupsEmptyStateHeading,
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          classroomGroupsEmptyStateSubheading,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
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
              }
            }));
  }
}

Widget chatGroups(int index, Groups groups, BuildContext context, Bloc groupsBloc, Map<String, Messages?> lastMessages) {
  groupsBloc
      .add(GetLastMessage( groupId: groups.id));
  return InkWell(
    onTap: () async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => openPage(
                Pages.chatsPage,
                context.read<GroupsBloc>().chatGroupsRepository,
                null,
                null,
                {"groups": groups}),
          ),
        );
        groupsBloc.add(GetLastMessage(groupId: groups.id));
      });
    },
    child: Container(
      padding: const EdgeInsets.all(defaultPaddingXs),
      height: 60,
      margin: const EdgeInsets.only(
          left: defaultPaddingSm,
          right: defaultPaddingSm,
          bottom: defaultPaddingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getGroupDp(groups.groupName, groups.groupPhoto, 14, false),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(groups.groupName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(
                  height: 3,
                ),
                Text('Managed by: ${groups.adminName}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall),
                // BlocBuilder<GroupsBloc, GroupsState>(
                //   buildWhen: (context, state) => state is LastMessageFetched,
                //   builder: (context, state) => (lastMessages[groups.id] != null) ? Text(lastMessages[groups.id]!.message) : const SizedBox(height: 0,))
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getTextStatus(groups.updatedTime.microsecondsSinceEpoch),
              const SizedBox(
                height: defaultColumnSpacingXs,
              ),
              BlocBuilder<GroupsBloc, GroupsState>(
                buildWhen: (context, state) => (state is LastMessageFetched),
                builder: (context, state) {
                  if (state is LastMessageFetched) {
                    if (state.lastMessage!.groupId!.id == groups.id) {
                       lastMessages[groups.id] = state.lastMessage;
                      return getUpdateAlert(
                        lastMessages[groups.id], context.read<GroupsBloc>().userRef);
                    } else {
                      return getUpdateAlert(
                        lastMessages[groups.id], context.read<GroupsBloc>().userRef);
                    }
                  } else {
                    return const SizedBox(
                      height: 0,
                      width: 0,
                    );
                  }
                },
              )
            ],
          ),
        ],
      ),
    ),
  );
}

Widget getUpdateAlert(Messages? lastMessage, DocumentReference userRef) {
  if (lastMessage == null ||
      lastMessage.readBy == null ||
      lastMessage.sender == null) {
    return const SizedBox();
  }
  List<dynamic> readBy = lastMessage.readBy!;
  DocumentReference senderRef = lastMessage.sender!;
  if (senderRef == userRef || readBy.contains(userRef)) {
    return const SizedBox(
      height: 0,
      width: 0,
    );
  } else {
    return Container(
      height: 10,
      width: 10,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, color: Color.fromARGB(255, 57, 173, 61)),
    );
  }
}

Widget getGroupDp(
    String groupName, String? groupPhoto, double size, bool isLocalImage) {
  if (isLocalImage) {
    return ClipOval(
      child: Image.file(
          height: size * 10 / 3,
          width: size * 10 / 3,
          fit: BoxFit.cover,
          File(groupPhoto!)),
    );
  } else if (groupPhoto == null || groupPhoto.trim().isEmpty) {
    return ProfilePicture(
      fontsize: size,
      name: groupName,
      radius: size * 5 / 3,
    );
  } else {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: groupPhoto,
        height: size * 10 / 3,
        fit: BoxFit.cover,
        width: size * 10 / 3,
      ),
    );
  }
}
