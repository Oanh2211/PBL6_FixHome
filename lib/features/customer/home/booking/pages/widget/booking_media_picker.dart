import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

class BookingMediaPicker extends StatelessWidget {
  final List<XFile> selectedFiles;
  final Function(XFile file, String mediaType) onSelected;
  final Function(int index) onRemove;

  const BookingMediaPicker({
    super.key,
    required this.selectedFiles,
    required this.onSelected,
    required this.onRemove,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      onSelected(image, 'IMAGE');
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();

    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );

    if (video != null) {
      onSelected(video, 'VIDEO');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'customer.booking.media_title'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'customer.booking.media_hint'.tr(),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _button(
                icon: Icons.image_outlined,
                label: 'customer.booking.choose_image'.tr(),
                onTap: () => _pickImage(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _button(
                icon: Icons.videocam_outlined,
                label: 'customer.booking.choose_video'.tr(),
                onTap: () => _pickVideo(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(selectedFiles.length, (index) {
            final file = selectedFiles[index];
            final isVideo =
                file.path.toLowerCase().endsWith('.mp4') ||
                file.path.toLowerCase().endsWith('.mov');

            return Stack(
              children: [
                Container(
                  width: 95,
                  height: 85,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isVideo
                      ? const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.primary,
                          size: 35,
                        )
                      : Image.file(File(file.path), fit: BoxFit.cover),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: GestureDetector(
                    onTap: () => onRemove(index),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.error,
                      child: Icon(Icons.close, size: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _button({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 25),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
