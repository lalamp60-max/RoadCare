class RoadNotification {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String createdAt;
  final bool isRead;

  const RoadNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory RoadNotification.fromMap(Map<String, dynamic> map) {
    return RoadNotification(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      type: (map['type'] ?? 'general').toString(),
      createdAt: (map['created_at'] ?? '').toString(),
      isRead: (map['is_read'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'created_at': createdAt,
      'is_read': isRead ? 1 : 0,
    };
  }

  RoadNotification copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    String? createdAt,
    bool? isRead,
  }) {
    return RoadNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
