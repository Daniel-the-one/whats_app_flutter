enum MessageStatus {
  pending,
  sent,
  delivered,
  read,
}

class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final String? imagePath;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
    this.imagePath,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'imagePath': imagePath,
    };
  }
}
