import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable search input bar matching the reference UI design
class SearchInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback? onFilterTap;

  const SearchInputBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.searchBarDark : AppColors.searchBarLight,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Search Icon
          Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            size: 22,
          ),
          const SizedBox(width: 10),
          // Text Input Field
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          // Clear Button or Filter Icon
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  onPressed: onClear,
                );
              }
              return IconButton(
                icon: const Icon(Icons.tune_rounded, size: 20),
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
                onPressed: onFilterTap,
              );
            },
          ),
        ],
      ),
    );
  }
}
