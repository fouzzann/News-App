import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

/// Production-ready network image component with multi-tier fallback:
/// 1. Direct URL loading with standard browser headers
/// 2. Automatic proxy bypass for Cloudflare/WAF blocked domains (e.g. NASASpaceFlight, SpaceflightNow)
/// 3. In-flight fallback to high-speed global image CDN (wsrv.nl) if direct load encounters 403 or network errors
/// 4. Shimmer animation while loading and placeholder icon if all sources are unavailable
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

  /// Standard browser headers to minimize anti-hotlinking and bot-detection blocks
  static const Map<String, String> _browserHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
    'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  };

  /// Translates URLs that are known to block mobile/unauthenticated requests (Cloudflare 403 Bot Fight Mode)
  /// into CDN-cached endpoints.
  static String _resolveUrl(String url) {
    final clean = url.trim();
    final lower = clean.toLowerCase();

    // Known hosts with aggressive Cloudflare 403 Bot protection / Hotlink blocks
    if (lower.contains('nasaspaceflight.com') ||
        lower.contains('spaceflightnow.com')) {
      return _buildCdnProxyUrl(clean);
    }
    return clean;
  }

  static String _buildCdnProxyUrl(String originalUrl) {
    if (originalUrl.contains('wsrv.nl')) return originalUrl;
    return 'https://wsrv.nl/?url=${Uri.encodeComponent(originalUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget imageWidget;

    if (!_isValidUrl) {
      imageWidget = _buildFallback(isDark);
    } else {
      final resolvedUrl = _resolveUrl(imageUrl!);

      imageWidget = Image.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        headers: _browserHeaders,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerPlaceholder(isDark);
        },
        errorBuilder: (context, error, stackTrace) {
          // If the resolved URL wasn't already proxied, try the CDN proxy as secondary fallback
          if (!resolvedUrl.contains('wsrv.nl')) {
            final proxyUrl = _buildCdnProxyUrl(imageUrl!.trim());
            return Image.network(
              proxyUrl,
              width: width,
              height: height,
              fit: fit,
              headers: _browserHeaders,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildShimmerPlaceholder(isDark);
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildFallback(isDark);
              },
            );
          }
          return _buildFallback(isDark);
        },
      );
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
