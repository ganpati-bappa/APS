import 'dart:io';
import 'package:aps/src/constants/images.dart';
import 'package:aps/blocs/create_group_bloc/create_group_bloc.dart';
import 'package:aps/blocs/groups_bloc/groups_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGroup extends StatefulWidget {
  final List<MyUser> users;
  const CreateGroup({required this.users, super.key});

  @override
  State<CreateGroup> createState() => _CreateGroup();
}

class _CreateGroup extends State<CreateGroup> {
  final TextEditingController _textEditingController = TextEditingController();
  late MyUser admin;
  int selectedIndex = 0;
  String groupPhoto = "";

  @override
  Widget build(BuildContext context) {
    if (widget.users.isNotEmpty) {
      admin = widget.users[selectedIndex];
    }
    return BlocListener<CreateGroupBloc, CreateGroupState>(
        listener: (context, state) {
      if (state is GroupSuccessfulyCreated) {
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (state is GroupCreationFailed) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message)));
        context.read<CreateGroupBloc>().add(ResetCreateGroupInitialState());
      }
    }, child: BlocBuilder<CreateGroupBloc, CreateGroupState>(
            builder: (context, state) {
      if (state is GroupCreationInProgress) {
        return loadingPage(
            context,
            "Group creation: 99% complete...",
            "just waiting for that one person who always says ‘I’m here late",
            {"loadingAnimation": groupCreationLoading});
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            centerTitle: false,
            title: Text(createNewGroup,
                style: Theme.of(context).textTheme.displayLarge),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPaddingMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: () {
                          openBottomSheetImagePicker(context, (params) {
                            if (params["image"] != null) {
                              setState(() {
                                groupPhoto = params["image"];
                                Navigator.pop(context);
                              });
                            }
                          });
                        },
                        child: getGroupPhoto(context, groupPhoto)),
                    const SizedBox(height: defaultColumnSpacingLg),
                    TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.keyboard),
                        hintText: createGroupInputText,
                        constraints: BoxConstraints(maxHeight: 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: defaultColumnSpacingXXL,
                ),
                Text(selectGroupAdmin,
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(
                  height: defaultColumnSpacingLg,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: widget.users.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultColumnSpacingSm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ProfilePicture(
                                      name: widget.users[index].name,
                                      radius: userDpRadius,
                                      fontsize: 13),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.users[index].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium),
                                      Text(widget.users[index].email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall)
                                    ],
                                  ),
                                ],
                              ),
                              Radio(
                                  activeColor: Colors.black,
                                  value: index,
                                  groupValue: selectedIndex,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedIndex = value!;
                                      admin = widget.users[selectedIndex];
                                    });
                                  })
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
          persistentFooterButtons: [
            BlocBuilder<CreateGroupBloc, CreateGroupState>(
              builder: (context, state) {
                if (state is CreateGroupInitial) {
                  return ElevatedButton(
                      style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10))),
                      onPressed: () {
                        context.read<CreateGroupBloc>().add(CreateNewGroup(
                            users: widget.users,
                            groupName: _textEditingController.text.trim(),
                            admin: admin,
                            groupPhoto: groupPhoto));
                      },
                      child: Text(
                        createNewGroup,
                        style: Theme.of(context).textTheme.titleMedium,
                      ));
                } else {
                  return ElevatedButton(
                      style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10))),
                      onPressed: () {},
                      child: Text(
                        createNewGroup,
                        style: Theme.of(context).textTheme.titleMedium,
                      ));
                }
              },
            ),
          ],
        );
      }
    }));
  }
}

Widget getGroupPhoto(BuildContext context, String photo) {
  if (photo.isEmpty) {
    return Container(
      height: 100,
      width: 100,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
          borderRadius: sendButtonRadius,
          color: const Color.fromARGB(255, 205, 204, 204)),
      child: const Icon(
        Icons.camera_alt_rounded,
        size: 30,
      ),
    );
  } else {
    return GestureDetector(
      onTap: () {
        ImageProvider image = FileImage(File(photo));
        openFullPageImageViewer(context, image);
      },
      child: ClipOval(
        child:
            Image.file(height: 100, width: 100, fit: BoxFit.cover, File(photo)),
      ),
    );
  }
}
