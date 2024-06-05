import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/core/routes/app_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_state.dart';
import 'package:go_router/go_router.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatCubit() : super(ChatInitial());

  Future<void> loadMessages(String chatId) async {
    emit(ChatLoading());
    final messagesStream = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();

    messagesStream.listen((snapshot) {
      if (isClosed) return;

      // ignore: curly_braces_in_flow_control_structures
      final messages = snapshot.docs
          .map((doc) => Message(
                text: doc['text'] ?? '',
                isSent: doc['userId'] == _auth.currentUser?.uid,
              ))
          .toList();
      emit(ChatLoaded(messages: messages));
    });
  }

  void sendMessage(
      String chatId, String messageText, String userId, bool isSent) {
    try {
      final message = {
        'text': messageText,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'isSent': isSent,
      };

      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message)
          .then((_) {
        addMessage(Message(text: messageText, isSent: isSent));
        loadMessages(chatId);
        final currentState = state;
        if (currentState is ChatLoaded) {
          final List<Message> updatedMessages =
              List.from(currentState.messages);
          updatedMessages.insert(0, Message(text: messageText, isSent: isSent));
          emit(ChatLoaded(messages: updatedMessages));
        }
      });
    } catch (e) {
      emit(ChatError(errorMessage: e.toString()));
    }
  }

  Future<void> createNewChat(String userId) async {
    emit(ChatLoading());
    try {
      final currentUserUid = _auth.currentUser!.uid;

      final existingChat = await _firestore
          .collection('chats')
          .where('users', arrayContains: currentUserUid)
          .get();

      String? chatId;
      for (var doc in existingChat.docs) {
        final users = List<String>.from(doc['users']);
        if (users.contains(userId)) {
          chatId = doc.id;
          break;
        }
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final recipientName = userData['first_name'] ?? 'Unknown User';

      if (chatId == null) {
        final newChatDocRef = await _firestore.collection('chats').add({
          'createdAt': FieldValue.serverTimestamp(),
          'users': [userId, currentUserUid],
          'recipientName': recipientName,
        });

        chatId = newChatDocRef.id;
      }

      emit(ChatLoaded(messages: const []));

      GoRouter.of(navigatorKey.currentContext!).go(
        '${Routers.conversation}/$chatId',
        extra: recipientName,
      );

      loadMessages(chatId);
    } catch (e) {
      emit(ChatError(errorMessage: e.toString()));
    }
  }

  void addMessage(Message message) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      final List<Message> updatedMessages = List.from(currentState.messages)
        ..insert(0, message);
      emit(ChatLoaded(messages: updatedMessages));
    }
  }
}
