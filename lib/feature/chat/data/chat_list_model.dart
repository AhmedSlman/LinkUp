class AllUsersModel {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String latestMessage;
  final String email;

  final String? photoUrl; // إضافة حقل الصورة

  AllUsersModel({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.latestMessage,
    this.photoUrl,
    required this.email,
  });
}
