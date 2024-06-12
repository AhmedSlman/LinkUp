import 'package:linkup/feature/chat/data/message_model.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  List<Object?> get props => [];
}

class ChatLoading extends ChatState {
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState {
  final List<Message> messages;

  ChatLoaded({
    required this.messages,
  });

  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String errorMessage;

  ChatError({
    required this.errorMessage,
  });

  List<Object?> get props => [errorMessage];
}
