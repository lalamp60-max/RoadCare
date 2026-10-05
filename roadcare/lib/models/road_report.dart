class RoadReport {
  final int? id;
  final int userId;

  final String title;
  final String description;
  final String damageType;
  final String severity;

  final double? latitude;
  final double? longitude;

  final String? address;

  // PHOTO EVIDENCE
  final String? imagePath;

  final String status;

  final String createdAt;
  final String updatedAt;

  const RoadReport({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.damageType,
    required this.severity,
    this.latitude,
    this.longitude,
    this.address,
    this.imagePath,
    this.status = 'Pending',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'damage_type': damageType,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,

      // PHOTO PATH
      'image_path': imagePath,

      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory RoadReport.fromMap(Map<String, dynamic> map) {
    return RoadReport(
      id: map['id'] == null ? null : (map['id'] as num).toInt(),

      userId: (map['user_id'] as num).toInt(),

      title: map['title'] as String? ?? '',

      description: map['description'] as String? ?? '',

      damageType: map['damage_type'] as String? ?? 'Pothole',

      severity: map['severity'] as String? ?? 'Medium',

      latitude: map['latitude'] == null
          ? null
          : (map['latitude'] as num).toDouble(),

      longitude: map['longitude'] == null
          ? null
          : (map['longitude'] as num).toDouble(),

      address: map['address'] as String?,

      // PHOTO PATH
      imagePath: map['image_path'] as String?,

      status: map['status'] as String? ?? 'Pending',

      createdAt: map['created_at'] as String? ?? '',

      updatedAt: map['updated_at'] as String? ?? '',
    );
  }
}
