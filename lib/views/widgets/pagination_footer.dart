import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Footer widget for pagination loading state and pagination retry errors
class PaginationFooter extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final bool hasMore;

  const PaginationFooter({
    super.key,
    required this.isLoading,
    this.error,
    required this.onRetry,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.errorLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error!,
                  style: const TextStyle(fontSize: 13, color: AppColors.error),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'You have caught up with all latest news',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMutedLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}
