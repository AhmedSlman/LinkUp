class ChatListItem {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String latestMessage;
  final String? photoUrl; // إضافة حقل الصورة

  ChatListItem({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.latestMessage,
    this.photoUrl,
  });
}
