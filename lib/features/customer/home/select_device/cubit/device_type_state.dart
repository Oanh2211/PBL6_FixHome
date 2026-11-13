import '../model/device_type_model.dart';

enum DeviceTypeStatus { initial, loading, success, failure }

class DeviceTypeState {
  final DeviceTypeStatus status;
  final List<DeviceTypeModel> devices;
  final String? errorMessage;
  final String searchQuery;

  const DeviceTypeState({
    this.status = DeviceTypeStatus.initial,
    this.devices = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  DeviceTypeState copyWith({
    DeviceTypeStatus? status,
    List<DeviceTypeModel>? devices,
    String? errorMessage,
    String? searchQuery,
    bool clearError = false,
  }) {
    return DeviceTypeState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
