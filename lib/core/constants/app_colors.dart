import 'package:flutter/material.dart';

/// App Color Palette adhering to the UI reference design in the specification
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF2172EC);
  static const Color primaryDark = Color(0xFF1A5BBF);
  static const Color primaryLight = Color(0xFFE8F1FD);

  // Neutral / Background colors (Light)
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color searchBarLight = Color(0xFFF3F4F6);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // Neutral / Background colors (Dark - Pure Black Theme)
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF181818);
  static const Color searchBarDark = Color(0xFF1E1E1E);
  static const Color dividerDark = Color(0xFF2E2E2E);

  // Text colors (Light)
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textMutedLight = Color(0xFF9CA3AF);

  // Text colors (Dark - Neutral monochrome)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);
  static const Color textMutedDark = Color(0xFF71717A);

  // Status colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Shimmer colors
  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF1F5F9);
  static const Color shimmerBaseDark = Color(0xFF1C1C1E);
  static const Color shimmerHighlightDark = Color(0xFF2C2C2E);
}
