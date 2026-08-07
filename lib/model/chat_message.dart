class ChatMessage {
  final int userId;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? imagePath;

  ChatMessage({
    required this.userId,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.imagePath,
  });
}
