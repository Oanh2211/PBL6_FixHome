class MediaUploadIntentModel {
  final String uploadIntentId;
  final String uploadUrl;
  final String apiKey;
  final String signature;
  final Map<String, dynamic> uploadParams;

  MediaUploadIntentModel({
    required this.uploadIntentId,
    required this.uploadUrl,
    required this.apiKey,
    required this.signature,
    required this.uploadParams,
  });

  factory MediaUploadIntentModel.fromJson(Map<String, dynamic> json) {
    return MediaUploadIntentModel(
      uploadIntentId: json['upload_intent_id']?.toString() ?? '',
      uploadUrl: json['upload_url'] ?? '',
      apiKey: json['api_key'] ?? '',
      signature: json['signature'] ?? '',
      uploadParams: Map<String, dynamic>.from(json['upload_params'] ?? {}),
    );
  }
}

class MediaUploadResultModel {
  final int mediaId;
  final String fileUrl;
  final String mediaType;

  MediaUploadResultModel({
    required this.mediaId,
    required this.fileUrl,
    required this.mediaType,
  });

  factory MediaUploadResultModel.fromJson(Map<String, dynamic> json) {
    return MediaUploadResultModel(
      mediaId: json['media_id'] ?? 0,
      fileUrl: json['file_url'] ?? '',
      mediaType: json['media_type'] ?? 'IMAGE',
    );
  }
}
