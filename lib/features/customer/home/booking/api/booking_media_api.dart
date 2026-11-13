import 'dart:io';

import 'package:dio/dio.dart';

import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/home/booking/models/media_model.dart';
import 'package:fixhome/features/customer/home/booking/models/upload_intent_model.dart';

class BookingMediaApi {
  final Dio dio;

  BookingMediaApi({Dio? dio}) : dio = dio ?? DioClient.instance;

  // 1. Tạo upload intent
  Future<UploadIntentModel> createUploadIntent({
    required String mediaType,
  }) async {
    final response = await dio.post(
      '/media/upload-intents',
      data: {'media_type': mediaType},
    );

    final data = _extractData(response.data);

    return UploadIntentModel.fromJson(data);
  }

  // 2. Upload trực tiếp lên Cloudinary
  Future<void> uploadToCloudinary({
    required File file,
    required UploadIntentModel intent,
  }) async {
    final cloudinaryDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(minutes: 5),
      ),
    );

    final formMap = <String, dynamic>{
      'file': await MultipartFile.fromFile(file.path),
      'api_key': intent.apiKey,
      'signature': intent.signature,
      ...intent.uploadParams,
    };

    final formData = FormData.fromMap(formMap);

    await cloudinaryDio.post(
      intent.uploadUrl,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // 3. Xác nhận upload thành công
  Future<MediaModel> completeUpload(String intentId) async {
    final response = await dio.post('/media/upload-intents/$intentId/complete');

    final data = _extractData(response.data);

    return MediaModel.fromJson(data);
  }

  // Upload hoàn chỉnh
  Future<MediaModel> uploadMedia({
    required File file,
    required String mediaType,
  }) async {
    final intent = await createUploadIntent(mediaType: mediaType);

    if (intent.expiresAt != null &&
        intent.expiresAt!.isBefore(DateTime.now())) {
      throw Exception('Upload intent expired');
    }

    await uploadToCloudinary(file: file, intent: intent);

    return completeUpload(intent.uploadIntentId);
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return response;
    }

    throw Exception('Invalid API response');
  }
}
