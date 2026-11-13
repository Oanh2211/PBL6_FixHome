import 'package:equatable/equatable.dart';
import 'package:fixhome/features/customer/home/booking/models/booking_model.dart';
import 'package:fixhome/features/customer/home/booking/models/media_model.dart';

enum BookingStatus { initial, uploading, submitting, success, failure }

class BookingState extends Equatable {
  final BookingStatus status;
  final String? errorMessage;

  final String issueDescription;

  final String address;
  final double? latitude;
  final double? longitude;
  final String wardCode;

  final String requestedTimeType;
  final DateTime? scheduledAt;

  final String contactName;
  final String contactPhone;
  final String customerNote;
  final String voucherCode;

  final List<MediaModel> mediaList;
  final BookingModel? booking;

  const BookingState({
    this.status = BookingStatus.initial,
    this.errorMessage,
    this.issueDescription = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.wardCode = '',
    this.requestedTimeType = 'NOW',
    this.scheduledAt,
    this.contactName = '',
    this.contactPhone = '',
    this.customerNote = '',
    this.voucherCode = '',
    this.mediaList = const [],
    this.booking,
  });

  bool get isUploading => status == BookingStatus.uploading;

  bool get isSubmitting => status == BookingStatus.submitting;

  List<int> get mediaIds => mediaList.map((e) => e.id).toList();

  BookingState copyWith({
    BookingStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? issueDescription,
    String? address,
    double? latitude,
    double? longitude,
    String? wardCode,
    String? requestedTimeType,
    DateTime? scheduledAt,
    String? contactName,
    String? contactPhone,
    String? customerNote,
    String? voucherCode,
    List<MediaModel>? mediaList,
    BookingModel? booking,
  }) {
    return BookingState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      issueDescription: issueDescription ?? this.issueDescription,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      wardCode: wardCode ?? this.wardCode,
      requestedTimeType: requestedTimeType ?? this.requestedTimeType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      customerNote: customerNote ?? this.customerNote,
      voucherCode: voucherCode ?? this.voucherCode,
      mediaList: mediaList ?? this.mediaList,
      booking: booking ?? this.booking,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    issueDescription,
    address,
    latitude,
    longitude,
    wardCode,
    requestedTimeType,
    scheduledAt,
    contactName,
    contactPhone,
    customerNote,
    voucherCode,
    mediaList,
    booking,
  ];
}
