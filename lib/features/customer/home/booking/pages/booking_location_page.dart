import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/home/booking/cubit/booking_cubit.dart';
import 'package:fixhome/features/customer/home/booking/cubit/booking_state.dart';
import 'package:fixhome/features/customer/home/booking/pages/widget/booking_step_indicator.dart';
import 'package:fixhome/features/customer/home/booking/pages/booking_time_note_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class BookingLocationPage extends StatefulWidget {
  final int categoryId;
  final int deviceTypeId;
  final String categoryName;
  final String deviceName;

  const BookingLocationPage({
    super.key,
    required this.categoryId,
    required this.deviceTypeId,
    required this.categoryName,
    required this.deviceName,
  });

  @override
  State<BookingLocationPage> createState() => _BookingLocationPageState();
}

class _BookingLocationPageState extends State<BookingLocationPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Tọa độ mặc định tại Đà Nẵng.
  LatLng _selectedPosition = const LatLng(16.0544, 108.2022);

  String _address = '';
  bool _mapReady = false;
  bool _loadingLocation = false;
  bool _loadingAddress = false;
  bool _searching = false;

  int _geocodingRequestId = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final state = context.read<BookingCubit>().state;

      if (state.latitude != null && state.longitude != null) {
        _selectedPosition = LatLng(state.latitude!, state.longitude!);

        _address = state.address;
        _searchController.text = state.address;

        if (_mapReady) {
          _mapController.move(_selectedPosition, 16);
        }

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Chọn vị trí trên bản đồ và chuyển tọa độ thành địa chỉ.
  Future<void> _selectPosition(LatLng position) async {
    final requestId = ++_geocodingRequestId;

    setState(() {
      _selectedPosition = position;
      _loadingAddress = true;
      _address = '';
    });

    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted || requestId != _geocodingRequestId) return;

      if (placemarks.isEmpty) {
        throw Exception('Address not found');
      }

      final place = placemarks.first;

      final parts =
          [
                place.name,
                place.street,
                place.subLocality,
                place.locality,
                place.subAdministrativeArea,
                place.administrativeArea,
                place.country,
              ]
              .whereType<String>()
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList();

      final address = parts.toSet().join(', ');

      setState(() {
        _address = address;
        _searchController.text = address;
        _loadingAddress = false;
      });

      if (address.isEmpty) {
        _showMessage('customer.booking.reverse_geocoding_error'.tr());
      }
    } catch (e) {
      if (!mounted || requestId != _geocodingRequestId) return;

      setState(() {
        _address = '';
        _loadingAddress = false;
      });

      _showMessage('customer.booking.reverse_geocoding_error'.tr());
    }
  }

  // Tìm địa chỉ bằng từ khóa.
  Future<void> _searchAddress() async {
    final keyword = _searchController.text.trim();

    if (keyword.isEmpty || _searching) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _searching = true;
    });

    try {
      final locations = await Geocoding().locationFromAddress(keyword);

      if (!mounted) return;

      if (locations.isEmpty) {
        throw Exception('Address not found');
      }

      final result = locations.first;

      final position = LatLng(result.latitude, result.longitude);

      await _selectPosition(position);

      if (!mounted) return;

      if (_mapReady) {
        _mapController.move(position, 16);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('customer.booking.search_location_error'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  // Lấy vị trí GPS hiện tại.
  Future<void> _getCurrentLocation() async {
    if (_loadingLocation) return;

    setState(() {
      _loadingLocation = true;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        throw Exception('GPS is disabled');
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final point = LatLng(position.latitude, position.longitude);

      await _selectPosition(point);

      if (!mounted) return;

      if (_mapReady) {
        _mapController.move(point, 16);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('customer.booking.current_location_error'.tr());
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Thanh tìm kiếm địa chỉ.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _searchAddress(),
        decoration: InputDecoration(
          hintText: 'customer.booking.search_location_hint'.tr(),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: IconButton(
            onPressed: _searching ? null : _searchAddress,
            icon: _searching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_forward, color: AppColors.primary),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  // Bản đồ OpenStreetMap.
  Widget _buildMap() {
    return Container(
      height: 390,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 14,
              onMapReady: () {
                _mapReady = true;
                _mapController.move(_selectedPosition, 14);
              },
              onTap: (_, point) {
                _selectPosition(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.fixhome',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 50,
                    height: 55,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 45,
                    ),
                  ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // Nút lấy vị trí hiện tại.
          Positioned(
            right: 12,
            bottom: 16,
            child: FloatingActionButton.small(
              heroTag: 'booking_current_location',
              backgroundColor: AppColors.surface,
              onPressed: _loadingLocation ? null : _getCurrentLocation,
              child: _loadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // Hướng dẫn chọn vị trí trên bản đồ.
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: AppColors.primary,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'customer.booking.map_instruction'.tr(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thông tin vị trí đã chọn.
  Widget _buildAddressCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'customer.booking.selected_location'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_loadingAddress) const LinearProgressIndicator(minHeight: 2),

          const SizedBox(height: 6),

          Text(
            _address.isEmpty
                ? 'customer.booking.location_not_selected'.tr()
                : _address,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),

          const SizedBox(height: 8),

          Text(
            '${_selectedPosition.latitude.toStringAsFixed(6)}, '
            '${_selectedPosition.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Lưu vị trí và chuyển sang trang tiếp theo.
  void _continue() {
    if (_address.trim().isEmpty || _loadingAddress) {
      _showMessage('customer.booking.location_not_selected'.tr());
      return;
    }

    final cubit = context.read<BookingCubit>();

    cubit.updateLocation(
      address: _address,
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
      wardCode: cubit.state.wardCode,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: BookingTimeNotePage(
            categoryId: widget.categoryId,
            deviceTypeId: widget.deviceTypeId,
            categoryName: widget.categoryName,
            deviceName: widget.deviceName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('customer.booking.location_page_title'.tr()),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          const BookingStepIndicator(currentStep: 1),
          _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [_buildMap(), _buildAddressCard()]),
            ),
          ),
          _bottomButton(),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'customer.booking.continue'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
