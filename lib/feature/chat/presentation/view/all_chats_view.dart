import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUserId)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatDocs = chatSnapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              final chatDoc = chatDocs[index];
              final users =
                  List<String>.from(chatDoc['users'] as List).cast<String>();
              // Get the other user's name based on current user ID
              final otherUserId = users.firstWhere((id) => id != currentUserId);

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasData) {
                    final otherUserData = userSnapshot.data!;
                    final otherUserName =
                        otherUserData['first_name']?.toString();

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatDoc.id)
                          .collection('messages')
                          .orderBy('timestamp', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, messageSnapshot) {
                        if (messageSnapshot.hasData &&
                            messageSnapshot.data!.docs.isNotEmpty) {
                          final latestMessageDoc =
                              messageSnapshot.data!.docs.first;
                          final latestMessageText =
                              latestMessageDoc['text']?.toString();

                          return ListTile(
                            title: Text(otherUserName ?? 'Loading...'),
                            subtitle: Text(latestMessageText ?? ''),
                            onTap: () {
                              final chatId = chatDoc.id;
                              context.go('${Routers.conversation}/$chatId',
                                  extra: otherUserName);
                            },
                          );
                        } else {
                          return ListTile(
                            title: Text(otherUserName ?? 'Loading...'),
                            subtitle: const Text('No messages yet'),
                            onTap: () {
                              final chatId = chatDoc.id;
                              context.go('${Routers.conversation}/$chatId',
                                  extra: otherUserName);
                            },
                          );
                        }
                      },
                    );
                  } else {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.go(Routers.allUsers);
        },
      ),
    );
  }
}
