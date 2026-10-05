class ReportImage {
  final int? id;
  final int reportId;
  final String imagePath;
  final String imageType;
  final String createdAt;

  const ReportImage({
    this.id,
    required this.reportId,
    required this.imagePath,
    this.imageType = 'evidence',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'image_path': imagePath,
      'image_type': imageType,
      'created_at': createdAt,
    };
  }

  factory ReportImage.fromMap(Map<String, dynamic> map) {
    return ReportImage(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      imagePath: map['image_path'] as String,
      imageType: map['image_type'] as String? ?? 'evidence',
      createdAt: map['created_at'] as String,
    );
  }
}
