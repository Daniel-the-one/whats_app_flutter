class StatusModel {
  final int id;
  final int userId;
  final String userName;
  final String userImage;
  final List<String> statusImages;
  final DateTime lastUpdated;
  final bool isSeen;

  StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.statusImages,
    required this.lastUpdated,
    required this.isSeen,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userImage: json['userImage'] as String,
      statusImages: List<String>.from(json['statusImages'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isSeen: json['isSeen'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'statusImages': statusImages,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isSeen': isSeen,
    };
  }
}
