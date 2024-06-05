class ChatListItem {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String latestMessage;

  ChatListItem({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.latestMessage,
  });
}
