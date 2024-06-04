import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_state.dart';

class ConversationPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String chatId;

  ConversationPage({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit()..loadMessages(chatId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          leading: IconButton(
            onPressed: () {
              context.go(Routers.allChats);
            },
            icon: const Icon(Icons.arrow_back),
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
                        return ListTile(
                          title: Text(message.text),
                          tileColor:
                              message.isSent ? Colors.blue : Colors.green,
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(labelText: 'Send a message...'),
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
