class UploadIntentModel {
  final String uploadIntentId;
  final String uploadUrl;
  final String apiKey;
  final String signature;
  final Map<String, dynamic> uploadParams;

  UploadIntentModel({
    required this.uploadIntentId,
    required this.uploadUrl,
    required this.apiKey,
    required this.signature,
    required this.uploadParams,
  });

  factory UploadIntentModel.fromJson(Map<String, dynamic> json) {
    return UploadIntentModel(
      uploadIntentId: json['upload_intent_id']?.toString() ?? '',
      uploadUrl: json['upload_url']?.toString() ?? '',
      apiKey: json['api_key']?.toString() ?? '',
      signature: json['signature']?.toString() ?? '',
      uploadParams: Map<String, dynamic>.from(json['upload_params'] ?? {}),
    );
  }
}
