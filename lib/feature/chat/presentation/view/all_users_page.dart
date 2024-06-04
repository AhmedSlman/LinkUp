import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit.dart';

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final usersDocs = usersSnapshot.data!.docs
              .where((doc) => doc.id != currentUserUid)
              .toList();
          return ListView.builder(
            itemCount: usersDocs.length,
            itemBuilder: (ctx, index) {
              final userData = usersDocs[index].data() as Map<String, dynamic>;
              final firstName = userData['first_name'] ?? 'No Username';
              final userId = usersDocs[index].id;
              return ListTile(
                title: Text(firstName),
                onTap: () {
                  final chatCubit = context.read<ChatCubit>();
                  chatCubit.createNewChat(userId);
                },
              );
            },
          );
        },
      ),
    );
  }
}
