import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/feature/chat/presentation/cubit/chatList_cubit/chat_list_cubit.dart';
import 'package:linkup/feature/chat/presentation/cubit/chatList_cubit/chat_list_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_cubit.dart';

class AllUsersPage extends StatelessWidget {
  const AllUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: BlocProvider(
        create: (context) => ChatListCubit()..loadUsers(),
        child: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state is AllUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AllUsersLoaded) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return ListTile(
                    leading: user.photoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(user.otherUserName),
                    subtitle: Text(user.email),
                    onTap: () {
                      context.read<ChatListCubit>().createNewChat(
                            user.otherUserId,
                            user.otherUserName,
                            user.photoUrl,
                          );
                    },
                  );
                },
              );
            } else if (state is ChatListError) {
              return Center(child: Text(state.errorMessage));
            } else {
              return const Center(child: Text('No users found'));
            }
          },
        ),
      ),
    );
  }
}
