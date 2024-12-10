import 'dart:io';

import 'package:aps/blocs/chats_bloc/chat_bloc.dart';
import 'package:aps/blocs/edit_group/edit_group_bloc.dart';
import 'package:aps/blocs/groups_bloc/groups_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/screens/editGroup.dart';
import 'package:aps/src/screens/groups.dart';
import 'package:aps/src/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:user_repository/user_repository.dart';
import 'package:path/path.dart' as path;

class IndividualChatGroup extends StatefulWidget {
  final String groupStatus;
  final Groups group;

  const IndividualChatGroup(
      {required this.groupStatus, required this.group, super.key});

  @override
  State<IndividualChatGroup> createState() => _IndividualChatGroup();
}

class _IndividualChatGroup extends State<IndividualChatGroup> {
  late String groupName;
  String? groupStatus;
  String? groupPhoto;
  final TextEditingController _pdfNameController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _listScrollContainer = ScrollController();
  bool isMoreLoading = false;
  bool hasMoreMessagesToLoad = true;
  String _fileExtension = "";
  late final Bloc groupBloc;
  late final Bloc chatsBloc;
  Groups? localGroup;

  @override
  void initState() {
    super.initState();
    localGroup ??= widget.group;
    groupBloc = context.read<GroupsBloc>();
    chatsBloc = context.read<ChatsBloc>();
    groupName = widget.group.groupName;
    groupStatus = widget.groupStatus;
    groupPhoto = widget.group.groupPhoto!;
    _listScrollContainer.addListener(_scrollListeners);
    chatsBloc
        .add(ChatLoadingRequired(groupId: context.read<ChatsBloc>().groupRef));
  }

  void _scrollListeners() {
    if (_listScrollContainer.position.pixels ==
            _listScrollContainer.position.maxScrollExtent &&
        hasMoreMessagesToLoad &&
        !isMoreLoading) {
      chatsBloc.add(LoadMoreMessageRequired());
      setState(() {
        isMoreLoading = true;
      });
    }
  }

  void _openPdfFile(BuildContext context, String path, Function handler) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.black,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white60,
                  )),
              actions: [
                IconButton(
                    onPressed: () => handler(),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white60,
                    ))
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: path,
                    enableSwipe: true,
                    swipeHorizontal: true,
                    autoSpacing: true,
                    pageSnap: true,
                    onError: (error) {
                      print(error);
                    },
                    onPageError: (page, error) {
                      print('$page: ${error.toString()}');
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Container(
                        color: Colors.black,
                        child: TextField(
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          maxLength: 40,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          controller: _pdfNameController,
                          cursorColor: Colors.white54,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusColor: Colors.white54,
                              focusedBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.white,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 16),
                              hintText: pdfFileNameHint,
                              contentPadding: EdgeInsets.all(0)),
                        )),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatsBloc, ChatState>(
      listenWhen: (context, state) => state is ChatGroupUpdated || state is GroupDeleted,
      listener: (_, state) {
        if (state is ChatGroupUpdated) {
          setState(() {
            localGroup = state.group;
            groupName = localGroup!.groupName;
            groupStatus = getDateLabel(convertTimestampToDateTime(
                localGroup!.updatedTime.microsecondsSinceEpoch));
            groupPhoto = localGroup!.groupPhoto!;
          });
        }
        else if (state is GroupDeleted) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<ChatsBloc, ChatState>(builder: (context, state) {
        if (state is GroupDeletionInProgress) {
          return loadingPage(context, "Zzzzzhhhhh...", " Don’t mind the noise, just vacuuming your messages.", {"loadingAnimation": deleteLoading});
        } else {
          return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            titleSpacing: 0,
            title: Padding(
                padding: const EdgeInsets.only(
                    right: defaultPaddingXs,
                    top: defaultPaddingXs,
                    bottom: defaultPaddingXs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getGroupDp(context, groupName, groupPhoto, 10, false),
                    const SizedBox(width: defaultColumnSpacingSm),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Last updated on $groupStatus',
                            style: Theme.of(context).textTheme.bodyMedium)
                      ],
                    )
                  ],
                )),
            actions: [
              IconButton(
                  onPressed: () async {
                    final Groups updatedGroup = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                                  value:
                                      BlocProvider.of<EditGroupBloc>(context),
                                  child: EditGroup(group: localGroup!),
                                )));
                    setState(() {
                      localGroup = updatedGroup;
                      if (groupName != updatedGroup.groupName) {
                        groupName = localGroup!.groupName;
                      }
                      if (groupPhoto != updatedGroup.groupPhoto) {
                        groupPhoto = localGroup!.groupPhoto;
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
                  )),
                IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        actionsPadding: const EdgeInsets.only(right: defaultPaddingMd, bottom: defaultColumnSpacingSm, left: defaultPaddingMd),
                        title: Text("Delete $groupName", style: Theme.of(context).textTheme.labelLarge,),
                        content: Text("Are you sure you want to delete $groupName. As Group information can not be restored later."),
                        actions: [
                          TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 16),)),
                          TextButton(onPressed: () {
                            Navigator.pop(context);
                              chatsBloc.add(GroupDeletionRequired(group: localGroup!));
                          }, child: const Text("Delete", style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 223, 86, 76)),))
                        ],
                      );
                    });
                  }, 
                  icon: const Icon(Icons.delete, size: 20,))
            ],
          ),
          body: BlocListener<ChatsBloc, ChatState>(
            listener: (context, state) {
              if (state is NoMoreMessagesToLoad) {
                hasMoreMessagesToLoad = false;
                setState(() {
                  isMoreLoading = false;
                });
                // ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text(chatsLoadedCompletely)));
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  BlocBuilder<ChatsBloc, ChatState>(
                      buildWhen: (context, state) =>
                          state is ChatLoaded ||
                          state is ChatLoading ||
                          state is SendingMessage,
                      builder: (context, state) {
                        if (state is ChatLoading) {
                          return Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Lottie.asset(defaultLoading,
                                      width: 180, height: 180),
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
                                    chatsLoadingSubheading,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (state is ChatLoaded) {
                          if (state.messages.isNotEmpty) {
                            return Expanded(
                                child: ListView.builder(
                              controller: _listScrollContainer,
                              reverse: true,
                              itemCount: (isMoreLoading)
                                  ? state.messages.length + 1
                                  : state.messages.length,
                              itemBuilder: (context, index) {
                                if (index < state.messages.length) {
                                  return messageCard(
                                      state.messages[index],
                                      context,
                                      (index > 0)
                                          ? state.messages[index - 1].time
                                          : null);
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.black45,
                                    strokeWidth: 3,
                                  ));
                                }
                              },
                            ));
                          } else {
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Lottie.asset(emptyChat,
                                      width: 200, height: 200),
                                  const SizedBox(
                                    height: defaultColumnSpacing,
                                  ),
                                  Text(
                                    emptyChatsMessageHeading,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    emptyChatsMessageSubheading,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            );
                          }
                        } else if (state is SendingMessage) {
                          return Expanded(
                              child: ListView.builder(
                                  controller: _listScrollContainer,
                                  reverse: true,
                                  itemCount: (isMoreLoading)
                                      ? state.messages.length + 1
                                      : state.messages.length,
                                  itemBuilder: (context, index) {
                                    if (index < state.messages.length) {
                                      return messageCard(
                                          state.messages[index],
                                          context,
                                          (index > 0)
                                              ? state.messages[index - 1].time
                                              : null);
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.black45,
                                        strokeWidth: 3,
                                      ));
                                    }
                                  }));
                        } else {
                          return Expanded(
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset(defaultLoading,
                                    width: 180, height: 180),
                                const SizedBox(
                                  height: defaultColumnSpacing,
                                ),
                                Text(
                                  classroomGroupsLoadingHeading,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  chatsLoadingSubheading,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                          );
                        }
                      }),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPaddingXs),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(2, 4),
                                  ),
                                ], borderRadius: sendButtonRadius),
                                child: TextField(
                                  maxLines: 5,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  controller: _textEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: sendButtonRadius,
                                        borderSide: BorderSide.none),
                                    hoverColor: Colors.white,
                                    focusColor: Colors.white,
                                    filled: true,
                                    prefix: const SizedBox(
                                      width: 10,
                                    ),
                                    suffixIcon: SizedBox(
                                      width: 100,
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                FilePickerResult? result =
                                                    await FilePicker.platform
                                                        .pickFiles();
                                                if (result != null) {
                                                  String? filePath =
                                                      result.files.single.path;
                                                  _fileExtension =
                                                      path.extension(filePath!);
                                                  if (_fileExtension ==
                                                      ".pdf") {
                                                    setState(() {
                                                      _openPdfFile(
                                                          context, filePath,
                                                          () {
                                                        if (_pdfNameController
                                                            .text
                                                            .trim()
                                                            .isNotEmpty) {
                                                          context
                                                              .read<ChatsBloc>()
                                                              .add(SendPDF(
                                                                  filePath:
                                                                      filePath,
                                                                  fileName:
                                                                      _pdfNameController
                                                                          .text
                                                                          .trim()));
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    });
                                                  }
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.picture_as_pdf,
                                                color: Colors.grey,
                                              )),
                                          IconButton(
                                              onPressed: () async {
                                                openBottomSheetImagePicker(
                                                    context, (params) {
                                                  setState(() {
                                                    if (params["image"] !=
                                                        null) {
                                                      context
                                                          .read<ChatsBloc>()
                                                          .add(SendImage(
                                                              imagePath: params[
                                                                  "image"]));
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                              )),
                                        ],
                                      ),
                                    ),
                                    fillColor: Colors.white,
                                    hintText: inputChatText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                if (_textEditingController.text.isNotEmpty) {
                                  (context).read<ChatsBloc>().add(SendMessage(
                                      message:
                                          _textEditingController.text.trim()));
                                  _textEditingController.clear();
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 22, 16, 30),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(Icons.send, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
        }
      })
    );
  }
}

Widget messageCard(
    Messages message, BuildContext context, Timestamp? previousMessageTime) {
  bool bySender = message.sender?.id == context.read<GroupsBloc>().userRef.id;
  String dateLabel = "";
  if (bySender) {
    return Column(
      children: [
        isLabelRequired(""),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPaddingSm, vertical: defaultPaddingXs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getMessageLabels(message, bySender),
              getMessageByType(context, message, bySender, (params) {
                if (params["image"] != null) {
                  context.read<ChatsBloc>().add(StoreImageLocally(
                      filePath: params["image"], messageId: message.id!));
                }
              }),
            ],
          ),
        ),
      ],
    );
  } else {
    if (!message.readBy!.contains(context.read<GroupsBloc>().userRef)) {
      context.read<ChatsBloc>().add(
          UpdateMessageReadBy(messageId: message.id!, users: message.readBy!));
    }
    return Column(
      children: [
        isLabelRequired(dateLabel),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPaddingSm, vertical: defaultPaddingXs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getMessageByType(context, message, bySender, (params) {
                if (params["image"] != null) {
                  context.read<ChatsBloc>().add(StoreImageLocally(
                      filePath: params["image"], messageId: message.id!));
                }
              }),
              getMessageLabels(message, bySender)
            ],
          ),
        ),
      ],
    );
  }
}

Widget isLabelRequired(String dayChangedLabel) {
  if (dayChangedLabel.isEmpty) {
    return const SizedBox();
  } else {
    return Center(
      child: Text(dayChangedLabel),
    );
  }
}

Widget getGroupDp(BuildContext context, String groupName, String? groupPhoto,
    double size, bool isLocalImage) {
  if (isLocalImage) {
    return GestureDetector(
      onTap: () =>
          openFullPageImageViewer(context, FileImage(File(groupPhoto))),
      child: ClipOval(
        child: Image.file(
            height: size * 4,
            width: size * 4,
            fit: BoxFit.cover,
            File(groupPhoto!)),
      ),
    );
  } else if (groupPhoto == null || groupPhoto.trim().isEmpty) {
    return ProfilePicture(
      fontsize: size,
      name: groupName,
      radius: size * 2,
    );
  } else {
    return GestureDetector(
      onTap: () => openFullPageImageViewer(
          context, CachedNetworkImageProvider(groupPhoto)),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: groupPhoto,
          height: size * 4,
          fit: BoxFit.cover,
          width: size * 4,
        ),
      ),
    );
  }
}

Widget getMessageLabels(Messages message, bool bySender) {
  List<String> timeLabel =
      convertTimestampToString(message.time!.microsecondsSinceEpoch);
  if (bySender) {
    if (message.messageType!.contains("Loading")) {
      return const Padding(
        padding: EdgeInsets.only(
            right: defaultPadding, left: defaultColumnSpacingXs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Loading ...",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                ))
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(
            right: defaultPadding, left: defaultColumnSpacingXs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              getDateLabel(message.time!.toDate()),
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              timeLabel[1],
              style: const TextStyle(fontSize: 8),
            ),
          ],
        ),
      );
    }
  } else {
    if (message.messageType!.contains("Loading")) {
      return const Padding(
        padding: EdgeInsets.only(
            left: defaultPadding, right: defaultColumnSpacingXs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Loading",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 5),
            SizedBox(
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(
            left: defaultPadding, right: defaultColumnSpacingXs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              getDateLabel(message.time!.toDate()),
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              timeLabel[1],
              style: const TextStyle(fontSize: 8),
            ),
          ],
        ),
      );
    }
  }
}
