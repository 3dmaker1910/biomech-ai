class Photo {
  final String id;
  final String patientId;
  final String photoType;
  final String filePath;
  final int fileSize;
  final int width;
  final int height;
  final DateTime createdAt;

  Photo({
    required this.id,
    required this.patientId,
    required this.photoType,
    required this.filePath,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      photoType: json['photo_type'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get fullUrl {
    return filePath;
  }
}
