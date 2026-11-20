import 'package:flutter/material.dart';

/// Reusable circular publisher brand logo component
/// Matches official publisher brand identities (CNN, NASA, SpaceNews, NSF, etc.)
/// and supports loading network favicons with seamless fallback.
class PublisherLogo extends StatelessWidget {
  final String newsSite;
  final String? articleUrl;
  final double size;

  const PublisherLogo({
    super.key,
    required this.newsSite,
    this.articleUrl,
    this.size = 44,
  });

  String get _domain {
    if (articleUrl == null || articleUrl!.isEmpty) return '';
    try {
      final uri = Uri.parse(articleUrl!);
      return uri.host.replaceFirst(RegExp(r'^www\.'), '');
    } catch (_) {
      return '';
    }
  }

  String get _faviconUrl {
    final domain = _domain;
    if (domain.isEmpty) return '';
    return 'https://www.google.com/s2/favicons?domain=$domain&sz=128';
  }

  @override
  Widget build(BuildContext context) {
    final brand = _getBrandDesign(newsSite);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: brand.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: size > 30
            ? [
                BoxShadow(
                  color: brand.backgroundColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: _faviconUrl.isNotEmpty
          ? Image.network(
              _faviconUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildBrandBadge(brand),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(size * 0.15),
                    child: child,
                  );
                }
                return _buildBrandBadge(brand);
              },
            )
          : _buildBrandBadge(brand),
    );
  }

  Widget _buildBrandBadge(_BrandDesign brand) {
    return Container(
      width: size,
      height: size,
      color: brand.backgroundColor,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (brand.hasAccent)
            Positioned(
              right: size * 0.08,
              top: size * 0.08,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: brand.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Text(
            brand.badgeText,
            style: TextStyle(
              color: brand.textColor,
              fontSize: size * brand.fontSizeFactor,
              fontWeight: FontWeight.w900,
              letterSpacing: brand.letterSpacing,
            ),
          ),
        ],
      ),
    );
  }

  _BrandDesign _getBrandDesign(String site) {
    final normalized = site.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    if (normalized.contains('cnn')) {
      return const _BrandDesign(
        badgeText: 'CNN',
        backgroundColor: Color(0xFFCC0000),
        textColor: Colors.white,
        fontSizeFactor: 0.36,
        letterSpacing: -0.5,
      );
    }

    if (normalized.contains('nasa') && !normalized.contains('nasaspaceflight')) {
      return const _BrandDesign(
        badgeText: 'NASA',
        backgroundColor: Color(0xFF0B3D91),
        textColor: Colors.white,
        accentColor: Color(0xFFE03C31),
        hasAccent: true,
        fontSizeFactor: 0.32,
        letterSpacing: -0.5,
      );
    }

    if (normalized.contains('nasaspaceflight')) {
      return const _BrandDesign(
        badgeText: 'NSF',
        backgroundColor: Color(0xFF18181B),
        textColor: Color(0xFFF97316),
        fontSizeFactor: 0.36,
        letterSpacing: -0.5,
      );
    }

    if (normalized.contains('spacenews')) {
      return const _BrandDesign(
        badgeText: 'SN',
        backgroundColor: Color(0xFFDC2626),
        textColor: Colors.white,
        fontSizeFactor: 0.44,
        letterSpacing: -0.5,
      );
    }

    if (normalized.contains('europeanspaceflight')) {
      return const _BrandDesign(
        badgeText: 'ESF',
        backgroundColor: Color(0xFF003399),
        textColor: Colors.white,
        accentColor: Color(0xFFFBBF24),
        hasAccent: true,
        fontSizeFactor: 0.34,
        letterSpacing: -0.5,
      );
    }

    if (normalized.contains('teslarati')) {
      return const _BrandDesign(
        badgeText: 'T',
        backgroundColor: Color(0xFFE82127),
        textColor: Colors.white,
        fontSizeFactor: 0.54,
        letterSpacing: 0,
      );
    }

    if (normalized.contains('arstechnica')) {
      return const _BrandDesign(
        badgeText: 'ars',
        backgroundColor: Color(0xFFFF4E00),
        textColor: Colors.white,
        fontSizeFactor: 0.38,
        letterSpacing: -0.5,
      );
    }

    if (normalized.contains('spacepolicyonline')) {
      return const _BrandDesign(
        badgeText: 'SPO',
        backgroundColor: Color(0xFF1E3A8A),
        textColor: Colors.white,
        fontSizeFactor: 0.34,
        letterSpacing: -0.5,
      );
    }

    // Default for any other news site
    final initials = site.trim().isNotEmpty
        ? site.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join().toUpperCase()
        : 'NEWS';

    return _BrandDesign(
      badgeText: initials.length > 3 ? initials.substring(0, 3) : initials,
      backgroundColor: const Color(0xFF2172EC),
      textColor: Colors.white,
      fontSizeFactor: initials.length > 2 ? 0.34 : 0.42,
    );
  }
}

class _BrandDesign {
  final String badgeText;
  final Color backgroundColor;
  final Color textColor;
  final Color? accentColor;
  final bool hasAccent;
  final double fontSizeFactor;
  final double letterSpacing;

  const _BrandDesign({
    required this.badgeText,
    required this.backgroundColor,
    required this.textColor,
    this.accentColor,
    this.hasAccent = false,
    this.fontSizeFactor = 0.4,
    this.letterSpacing = 0,
  });
}
