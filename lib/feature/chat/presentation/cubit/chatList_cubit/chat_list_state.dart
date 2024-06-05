import 'package:linkup/feature/chat/data/chat_list_model.dart';

abstract class ChatListState {
  const ChatListState();

  List<Object?> get props => [];
}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatListItem> chats;

  const ChatListLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatListError extends ChatListState {
  final String errorMessage;

  const ChatListError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
