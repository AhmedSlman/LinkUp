// ignore_for_file: unnecessary_cast

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/feature/chat/data/user_model.dart';
import 'package:linkup/feature/chat/presentation/cubit/allUsers_cubit/all_users_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_cubit.dart';

class AllUsersCubit extends Cubit<AllUsersState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatCubit _chatCubit;

  AllUsersCubit(this._chatCubit) : super(AllUsersLoading());

  Future<void> loadUsers() async {
    emit(AllUsersLoading());

    try {
      final currentUserUid = _auth.currentUser?.uid;
      if (currentUserUid == null) {
        emit(const AllUsersError('No current user'));
        return;
      }

      final usersDocs = await _firestore.collection('users').get();
      List<UserItem> users = [];

      for (var doc in usersDocs.docs) {
        if (doc.id == currentUserUid) continue;

        final userData = doc.data() as Map<String, dynamic>;
        users.add(UserItem(
          userId: doc.id,
          firstName: userData['first_name'] ?? 'No Username',
          email: userData['email'] ?? 'No Email',
        ));
      }

      emit(AllUsersLoaded(users));
    } catch (e) {
      emit(AllUsersError(e.toString()));
    }
  }

  void createNewChat(String userId) {
    _chatCubit.createNewChat(userId);
  }
}
