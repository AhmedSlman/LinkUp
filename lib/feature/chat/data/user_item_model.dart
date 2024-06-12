class UserItem {
  final String userId;
  final String firstName;
  final String email;
  final String? photoUrl;

  UserItem({
    required this.userId,
    required this.firstName,
    required this.email,
    this.photoUrl,
  });
}
