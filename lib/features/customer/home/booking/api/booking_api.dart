import 'package:dio/dio.dart';

import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/home/booking/models/booking_model.dart';
import 'package:fixhome/features/customer/home/booking/models/booking_request_model.dart';

class BookingApi {
  final Dio dio;

  BookingApi({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<BookingModel> createBooking(BookingRequestModel request) async {
    final response = await dio.post('/repair-orders', data: request.toJson());

    final body = response.data;

    if (body is! Map) {
      throw Exception('Invalid booking response');
    }

    final data = body['data'];

    return BookingModel.fromJson(
      Map<String, dynamic>.from(data is Map ? data : body),
    );
  }
}
