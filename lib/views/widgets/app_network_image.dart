import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

/// Production-ready network image component with caching, shimmer placeholder,
/// error fallback, and cross-platform support (Android, iOS, Web, Desktop).
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.rocket_launch_rounded,
    this.fallbackIconSize = 32,
  });

  bool get _isValidUrl =>
      imageUrl != null &&
      imageUrl!.trim().isNotEmpty &&
      imageUrl!.trim().startsWith(RegExp(r'https?://', caseSensitive: false));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget imageWidget;

    if (!_isValidUrl) {
      imageWidget = _buildFallback(isDark);
    } else {
      final cleanUrl = imageUrl!.trim();

      // On Web & Desktop, use Image.network to avoid browser CORS and sqflite issues.
      // On Mobile (Android/iOS), use CachedNetworkImage for persistent disk caching.
      final isDesktopOrWeb = kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS;

      if (isDesktopOrWeb) {
        imageWidget = Image.network(
          cleanUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildShimmerPlaceholder(isDark);
          },
          errorBuilder: (context, error, stackTrace) => _buildFallback(isDark),
        );
      } else {
        imageWidget = CachedNetworkImage(
          imageUrl: cleanUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildShimmerPlaceholder(isDark),
          errorWidget: (context, url, error) => _buildFallback(isDark),
        );
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColors.searchBarDark : AppColors.searchBarLight,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: fallbackIconSize,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),
    );
  }
}
