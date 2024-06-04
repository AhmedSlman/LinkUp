class Message {
  final String text;
  final bool isSent;

  Message({
    required this.text,
    required this.isSent,
  });

  @override
  List<Object?> get props => [text, isSent];
}

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatState {
  @override
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState {
  final List<Message> messages;

  ChatLoaded({
    required this.messages,
  });

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String errorMessage;

  ChatError({
    required this.errorMessage,
  });

  List<Object?> get props => [errorMessage];
}
