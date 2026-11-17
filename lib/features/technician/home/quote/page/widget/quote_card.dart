import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fixhome/common/constants/app_color.dart';

import '../../api/technician_quote_api.dart';
import '../../model/technician_quote_model.dart';
import 'quote_status_badge.dart';

class QuoteCard extends StatefulWidget {
  final TechnicianQuoteModel quote;
  final VoidCallback onTap;

  const QuoteCard({super.key, required this.quote, required this.onTap});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  Timer? _timer;
  late DateTime _deadline;
  Duration _remaining = Duration.zero;
  Future<Map<String, dynamic>>? _mediaFuture;

  @override
  void initState() {
    super.initState();
    final quote = widget.quote;
    _deadline =
        quote.expiresAt ??
        quote.invitedAt?.add(const Duration(minutes: 5)) ??
        DateTime.now().add(const Duration(minutes: 5));
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });

    _mediaFuture = _loadFirstMedia(quote);
  }

  @override
  void didUpdateWidget(covariant QuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quote.quoteId != widget.quote.quoteId ||
        oldWidget.quote.expiresAt != widget.quote.expiresAt ||
        oldWidget.quote.invitedAt != widget.quote.invitedAt) {
      _timer?.cancel();
      _deadline =
          widget.quote.expiresAt ??
          widget.quote.invitedAt?.add(const Duration(minutes: 5)) ??
          DateTime.now().add(const Duration(minutes: 5));
      _updateRemaining();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) _updateRemaining();
      });
      _mediaFuture = _loadFirstMedia(widget.quote);
    }
  }

  Future<Map<String, dynamic>> _loadFirstMedia(
    TechnicianQuoteModel quote,
  ) async {
    final api = TechnicianQuoteApi();
    var mediaIds = quote.mediaIds;
    if (mediaIds.isEmpty) {
      try {
        final detail = await api.getQuoteDetail(quote.quoteId);
        mediaIds = detail.mediaIds;
      } catch (e) {
        debugPrint('QUOTE CARD DETAIL/MEDIA ERROR [${quote.quoteId}]: $e');
        return <String, dynamic>{};
      }
    }
    if (mediaIds.isEmpty) return <String, dynamic>{};
    return api.getMedia(mediaIds.first);
  }

  void _updateRemaining() {
    final diff = _deadline.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    if (_remaining == Duration.zero) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return DateFormat('HH:mm - dd/MM/yyyy').format(date.toLocal());
  }

  String _formatDistance(double distance) =>
      '${distance.toStringAsFixed(1)} km';

  String _countdownLabel() {
    if (_remaining == Duration.zero) return 'technician.quotes.expired'.tr();
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds.remainder(60);
    return 'Còn ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _categoryIcon(String url) {
    final value = url.trim();
    if (value.isEmpty) {
      return const Icon(
        Icons.home_repair_service_outlined,
        color: AppColors.primary,
        size: 22,
      );
    }
    final path = Uri.tryParse(value)?.path.toLowerCase() ?? value.toLowerCase();
    if (path.endsWith('.svg')) {
      return SvgPicture.network(
        value,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        placeholderBuilder: (_) => const Icon(
          Icons.home_repair_service_outlined,
          color: AppColors.primary,
        ),
        errorBuilder: (_, __, ___) => const Icon(
          Icons.home_repair_service_outlined,
          color: AppColors.primary,
        ),
      );
    }
    return Image.network(
      value,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.home_repair_service_outlined,
        color: AppColors.primary,
      ),
    );
  }

  Widget _mediaPreview() {
    if (_mediaFuture == null) return const SizedBox.shrink();
    return FutureBuilder<Map<String, dynamic>>(
      future: _mediaFuture,
      builder: (context, snapshot) {
        final url = snapshot.data?['file_url']?.toString() ?? '';
        if (url.isEmpty) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.textHint,
              ),
            ),
          ),
        );
      },
    );
  }

  String _timeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'NOW':
      case 'IMMEDIATE':
        return 'technician.quotes.time.now'.tr();
      case 'SCHEDULED':
        return 'technician.quotes.time.scheduled'.tr();
      default:
        return type.isEmpty ? '---' : type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final serviceName = quote.categoryName.trim().isNotEmpty
        ? quote.categoryName
        : 'Dịch vụ';
    final deviceName = quote.deviceName.trim().isNotEmpty
        ? quote.deviceName
        : 'Thiết bị';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatDistance(quote.distanceKm),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),

                  QuoteStatusBadge(status: quote.status),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: _categoryIcon(quote.categoryIconUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          deviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _mediaPreview(),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      quote.address.isNotEmpty
                          ? quote.address
                          : 'technician.quotes.no_address'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'technician.quotes.customer_time'.tr(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    Text(
                      quote.requestedTimeType.toUpperCase() == 'NOW' ||
                              quote.requestedTimeType.toUpperCase() ==
                                  'IMMEDIATE'
                          ? _timeLabel(quote.requestedTimeType)
                          : _formatDate(quote.scheduledAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'technician.quotes.view_detail'.tr(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
