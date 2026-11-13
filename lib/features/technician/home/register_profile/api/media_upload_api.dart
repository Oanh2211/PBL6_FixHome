import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fixhome/common/network/dio_client.dart';
import '../models/upload_intent_model.dart';
import '../models/upload_complete_model.dart';

class MediaUploadApi {
  final Dio dio;

  MediaUploadApi({Dio? dio}) : dio = dio ?? DioClient.instance;

  // Bước 1: Tạo upload intent
  Future<UploadIntentModel> createUploadIntent({
    String mediaType = 'IMAGE',
  }) async {
    final response = await dio.post(
      '/media/upload-intents',
      data: {'media_type': mediaType},
    );

    return UploadIntentModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  // Bước 2: Upload trực tiếp lên Cloudinary
  Future<void> uploadToCloudinary({
    required File file,
    required UploadIntentModel intent,
  }) async {
    final params = Map<String, dynamic>.from(intent.uploadParams);

    params['api_key'] = intent.apiKey;
    params['signature'] = intent.signature;

    final formData = FormData.fromMap({
      ...params,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });

    final cloudinaryDio = Dio();

    await cloudinaryDio.post(
      intent.uploadUrl,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
  }

  // Bước 3: Xác nhận upload
  Future<UploadCompleteModel> completeUpload({required String intentId}) async {
    final response = await dio.post('/media/upload-intents/$intentId/complete');

    return UploadCompleteModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  // Hàm upload tổng hợp
  Future<UploadCompleteModel> uploadFile({
    required File file,
    String mediaType = 'IMAGE',
  }) async {
    // Tạo intent
    final intent = await createUploadIntent(mediaType: mediaType);

    // Upload Cloudinary
    await uploadToCloudinary(file: file, intent: intent);

    // Xác nhận
    return await completeUpload(intentId: intent.uploadIntentId);
  }
}
