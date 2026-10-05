class Feedback {
  final int? id;
  final int userId;
  final int reportId;
  final int rating;
  final String? comment;
  final String createdAt;

  const Feedback({
    this.id,
    required this.userId,
    required this.reportId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'report_id': reportId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      reportId: map['report_id'] as int,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
