import 'dart:io';

import 'package:aps/blocs/add_user_bloc/add_user_bloc.dart';
import 'package:aps/blocs/chats_bloc/chat_bloc.dart';
import 'package:aps/blocs/edit_group/edit_group_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/styles.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:lottie/lottie.dart';
import 'package:user_repository/user_repository.dart';

class EditGroup extends StatefulWidget {
  final Groups group;
  const EditGroup({required this.group, super.key});

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<bool> selected = [];
  late Groups group;
  bool isGroupDpUpdated = false;
  bool isLocalImage = false;
  bool isGroupEditing = false;
  late final Bloc editBloc;

  @override
  void initState() {
    super.initState();
    group = widget.group.copyWith();
    editBloc = context.read<EditGroupBloc>();
    _textEditingController.text = widget.group.groupName;
    editBloc.add(GroupUsersLoadingRequired(groupId: widget.group.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditGroupBloc, EditGroupState>(
        listenWhen: (context, state) => (state is GroupsIsEdited || state is GroupEditingFailedState),
        listener: (context, state) {
          if (state is GroupsIsEdited) {
            isGroupEditing = false;
            Navigator.pop(context, state.groups);
          } else if (state is GroupEditingFailedState) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
             ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: customSnackbar(context, state.message)));
            }
            editBloc.add(GroupUsersLoadingRequired(groupId: widget.group.id));
        },
        child: BlocBuilder<EditGroupBloc, EditGroupState>(
            buildWhen: (context, state) => state is EditingInProgress || state is EditGroupUserLoaded,
            builder: (context, state) {
              if (state is EditingInProgress) {
                return loadingPage(
                    context, classroomGroupsLoadingHeading, editGroupLoading);
              } else if (state is EditGroupUserLoaded) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: backgroundColor,
                    title: Text(
                      editGroupHeading,
                      style: pageHeadingStyle,
                    ),
                    centerTitle: false,
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPaddingMd),
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
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
                                        getGroupDp(
                                            group, 25, isLocalImage, context),
                                        Positioned(
                                            right: -2,
                                            bottom: -2,
                                            child: InkWell(
                                              onTap: () {
                                                openBottomSheetImagePicker(
                                                    context, (params) {
                                                  if (params["image"] != null) {
                                                    setState(() {
                                                      isGroupDpUpdated = true;
                                                      isLocalImage = true;
                                                      group = group.copyWith(
                                                          groupPhoto:
                                                              params["image"]);
                                                      Navigator.pop(context);
                                                    });
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color:  Color.fromARGB(255, 253, 120, 129),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(20))),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: defaultColumnSpacingLg),
                                  TextField(
                                    controller: _textEditingController,
                                    maxLength: 30,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.keyboard),
                                      hintText: createGroupInputText,
                                      contentPadding: EdgeInsets.all(20)
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: defaultColumnSpacingXXL,
                              ),
                              Text(editGroupSubheading,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.displayMedium),
                              const SizedBox(
                                height: defaultColumnSpacingLg,
                              ),
                              Expanded(child:
                                  BlocBuilder<EditGroupBloc, EditGroupState>(
                                      builder: (context, state) {
                                if (state is EditGroupUserLoaded) {
                                  if (selected.isEmpty) {
                                    for (MyUser user in state.users) {
                                      if (widget.group.users.any((groupUser) =>
                                          groupUser.id == user.id)) {
                                        selected.add(true);
                                      } else {
                                        selected.add(false);
                                      }
                                    }
                                  }
                                  return ListView.builder(
                                      itemCount: state.users.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: defaultColumnSpacingSm),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width - 100,
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        ProfilePicture(
                                                            name: state
                                                                .users[index].name.trim(),
                                                            radius: 23,
                                                            fontsize: 13),
                                                        const SizedBox(width: 10),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                state.users[index]
                                                                    .name,
                                                                style:
                                                                    Theme.of(context)
                                                                        .textTheme
                                                                        .labelMedium,
                                                                ),
                                                            Text(
                                                                state.users[index]
                                                                    .email,
                                                                style:
                                                                    Theme.of(context)
                                                                        .textTheme
                                                                        .labelSmall),
                                                            Text(state.users[index].persona!, style: groupAdminStyles,)
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Checkbox(
                                                    checkColor: Colors.white,
                                                    activeColor: Colors.black,
                                                    value: selected[index],
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        selected[index] =
                                                            !selected[index];
                                                      });
                                                    }),
                                              ],
                                            ));
                                      });
                                } else {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Lottie.asset(defaultLoading,
                                            width: 80, height: 80),
                                        const SizedBox(
                                          height: defaultColumnSpacing,
                                        ),
                                        Text(
                                          classroomGroupsLoadingHeading,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Users are loading",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }))
                            ])),
                  ),
                  persistentFooterButtons: [
                    BlocBuilder<EditGroupBloc, EditGroupState>(
                        builder: (context, state) {
                      if (state is EditGroupUserLoaded) {
                        List<String> selectedUsers = [];
                        selectedUsers = state.users
                            .asMap()
                            .entries
                            .where((entry) => selected[entry.key])
                            .map((entry) => entry.value.id)
                            .toList();
                        return ElevatedButton(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: defaultPaddingMd))),
                            onPressed: () {
                              bool isAdminPartOfGroup = false;
                              for (int index = 0;index < selected.length; index++) {
                                if (selected[index]) {
                                  isAdminPartOfGroup |= (state.users[index].persona! == "Admin");
                                  break;
                                }
                              }
                              if (_textEditingController.text !=
                                      widget.group.groupName ||
                                  checkUsersChanged(
                                      selectedUsers, widget.group.users) ||
                                  group.groupPhoto != widget.group.groupPhoto &&
                                      !isGroupEditing) {
                                if (isAdminPartOfGroup) {
                                  isGroupEditing = true;
                                editBloc.add(EditGroupsRequired(
                                    groupName: _textEditingController.text,
                                    users: selectedUsers,
                                    group: group,
                                    isGroupDpUpdated: isGroupDpUpdated));
                                } else {
                                  editBloc.add(const GroupEditingFailed(message: "Admin can not be removed from the group"));
                                }
                              }
                            },
                            child: Text(
                              editGroupHeading,
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                      } else if (state is EditGroupUserLoading) {
                        return ElevatedButton(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: defaultPaddingMd))),
                            onPressed: () {},
                            child: Text(
                              editGroupHeading,
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                      } else {
                        return ElevatedButton(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: defaultPaddingMd))),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              editGroupHeading,
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                      }
                    }),
                  ],
                );
              } else {
                return loadingPage(
                    context, classroomGroupsLoadingHeading, editGroupLoading);
              }
            }));
  }
}

Widget getGroupDp(
    Groups group, double size, bool isLocalImage, BuildContext context) {
  if (isLocalImage) {
    return GestureDetector(
      onTap: () {
        ImageProvider image = FileImage(File(group.groupPhoto!));
        openFullPageImageViewer(context, image);
      },
      child: ClipOval(
        child: Image.file(
            height: size * 4,
            width: size * 4,
            fit: BoxFit.cover,
            File(group.groupPhoto!)),
      ),
    );
  } else if (group.groupPhoto == null || group.groupPhoto!.trim().isEmpty) {
    return ProfilePicture(
      fontsize: size,
      name: group.groupName.trim(),
      radius: size * 2,
    );
  } else {
    return GestureDetector(
      onTap: () {
        CachedNetworkImageProvider image =
            CachedNetworkImageProvider(group.groupPhoto!);
        openFullPageImageViewer(context, image);
      },
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: group.groupPhoto!,
          height: size * 4,
          fit: BoxFit.cover,
          width: size * 4,
        ),
      ),
    );
  }
}

bool checkUsersChanged(List<String> selectedUsers, List<dynamic> users) {
  if (selectedUsers.length != users.length) {
    return true;
  }
  selectedUsers.sort();
  users.sort((dynamic user1, dynamic user2) {
    return (user1.id.toLowerCase().compareTo(user2.id.toLowerCase()));
  });
  bool res = true;
  for (int i = 0; i < users.length; i++) {
    res &= (selectedUsers[i] == users[i].id);
  }
  return res;
}
