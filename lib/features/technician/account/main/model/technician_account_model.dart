class TechnicianAccountModel {
  final String? fullName;
  final String? avatarUrl;

  const TechnicianAccountModel({this.fullName, this.avatarUrl});

  factory TechnicianAccountModel.fromJson({
    required Map<String, dynamic> profileJson,
    required Map<String, dynamic> meJson,
  }) {
    return TechnicianAccountModel(
      fullName: meJson['full_name']?.toString(),
      avatarUrl: profileJson['avatar_url']?.toString(),
    );
  }
}
