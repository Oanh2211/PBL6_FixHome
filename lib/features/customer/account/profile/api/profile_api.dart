import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/account/profile/model/profile_response_model.dart';

class ProfileApi {
  final dio = DioClient.instance;

  Future<ProfileResponseModel> getProfile() async {
    try {
      final response = await dio.get('/me');

      return ProfileResponseModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileResponseModel> updateProfile({required String fullName}) async {
    try {
      final response = await dio.patch('/me', data: {'full_name': fullName});

      return ProfileResponseModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } catch (e) {
      rethrow;
    }
  }
}
