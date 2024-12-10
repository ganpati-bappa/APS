import 'dart:io';

import 'package:aps/blocs/chats_bloc/chat_bloc.dart';
import 'package:aps/blocs/edit_group/edit_group_bloc.dart';
import 'package:aps/blocs/groups_bloc/groups_bloc.dart';
import 'package:aps/blocs/home_bloc/home_bloc.dart';
import 'package:aps/blocs/pdf_viewer_bloc/pdf_viewer_bloc.dart';
import 'package:aps/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aps/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:aps/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/screens/chat_groups.dart';
import 'package:aps/src/screens/home.dart';
import 'package:aps/src/screens/login.dart';
import 'package:aps/src/screens/pdf_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:user_repository/user_repository.dart';

String getDateLabel(DateTime timestamp) {
  String dayLabel = "";
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));

  if (timestamp.isAfter(today)) {
    dayLabel = "Today";
  } else if (timestamp.isAfter(yesterday) && timestamp.isBefore(today)) {
    dayLabel = "Yesterday";
  } else {
    dayLabel = "${timestamp.day}/${timestamp.month}/${timestamp.year}";
  }
  return dayLabel;
}

DateTime convertTimestampToDateTime(int timestamp) {
  return DateTime.fromMicrosecondsSinceEpoch(timestamp);
}

List<String> convertTimestampToString(int timestamp) {
  // Convert the timestamp to DateTime
  DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp);

  // Format the DateTime to a string
  String formattedTime = DateFormat('yyyy-MM-dd kk:mm').format(dateTime);
  return formattedTime.split(' ');
}

Widget getTextStatus(int timestamp) {
  if (getDateLabel(convertTimestampToDateTime(timestamp)) != "Today") {
    return Text(getDateLabel(convertTimestampToDateTime(timestamp)),
        style: GoogleFonts.ptSerif(fontWeight: FontWeight.w400, fontSize: 12));
  } else {
    return Text(convertTimestampToString(timestamp)[1],
        style: GoogleFonts.ptSerif(fontWeight: FontWeight.w400, fontSize: 12));
  }
}

Future<XFile?> openImagePicker(BuildContext context, ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
      source: source, maxHeight: 800, maxWidth: 800, imageQuality: 100);
  if (image != null) {
    return image;
  }
  return null;
}

enum Pages {
  loginPage,
  homePage,
  signUpPage,
  chatsPage,
  createGroupPage,
  addUsersPage,
  userProfilePage
}

MultiBlocProvider openPage(
    Pages pages,
    ChatGroupsRepository? chatGroupsRepository,
    UserRepository? userRepository,
    User? user,
    [Map<String, dynamic>? params]) {
  if (pages == Pages.homePage) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GroupsBloc>(
            create: (context) => GroupsBloc(
                chatGroupsRepository: chatGroupsRepository!, user: user)),
        BlocProvider<UserProfileBloc>(
          create: (context) => UserProfileBloc(userRepository: userRepository!),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(userRepository: userRepository!),
        )
      ],
      child: const Home(),
    );
  } else if (pages == Pages.loginPage) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(myUserRepository: userRepository!),
        ),
      ],
      child: const Login(),
    );
  } else if (pages == Pages.chatsPage) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatsBloc>(
            create: (context) => ChatsBloc(
                myChatRepository: chatGroupsRepository!,
                groupRef:
                    context.read<GroupsBloc>().groupRef(params!["groups"].id),
                senderRef: context.read<GroupsBloc>().userRef)),
        BlocProvider<EditGroupBloc>(
          create: (context) => EditGroupBloc(
              chatGroupsRepository:
                  context.read<GroupsBloc>().chatGroupsRepository),
        )
      ],
      child: IndividualChatGroup(
          groupStatus: getDateLabel(convertTimestampToDateTime(
              params!["groups"].updatedTime.microsecondsSinceEpoch)),
          group: params["groups"]),
    );
  } else {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(myUserRepository: userRepository!),
        ),
        BlocProvider<SignUpBloc>(
            create: (context) => SignUpBloc(myUserRepostiory: userRepository!))
      ],
      child: const Login(),
    );
  }
}

void openBottomSheetFieldEditor(Map<String, dynamic> params, Function handler) {
  final TextEditingController controller = TextEditingController();
  controller.text = params["value"];
  TextInputType type;
  if (params["type"] != null) {
    type = params["type"];
  } else {
    type = TextInputType.text;
  }
  showModalBottomSheet(
      context: params["context"],
      builder: (context) {
        return SafeArea(
          child: Container(
            height: 180 + MediaQuery.of(context).viewInsets.bottom,
            decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: bottomSheetRadius, topRight: bottomSheetRadius)),
            padding: const EdgeInsets.all(defaultPaddingMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit your ${params['field']}",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(
                  height: 25,
                ),
                TextField(
                  controller: controller,
                  maxLines: 1,
                  keyboardType: type,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                      isCollapsed: true,
                      constraints: BoxConstraints(maxHeight: 30),
                      contentPadding: EdgeInsets.all(0),
                      prefixIcon: Icon(
                        Icons.keyboard,
                        color: Colors.black54,
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black54, width: 2))),
                ),
                const SizedBox(
                  height: 18,
                ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: ElevatedButton(
                      onPressed: () {
                        handler({"text": controller.text});
                      },
                      child: Text(
                        save,
                        style: Theme.of(context).textTheme.titleMedium,
                      )),
                )
              ],
            ),
          ),
        );
      });
}

void openBottomSheetImagePicker(BuildContext context, [Function? handler]) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: bottomSheetRadius, topRight: bottomSheetRadius)),
          height: 200,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(photoPick,
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          XFile? file = await openImagePicker(
                              context, ImageSource.camera);
                          handler!({
                            "image": file!.path,
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: sendButtonRadius,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.black87,
                            size: 25,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(camera,
                          style: Theme.of(context).textTheme.headlineSmall)
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          XFile? file = await openImagePicker(
                              context, ImageSource.gallery);
                          handler!({
                            "image": file!.path,
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: sendButtonRadius,
                          ),
                          child: const Icon(
                            Icons.browse_gallery_outlined,
                            color: Colors.black87,
                            size: 25,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(gallery,
                          style: Theme.of(context).textTheme.headlineSmall)
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      });
}

Widget getMessageByType(BuildContext context, Messages message, bool bySender,
    [Function? handler]) {
  if (bySender) {
    if (message.messageType == "text" || message.messageType == "textLoading") {
      return Flexible(
          child: Container(
        decoration: const BoxDecoration(
            color: userChatColor,
            borderRadius: BorderRadius.all(inputBorderRadius)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultColumnSpacingMd,
              vertical: defaultColumnSpacingSm),
          child: Text(
            message.message,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ));
    } else if (message.messageType == "pdf") {
      return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlocProvider<PdfViewerBloc>(
                          create: (context) => PdfViewerBloc(),
                          child: PDFViewer(
                              pdfUrl: message.url!, pdfName: message.message),
                        )));
          },
          child: Container(
            decoration: const BoxDecoration(
                color: userChatColor,
                borderRadius: BorderRadius.all(inputBorderRadius)),
            padding: const EdgeInsets.symmetric(
                horizontal: defaultColumnSpacingMd,
                vertical: defaultColumnSpacingSm),
            child: Row(
              children: [
                Image.asset(
                  pdfIcons,
                  height: 36,
                  width: 36,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 200),
                        child: Text(message.message,
                            style: Theme.of(context).textTheme.titleMedium)),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 200),
                        child: const Text(
                          "PDF uploaded by You",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w100,
                              color: Colors.white54),
                        ))
                  ],
                )
              ],
            ),
          ));
    } else if (message.messageType == "pdfLoading") {
      return Container(
        decoration: const BoxDecoration(
            color: userChatColor,
            borderRadius: BorderRadius.all(inputBorderRadius)),
        padding: const EdgeInsets.symmetric(
            horizontal: defaultColumnSpacingMd,
            vertical: defaultColumnSpacingSm),
        child: Row(
          children: [
            const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: backgroundColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 200),
                    child: Text(message.message,
                        style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(
                  height: 7,
                ),
                Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 200),
                    child: const Text(
                      "Uploading PDF ...",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w100,
                          color: Colors.white54),
                    ))
              ],
            )
          ],
        ),
      );
    } else if (message.messageType == "imageLoading") {
      return Container(
        decoration: const BoxDecoration(
            color: userChatColor,
            borderRadius: BorderRadius.all(inputBorderRadius)),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(inputBorderRadius),
                child: Image.file(
                  File(
                    message.message,
                  ),
                  width: 270,
                  height: 300,
                  fit: BoxFit.cover,
                ))),
      );
    } else {
      File imageFile = File(message.message);
      bool imageFileExists = imageFile.existsSync();
      if (imageFileExists) {
        return Flexible(
            child: GestureDetector(
                onTap: () =>
                    openFullPageImageViewer(context, FileImage(imageFile)),
                child: Container(
                    decoration: const BoxDecoration(
                        color: userChatColor,
                        borderRadius: BorderRadius.all(inputBorderRadius)),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(inputBorderRadius),
                            child: Image.file(
                              imageFile,
                              width: 270,
                              height: 300,
                              fit: BoxFit.cover,
                            ))))));
      } else {
        CachedNetworkImageProvider image =
            CachedNetworkImageProvider(message.url!);
        handler!({"image": message.url!});
        return Flexible(
            child: GestureDetector(
          onTap: () => openFullPageImageViewer(context, image),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 300),
            decoration: const BoxDecoration(
                color: userChatColor,
                borderRadius: BorderRadius.all(inputBorderRadius)),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(inputBorderRadius),
                    child: Image(
                      image: image,
                      width: 270,
                      height: 300,
                      fit: BoxFit.cover,
                    ))),
          ),
        ));
      }
    }
  } else {
    if (message.messageType == "text") {
      return Flexible(
          child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(inputBorderRadius)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.senderName,
                  style: GoogleFonts.ptSerif(
                      color: userColors[message.senderName.length % 5],
                      fontSize: 16)),
              const SizedBox(
                height: defaultColumnSpacingXs,
              ),
              Text(
                message.message,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ),
      ));
    } else if (message.messageType == "pdf") {
      return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlocProvider<PdfViewerBloc>(
                          create: (context) => PdfViewerBloc(),
                          child: PDFViewer(
                              pdfUrl: message.url!, pdfName: message.message),
                        )));
          },
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(inputBorderRadius)),
            padding: const EdgeInsets.symmetric(
                horizontal: defaultColumnSpacingMd,
                vertical: defaultColumnSpacingSm),
            child: Row(
              children: [
                Image.asset(
                  pdfIcons,
                  height: 36,
                  width: 36,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 200),
                        child: Text(
                          message.message,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 200),
                        child: Text(
                          "PDF uploaded by ${message.senderName}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w100),
                        ))
                  ],
                )
              ],
            ),
          ));
    } else {
      File imageFile = File(message.message);
      bool imageFileExists = imageFile.existsSync();
      if (imageFileExists) {
        return Flexible(
            child: GestureDetector(
                onTap: () =>
                    openFullPageImageViewer(context, FileImage(imageFile)),
                child: Container(
                    padding: const EdgeInsets.only(
                        left: defaultColumnSpacingSm,
                        right: defaultColumnSpacingSm,
                        top: defaultColumnSpacingMd,
                        bottom: defaultColumnSpacingSm),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(inputBorderRadius)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.senderName,
                            style: GoogleFonts.ptSerif(
                                color:
                                    userColors[message.senderName.length % 5],
                                fontSize: 16)),
                        const SizedBox(
                          height: defaultColumnSpacingSm,
                        ),
                        ClipRRect(
                            borderRadius:
                                const BorderRadius.all(inputBorderRadius),
                            child: Image.file(
                              imageFile,
                              width: 270,
                              height: 280,
                              fit: BoxFit.cover,
                            )),
                      ],
                    ))));
      } else {
        CachedNetworkImageProvider image =
            CachedNetworkImageProvider(message.url!);
        handler!({"image": message.url!});
        return Flexible(
          child: GestureDetector(
            onTap: () => openFullPageImageViewer(context, image),
            child: Container(
                padding: const EdgeInsets.only(
                    left: defaultColumnSpacingSm,
                    right: defaultColumnSpacingSm,
                    top: defaultColumnSpacingMd,
                    bottom: defaultColumnSpacingSm),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(inputBorderRadius)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.senderName,
                        style: GoogleFonts.ptSerif(
                            color: userColors[message.senderName.length % 5],
                            fontSize: 16)),
                    const SizedBox(
                      height: defaultColumnSpacingSm,
                    ),
                    ClipRRect(
                        borderRadius: const BorderRadius.all(inputBorderRadius),
                        child: Image(
                          image: image,
                          width: 270,
                          height: 280,
                          fit: BoxFit.cover,
                        )),
                  ],
                )),
          ),
        );
      }
    }
  }
}

void openFullPageImageViewer(BuildContext context, ImageProvider image) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
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
                ),
                body: PhotoView(
                  imageProvider: image,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                ),
              )));
}

Widget loadingPage(BuildContext context, String heading, String subHeading, [params]) {
  return Scaffold(
    body: SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (params != null && params["loadingAnimation"] != null) ? Lottie.asset(params["loadingAnimation"], height: 200, width: 200) : Lottie.asset(loadingPageAnimation, height: 200, width: 200),
            const SizedBox(
              height: defaultColumnSpacing,
            ),
            Text(
              heading,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(
              height: defaultColumnSpacingMd,
            ),
            Text(
              subHeading,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    ),
  );
}