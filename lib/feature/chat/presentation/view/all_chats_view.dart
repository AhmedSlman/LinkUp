// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/core/utils/app_colors.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/chatList_cubit/chat_list_cubit.dart';
import 'package:linkup/feature/chat/presentation/cubit/chatList_cubit/chat_list_state.dart';

class AllChatsPage extends StatelessWidget {
  const AllChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthCubit>().state is SignInSuccessState
        ? (context.read<AuthCubit>().state as SignInSuccessState).user.uid
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthCubit>().signOut();
              context.go(Routers.login);
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => ChatListCubit()..loadChatList(),
        child: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatListLoaded) {
              return ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (ctx, index) {
                  final chatItem = state.chats[index];
                  return ListTile(
                    leading: chatItem.photoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(chatItem.photoUrl!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(chatItem.otherUserName),
                    subtitle: Text(chatItem.latestMessage),
                    onTap: () {
                      context.go(
                        '${Routers.conversation}/${chatItem.chatId}',
                        extra: chatItem.otherUserName,
                      );
                    },
                  );
                },
              );
            } else if (state is ChatListError) {
              return Center(child: Text(state.errorMessage));
            } else {
              return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          context.go(Routers.allUsers);
        },
      ),
    );
  }
}
