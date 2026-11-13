import 'dart:io';

import 'package:fixhome/features/customer/home/booking/pages/widget/booking_media_picker.dart';
import 'package:fixhome/features/customer/home/booking/pages/widget/booking_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/common/network/dio_client.dart';

import '../api/booking_api.dart';
import '../api/booking_media_api.dart';

import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

import 'booking_location_page.dart';

class BookingPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  final int deviceTypeId;
  final String deviceName;

  const BookingPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.deviceTypeId,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingCubit(
        bookingApi: BookingApi(dio: DioClient.instance),
        mediaApi: BookingMediaApi(dio: DioClient.instance),
      ),
      child: _BookingView(
        categoryId: categoryId,
        categoryName: categoryName,
        deviceTypeId: deviceTypeId,
        deviceName: deviceName,
      ),
    );
  }
}

class _BookingView extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int deviceTypeId;
  final String deviceName;

  const _BookingView({
    required this.categoryId,
    required this.categoryName,
    required this.deviceTypeId,
    required this.deviceName,
  });

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  final TextEditingController _descriptionController = TextEditingController();

  final SpeechToText _speech = SpeechToText();

  final List<XFile> _selectedFiles = [];

  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              _isListening = status == 'listening';
            });
          }
        },
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');
        },
      );

      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
    }
  }

  Future<void> _toggleSpeech() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('customer.booking.voice_unavailable'.tr())),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      return;
    }

    await _speech.listen(
      // ignore: deprecated_member_use
      localeId: context.locale.toLanguageTag(),
      onResult: (result) {
        setState(() {
          _descriptionController.text = result.recognizedWords;
          _descriptionController.selection = TextSelection.collapsed(
            offset: _descriptionController.text.length,
          );
        });

        context.read<BookingCubit>().updateDescription(result.recognizedWords);
      },
    );
  }

  Future<void> _handleSelectedFile(XFile file, String mediaType) async {
    if (_selectedFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('customer.booking.media_limit'.tr())),
      );
      return;
    }

    setState(() => _selectedFiles.add(file));

    await context.read<BookingCubit>().uploadMedia(
      File(file.path),
      mediaType: mediaType,
    );

    if (!mounted) return;

    final state = context.read<BookingCubit>().state;

    if (state.status == BookingStatus.failure) {
      setState(() => _selectedFiles.remove(file));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('customer.booking.upload_error'.tr())),
      );
    }
  }

  void _removeFile(int index) {
    if (index >= _selectedFiles.length) return;

    final file = _selectedFiles[index];

    // Media IDs được quản lý riêng trong Cubit.
    // Xóa ảnh đã upload theo thứ tự tương ứng.
    final media = context.read<BookingCubit>().state.mediaList;

    if (index < media.length) {
      context.read<BookingCubit>().removeMedia(media[index].id);
    }

    setState(() {
      _selectedFiles.remove(file);
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('customer.booking.title'.tr()),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return Column(
            children: [
              const BookingStepIndicator(currentStep: 0),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelectedDevice(),

                      const SizedBox(height: 22),

                      Text(
                        'customer.booking.description_title'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              maxLength: 500,
                              onChanged: context
                                  .read<BookingCubit>()
                                  .updateDescription,
                              decoration: InputDecoration(
                                hintText: 'customer.booking.description_hint'
                                    .tr(),
                                border: InputBorder.none,
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _toggleSpeech,
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                                label: Text(
                                  _isListening
                                      ? 'customer.booking.stop_voice'.tr()
                                      : 'customer.booking.voice'.tr(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      BookingMediaPicker(
                        selectedFiles: _selectedFiles,
                        onSelected: _handleSelectedFile,
                        onRemove: _removeFile,
                      ),

                      if (state.isUploading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: LinearProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),

                      const SizedBox(height: 15),

                      Text(
                        'customer.booking.media_uploaded'.tr(
                          args: ['${state.mediaList.length}'],
                        ),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildBottomButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDevice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.devices, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  widget.deviceName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, BookingState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: state.isUploading || state.isSubmitting || _isListening
                ? null
                : () {
                    if (state.issueDescription.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'customer.booking.description_required'.tr(),
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<BookingCubit>(),
                          child: BookingLocationPage(
                            categoryId: widget.categoryId,
                            deviceTypeId: widget.deviceTypeId,
                            categoryName: widget.categoryName,
                            deviceName: widget.deviceName,
                          ),
                        ),
                      ),
                    );
                  },
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
