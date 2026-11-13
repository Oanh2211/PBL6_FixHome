import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../../model/technician_location_model.dart';

class AvailabilityLocationDialog extends StatefulWidget {
  const AvailabilityLocationDialog({super.key});

  @override
  State<AvailabilityLocationDialog> createState() =>
      _AvailabilityLocationDialogState();
}

class _AvailabilityLocationDialogState
    extends State<AvailabilityLocationDialog> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Tọa độ mặc định ban đầu
  static const LatLng _defaultPosition = LatLng(16.047079, 108.206230);

  LatLng _selectedPosition = _defaultPosition;

  String _selectedAddress = '';

  String _locationSource = 'CURRENT_GPS';

  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // CHỌN VỊ TRÍ TRÊN MAP
  // =====================================================

  Future<void> _selectPosition(LatLng position) async {
    setState(() {
      _selectedPosition = position;
      _locationSource = 'CURRENT_GPS';
      _isLoading = true;
    });

    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ].where((e) => e != null && e.trim().isNotEmpty).toSet().join(', ');

        if (mounted) {
          setState(() {
            _selectedAddress = address;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedAddress = '${position.latitude}, ${position.longitude}';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedAddress = '${position.latitude}, ${position.longitude}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // TÌM KIẾM ĐỊA CHỈ
  // =====================================================

  Future<void> _searchLocation() async {
    final keyword = _searchController.text.trim();

    if (keyword.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final locations = await Geocoding().locationFromAddress(keyword);

      if (locations.isEmpty) {
        throw Exception('Not found');
      }

      final result = locations.first;

      final position = LatLng(result.latitude, result.longitude);

      _mapController.move(position, 16);

      await _selectPosition(position);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('technician.availability.location_not_found'.tr()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // =====================================================
  // LẤY VỊ TRÍ GPS HIỆN TẠI
  // =====================================================

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Location service disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();

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

      final latLng = LatLng(position.latitude, position.longitude);

      _mapController.move(latLng, 17);

      setState(() {
        _selectedPosition = latLng;
        _locationSource = 'CURRENT_GPS';
      });

      await _selectGpsPosition(latLng);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('technician.availability.gps_error'.tr())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectGpsPosition(LatLng position) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = '';

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        address = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.trim().isNotEmpty).toSet().join(', ');
      }

      if (mounted) {
        setState(() {
          _selectedAddress = address;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedAddress = '${position.latitude}, ${position.longitude}';
        });
      }
    }
  }

  // =====================================================
  // XÁC NHẬN VỊ TRÍ
  // =====================================================

  void _confirmLocation() {
    if (_selectedAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('technician.availability.select_location'.tr())),
      );
      return;
    }

    Navigator.pop(
      context,
      TechnicianLocationModel(
        latitude: _selectedPosition.latitude,
        longitude: _selectedPosition.longitude,
        locationSource: _locationSource,
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'technician.availability.choose_location'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchLocation(),
                      decoration: InputDecoration(
                        hintText: 'technician.availability.search_address'.tr(),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              height: 19,
                              width: 19,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // MAP
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _defaultPosition,
                      initialZoom: 13,
                      onTap: (_, position) {
                        _selectPosition(position);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.fixhome.app',
                      ),

                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPosition,
                            width: 50,
                            height: 55,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.error,
                              size: 45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // NÚT GPS
                  Positioned(
                    right: 12,
                    bottom: 15,
                    child: FloatingActionButton.small(
                      heroTag: 'availability_current_location',
                      backgroundColor: Colors.white,
                      onPressed: _isLoading ? null : _getCurrentLocation,
                      child: const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  if (_isLoading)
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),

            // SELECTED ADDRESS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'technician.availability.selected_location'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.place,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAddress.isEmpty
                              ? 'technician.availability.tap_map'.tr()
                              : _selectedAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}'
                    ' | Lng: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isLoading || _selectedAddress.isEmpty
                          ? null
                          : _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: Text(
                        'technician.availability.confirm_location'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
