class Message {
  final String text;
  final bool isSent;

  Message({
    required this.text,
    required this.isSent,
  });

  List<Object?> get props => [text, isSent];
}
