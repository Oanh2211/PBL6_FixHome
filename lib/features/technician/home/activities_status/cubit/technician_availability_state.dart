enum TechnicianAvailabilityStatus { initial, loading, success, failure }

class TechnicianAvailabilityState {
  final TechnicianAvailabilityStatus status;
  final bool? isAvailable;
  final String? errorMessage;
  final String? successMessage;

  const TechnicianAvailabilityState({
    this.status = TechnicianAvailabilityStatus.initial,
    this.isAvailable,
    this.errorMessage,
    this.successMessage,
  });

  TechnicianAvailabilityState copyWith({
    TechnicianAvailabilityStatus? status,
    bool? isAvailable,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TechnicianAvailabilityState(
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
