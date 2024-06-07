// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/utils/app_constants.dart';
import 'package:linkup/feature/chat/data/chat_list_model.dart';
import 'package:linkup/feature/chat/presentation/cubit/chatList_cubit/chat_list_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_cubit.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final chatCubit = ChatCubit();
  String thisUser = '';

  ChatListCubit() : super(ChatListLoading());

  Future<void> loadChatList() async {
    emit(ChatListLoading());

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        emit(const ChatListError('No current user'));
        return;
      }

      final chatDocs = await _firestore
          .collection(AppConstants.KchatsCollection)
          .where(
            AppConstants.KusersCollection,
            arrayContains: currentUserId,
          )
          .get();

      List<AllUsersModel> chats = [];

      for (var chatDoc in chatDocs.docs) {
        final users =
            List<String>.from(chatDoc[AppConstants.KusersCollection] as List)
                .cast<String>();
        final currentUserId = _auth.currentUser!.uid;
        final userDocCurrent = await _firestore
            .collection(AppConstants.KusersCollection)
            .doc(currentUserId)
            .get();
        final currentUserName =
            userDocCurrent[AppConstants.KuserName] ?? "Unknown User";
        thisUser == currentUserName;
        final otherUserId = users.firstWhere((id) => id != currentUserId);

        final userDoc = await _firestore
            .collection(AppConstants.KusersCollection)
            .doc(otherUserId)
            .get();
        final otherUserName = userDoc[AppConstants.KuserName] ?? 'Unknown User';
        final otherUserDoc =
            await _firestore.collection('users').doc(otherUserId).get();
        final otherUserData = otherUserDoc.data();

        final latestMessageDoc = await _firestore
            .collection(AppConstants.KchatsCollection)
            .doc(chatDoc.id)
            .collection(AppConstants.KmessagesCollection)
            .orderBy(AppConstants.Ktimestamp, descending: true)
            .limit(1)
            .get();

        final latestMessageText = latestMessageDoc.docs.isNotEmpty
            ? latestMessageDoc.docs.first[AppConstants.Ktext]
            : 'No messages yet';

        chats.add(AllUsersModel(
          email: otherUserData?['email'] ?? 'No Email',
          chatId: chatDoc.id,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          latestMessage: latestMessageText,
          photoUrl: otherUserData?['photo_url'], // تحميل رابط الصورة
          timestamp: latestMessageDoc.docs.isNotEmpty
              ? latestMessageDoc.docs.first[AppConstants.Ktimestamp]
              : Timestamp.now(), // Adding timestamp for sorting
        ));
      }

      // Sorting chats by latest message timestamp in descending order
      chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> loadUsers() async {
    emit(AllUsersLoading());

    try {
      final currentUserUid = _auth.currentUser?.uid;
      if (currentUserUid == null) {
        emit(const AllUsersError('No current user'));
        return;
      }

      final usersDocs = await _firestore.collection('users').get();
      List<AllUsersModel> users = [];

      for (var doc in usersDocs.docs) {
        if (doc.id == currentUserUid) continue;

        final userData = doc.data();
        users.add(AllUsersModel(
          otherUserId: doc.id,
          otherUserName: userData['first_name'] ?? 'No Username',
          email: userData['email'] ?? 'No Email',
          photoUrl: userData['photo_url'],
          chatId: '', // لا توجد محادثة بعد
          latestMessage: '', timestamp: Timestamp.now(),
        ));
      }

      emit(AllUsersLoaded(users));
    } catch (e) {
      emit(AllUsersError(e.toString()));
    }
  }

  void createNewChat(String userId, String userName, String? photoUrl) {
    chatCubit.createNewChat(userId, userName, photoUrl);
  }
}
