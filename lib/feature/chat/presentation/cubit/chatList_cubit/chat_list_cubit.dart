import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/feature/chat/data/chat_list_model.dart';
import 'package:linkup/feature/chat/presentation/cubit/chatList_cubit/chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .get();

      List<ChatListItem> chats = [];

      for (var chatDoc in chatDocs.docs) {
        final users =
            List<String>.from(chatDoc['users'] as List).cast<String>();
        final otherUserId = users.firstWhere((id) => id != currentUserId);

        final userDoc =
            await _firestore.collection('users').doc(otherUserId).get();
        final otherUserName = userDoc['first_name'] ?? 'Unknown User';

        final latestMessageDoc = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        final latestMessageText = latestMessageDoc.docs.isNotEmpty
            ? latestMessageDoc.docs.first['text']
            : 'No messages yet';

        chats.add(ChatListItem(
          chatId: chatDoc.id,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          latestMessage: latestMessageText,
        ));
      }

      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}
