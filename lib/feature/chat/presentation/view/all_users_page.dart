// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/allUsers_cubit/all_users_cubit.dart';
import 'package:linkup/feature/chat/presentation/cubit/allUsers_cubit/all_users_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_cubit.dart';

class AllUsersPage extends StatelessWidget {
  const AllUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    String currentUserUid = '';
    if (state is SignInSuccessState) {
      currentUserUid = state.user.uid;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: BlocProvider(
        create: (context) =>
            AllUsersCubit(context.read<ChatCubit>())..loadUsers(),
        child: BlocBuilder<AllUsersCubit, AllUsersState>(
          builder: (context, state) {
            if (state is AllUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AllUsersLoaded) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (ctx, index) {
                  final userItem = state.users[index];
                  return ListTile(
                    leading: userItem.photoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(userItem.photoUrl!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(userItem.firstName),
                    subtitle: Text(userItem.email),
                    onTap: () {
                      context
                          .read<AllUsersCubit>()
                          .createNewChat(userItem.userId);
                    },
                  );
                },
              );
            } else if (state is AllUsersError) {
              return Center(child: Text(state.errorMessage));
            } else {
              return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }
}
