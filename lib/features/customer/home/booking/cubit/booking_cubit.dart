import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fixhome/features/customer/home/booking/models/booking_request_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/booking_api.dart';
import '../api/booking_media_api.dart';

import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingApi bookingApi;
  final BookingMediaApi mediaApi;

  BookingCubit({required this.bookingApi, required this.mediaApi})
    : super(const BookingState());

  // ================= DESCRIPTION =================

  void updateDescription(String value) {
    emit(state.copyWith(issueDescription: value, clearError: true));
  }

  // ================= LOCATION =================

  void updateLocation({
    required String address,
    required double latitude,
    required double longitude,
    required String wardCode,
  }) {
    emit(
      state.copyWith(
        address: address,
        latitude: latitude,
        longitude: longitude,
        wardCode: wardCode,
        clearError: true,
      ),
    );
  }

  // ================= TIME =================

  void selectNow() {
    emit(state.copyWith(requestedTimeType: 'NOW'));
  }

  void selectScheduled(DateTime dateTime) {
    emit(state.copyWith(requestedTimeType: 'SCHEDULED', scheduledAt: dateTime));
  }

  // ================= CONTACT =================

  void updateContact({required String name, required String phone}) {
    emit(state.copyWith(contactName: name, contactPhone: phone));
  }

  void updateCustomerNote(String value) {
    emit(state.copyWith(customerNote: value));
  }

  void updateVoucher(String value) {
    emit(state.copyWith(voucherCode: value));
  }

  // ================= MEDIA =================

  Future<void> uploadMedia(File file, {required String mediaType}) async {
    emit(state.copyWith(status: BookingStatus.uploading, clearError: true));

    try {
      final media = await mediaApi.uploadMedia(
        file: file,
        mediaType: mediaType,
      );

      emit(
        state.copyWith(
          status: BookingStatus.initial,
          mediaList: [...state.mediaList, media],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void removeMedia(int id) {
    emit(
      state.copyWith(
        mediaList: state.mediaList.where((media) => media.id != id).toList(),
        status: BookingStatus.initial,
      ),
    );
  }

  // ================= VALIDATION =================

  String? validate() {
    if (state.issueDescription.trim().isEmpty) {
      return 'booking.description_required';
    }

    if (state.address.trim().isEmpty ||
        state.latitude == null ||
        state.longitude == null) {
      return 'booking.address_required';
    }

    if (state.requestedTimeType == 'SCHEDULED') {
      if (state.scheduledAt == null ||
          !state.scheduledAt!.isAfter(DateTime.now())) {
        return 'booking.invalid_schedule';
      }
    }

    if (state.contactName.trim().isEmpty) {
      return 'booking.contact_required';
    }

    if (state.contactPhone.trim().isEmpty) {
      return 'booking.phone_required';
    }

    final phone = state.contactPhone.replaceAll(RegExp(r'[\s-]'), '');

    if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone)) {
      return 'booking.phone_invalid';
    }

    return null;
  }

  // ================= CREATE BOOKING =================

  Future<void> createBooking({
    required int categoryId,
    required int deviceTypeId,
  }) async {
    final error = validate();

    if (error != null) {
      emit(state.copyWith(status: BookingStatus.failure, errorMessage: error));
      return;
    }

    emit(state.copyWith(status: BookingStatus.submitting, clearError: true));

    try {
      final request = BookingRequestModel(
        address: state.address,
        latitude: state.latitude!,
        longitude: state.longitude!,
        categoryId: categoryId,
        deviceTypeId: deviceTypeId,
        issueDescription: state.issueDescription,
        requestedTimeType: state.requestedTimeType,
        scheduledAt: state.scheduledAt,
        wardCode: state.wardCode,
        contactName: state.contactName,
        contactPhone: state.contactPhone,
        customerNote: state.customerNote,
        voucherCode: state.voucherCode.isEmpty ? null : state.voucherCode,
        mediaIds: state.mediaIds,
      );

      final booking = await bookingApi.createBooking(request);

      emit(state.copyWith(status: BookingStatus.success, booking: booking));
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ?? e.message)
          : e.message;
      debugPrint(
        'CREATE BOOKING ERROR: ${e.response?.statusCode} - ${e.response?.data}',
      );
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: serverMessage ?? e.toString(),
        ),
      );
    } catch (e) {
      debugPrint('PARSE/OTHER ERROR: $e');
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const BookingState());
  }
}
