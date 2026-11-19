import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/article_model.dart';

/// Clean, responsive article card adhering to the reference UI specification
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isGridItem;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.isGridItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isGridItem) {
      return _buildGridCard(context, theme, isDark);
    }

    return _buildListCard(context, theme, isDark);
  }

  Widget _buildListCard(BuildContext context, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Thumbnail
            _buildThumbnail(width: 110, height: 110, isDark: isDark),
            const SizedBox(width: 14),
            // Article Information
            Expanded(
              child: SizedBox(
                height: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category / News Site
                        Text(
                          article.newsSite,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Article Title
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    // Author & Date Row
                    _buildAuthorDateRow(theme, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image takes top portion
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: _buildThumbnail(
                  width: double.infinity,
                  height: double.infinity,
                  isDark: isDark,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            // Text info takes bottom portion
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.newsSite,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    _buildAuthorDateRow(theme, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail({
    required double width,
    required double height,
    required bool isDark,
    BorderRadius? borderRadius,
  }) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    return Hero(
      tag: 'article_image_${article.id}',
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Container(
          width: width,
          height: height,
          color: isDark ? AppColors.surfaceDark : AppColors.shimmerBaseLight,
          child: article.hasValidImage
              ? CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: isDark
                        ? AppColors.shimmerBaseDark
                        : AppColors.shimmerBaseLight,
                    highlightColor: isDark
                        ? AppColors.shimmerHighlightDark
                        : AppColors.shimmerHighlightLight,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildImageFallback(isDark),
                )
              : _buildImageFallback(isDark),
        ),
      ),
    );
  }

  Widget _buildImageFallback(bool isDark) {
    return Container(
      color: isDark ? AppColors.searchBarDark : AppColors.searchBarLight,
      child: Center(
        child: Icon(
          Icons.rocket_launch_rounded,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildAuthorDateRow(ThemeData theme, bool isDark) {
    final avatarColor = _generateAvatarColor(article.primaryAuthor);

    return Row(
      children: [
        // Circular Author Avatar
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            article.authorInitials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Author Name
        Flexible(
          child: Text(
            article.primaryAuthor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Dot separator
        Text(
          '•',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textMutedDark
                : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(width: 4),
        // Date
        Text(
          article.formattedPublishedDate,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.textMutedDark
                : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  Color _generateAvatarColor(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
