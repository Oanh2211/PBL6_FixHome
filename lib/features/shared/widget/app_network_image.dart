import 'package:fixhome/common/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? svgColor;
  final BorderRadius? borderRadius;
  final Widget? fallback;
  final Widget? placeholder;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.svgColor,
    this.borderRadius,
    this.fallback,
    this.placeholder,
  });

  bool _isSvgUrl(String rawUrl) {
    final lower = rawUrl.toLowerCase();
    // Kiểm tra path sau khi parse Uri (loại bỏ query string ?... và fragment #...)
    final uri = Uri.tryParse(lower);
    if (uri != null && uri.path.isNotEmpty) {
      if (uri.path.endsWith('.svg')) return true;
    }
    // Fallback kiểm tra chuỗi trước dấu '?' hoặc '#'
    final cleanPath = lower.split('?').first.split('#').first;
    return cleanPath.endsWith('.svg') || lower.startsWith('data:image/svg+xml');
  }

  Widget _buildDefaultFallback() {
    return fallback ??
        Container(
          width: width,
          height: height,
          color: AppColors.surfaceMuted,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
        );
  }

  Widget _buildDefaultPlaceholder() {
    return placeholder ??
        SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = url?.trim() ?? '';
    if (trimmedUrl.isEmpty) {
      return _wrapWithBorderRadius(_buildDefaultFallback());
    }

    final Widget imageWidget;

    if (_isSvgUrl(trimmedUrl)) {
      imageWidget = SvgPicture.network(
        trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        colorFilter: svgColor != null
            ? ColorFilter.mode(svgColor!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (_) => _buildDefaultPlaceholder(),
        errorBuilder: (_, __, ___) => _buildDefaultFallback(),
      );
    } else {
      imageWidget = Image.network(
        trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildDefaultPlaceholder();
        },
        errorBuilder: (_, __, ___) => _buildDefaultFallback(),
      );
    }

    return _wrapWithBorderRadius(imageWidget);
  }

  Widget _wrapWithBorderRadius(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
