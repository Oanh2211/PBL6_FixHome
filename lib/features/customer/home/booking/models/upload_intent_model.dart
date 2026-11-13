class UploadIntentModel {
  final String uploadIntentId;
  final String uploadUrl;
  final String apiKey;
  final String signature;
  final Map<String, dynamic> uploadParams;
  final DateTime? expiresAt;
  final int maxFileSizeBytes;
  final double maxDurationSeconds;

  const UploadIntentModel({
    required this.uploadIntentId,
    required this.uploadUrl,
    required this.apiKey,
    required this.signature,
    required this.uploadParams,
    this.expiresAt,
    required this.maxFileSizeBytes,
    required this.maxDurationSeconds,
  });

  factory UploadIntentModel.fromJson(Map<String, dynamic> json) {
    return UploadIntentModel(
      uploadIntentId: json['upload_intent_id'].toString(),
      uploadUrl: json['upload_url'] ?? '',
      apiKey: json['api_key'] ?? '',
      signature: json['signature'] ?? '',
      uploadParams: Map<String, dynamic>.from(json['upload_params'] ?? {}),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      maxFileSizeBytes: (json['max_file_size_bytes'] as num?)?.toInt() ?? 0,
      maxDurationSeconds:
          (json['max_duration_seconds'] as num?)?.toDouble() ?? 0,
    );
  }
}
