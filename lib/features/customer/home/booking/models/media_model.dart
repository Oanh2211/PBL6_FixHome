class MediaModel {
  final int id;
  final String mediaType;
  final String fileUrl;
  final String mimeType;
  final int fileSizeBytes;
  final double durationSeconds;

  const MediaModel({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSizeBytes,
    this.durationSeconds = 0,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: (json['media_id'] as num).toInt(),
      mediaType: json['media_type'] ?? '',
      fileUrl: json['file_url'] ?? '',
      mimeType: json['mime_type'] ?? '',
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0,
    );
  }
}
