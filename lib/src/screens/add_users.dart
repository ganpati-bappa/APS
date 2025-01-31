import 'package:aps/blocs/add_user_bloc/add_user_bloc.dart';
import 'package:aps/blocs/create_group_bloc/create_group_bloc.dart';
import 'package:aps/blocs/groups_bloc/groups_bloc.dart';
import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/styles.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/screens/create_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:user_repository/user_repository.dart';

class AddUsers extends StatefulWidget {
  const AddUsers({super.key});

  @override
  State<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> {
  List<bool> selected = List.generate(20, (index) => false);

  @override
  void initState() {
    super.initState();
    context.read<AddUserBloc>().add(UsersLoadingRequirred());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text(
            addUsers,
            style: pageHeadingStyle,
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<AddUserBloc, AddUserState>(
          buildWhen: (context, state) => (state is AddUsersLoaded || state is UsersLoading),
          builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator(),);
          } else if (state is AddUsersLoaded) {
            while (selected.length < state.users.length) {
              selected.add(false);
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    return Container(
                        padding: const EdgeInsets.all(defaultColumnSpacingSm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                ProfilePicture(
                                    name: state.users[index].name.trim(),
                                    radius: 23,
                                    fontsize: 13,
                                  ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.users[index].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium),
                                    Text(state.users[index].email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall),
                                    Text(state.users[index].persona!, style: groupAdminStyles,)
                                  ],
                                ),
                              ],
                            ),
                            Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.black,
                                value: selected[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    selected[index] = !selected[index];
                                  });
                                }),
                          ],
                        ));
                  }),
            );
          } else {
            return const SizedBox();
          }
        }),
        persistentFooterButtons: [
          BlocBuilder<AddUserBloc, AddUserState>(
            builder: (context, state) {
            if (state is AddUsersLoaded || state is UsersLoading) {
              List<MyUser> selectedUsers = [];
              if (state is AddUsersLoaded) {
                selectedUsers = state.users.asMap().entries.where((entry) => selected[entry.key]).map((entry) => entry.value).toList();
              }
              return ElevatedButton(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: defaultPaddingMd))
                ),
                onPressed: () { 
                  if (selectedUsers.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => BlocProvider<CreateGroupBloc>(
                        create: (context) => CreateGroupBloc(chatGroupsRepository: (context).read<GroupsBloc>().chatGroupsRepository),
                        child: CreateGroup(users: selectedUsers),
                        // child: CreateGroup(),
                      )
                    ));
                  }
                },
                child: Text(next, style: Theme.of(context).textTheme.titleMedium,));
            }
            else {
              return const Center(child: CircularProgressIndicator(),);
            }
          }),
        ],
        );
  }
}
