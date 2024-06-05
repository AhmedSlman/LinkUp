// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';
import 'package:linkup/feature/auth/presentation/widgets/auth_text_form_field.dart';
import 'package:linkup/feature/chat/data/message_model.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_state.dart';

class ConversationPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String chatId;
  final String otherUserName;

  ConversationPage({
    Key? key,
    required this.chatId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit()..loadMessages(chatId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(otherUserName),
          leading: IconButton(
            onPressed: () {
              context.go(Routers.allChats);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoaded) {
                    return ListView.builder(
                      reverse: true,
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return ChatBubble(
                          message: message.text,
                          messageColor: message.isSent
                              ? const Color.fromARGB(106, 33, 149, 243)
                              : const Color.fromARGB(96, 94, 103, 107),
                          alignment: message.isSent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                        );
                      },
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text(state.errorMessage));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 8.0,
                bottom: 15,
                top: 8,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: AuthTextFormField(
                      controller: _controller,
                      hintText: 'Send a message...',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final state = context.read<AuthCubit>().state;
                      if (state is SignInSuccessState) {
                        final userId = state.user.uid;
                        final messageText = _controller.text;

                        // Update UI with the sent message immediately
                        context.read<ChatCubit>().addMessage(
                              Message(text: messageText, isSent: true),
                            );

                        context.read<ChatCubit>().sendMessage(
                              chatId,
                              messageText,
                              userId,
                              true,
                            );

                        _controller.clear();

                        context.read<ChatCubit>().loadMessages(chatId);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.message,
    required this.messageColor,
    required this.alignment,
  }) : super(key: key);

  final String message;
  final Color messageColor;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width *
              0.7, // Maximum width for the chat bubble
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
