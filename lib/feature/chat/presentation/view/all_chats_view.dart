import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';

class AllChatsPage extends StatelessWidget {
  const AllChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chatDocs = chatSnapshot.data!.docs;
          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) => ListTile(
              title: Text(chatDocs[index]['recipientName'].toString()),
              onTap: () {
                final chatId = chatDocs[index].id;
                context.go('${Routers.conversation}/$chatId');
              },
            ),
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
