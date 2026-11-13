class UploadCompleteModel {
  final int mediaId;
  final String mediaUrl;
  final String fileName;
  final String mimeType;

  UploadCompleteModel({
    required this.mediaId,
    required this.mediaUrl,
    required this.fileName,
    required this.mimeType,
  });

  factory UploadCompleteModel.fromJson(Map<String, dynamic> json) {
    return UploadCompleteModel(
      mediaId: json['media_id'] ?? 0,
      mediaUrl: json['file_url'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
    );
  }
}
