import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_news_app/viewmodels/theme_viewmodel.dart';

void main() {
  group('ThemeViewModel Tests', () {
    test('Default themeMode is ThemeMode.light', () {
      final themeViewModel = ThemeViewModel();
      expect(themeViewModel.themeMode, ThemeMode.light);
      expect(themeViewModel.isDarkMode, isFalse);
    });

    test('toggleTheme switches between light and dark modes', () {
      final themeViewModel = ThemeViewModel();
      expect(themeViewModel.themeMode, ThemeMode.light);

      themeViewModel.toggleTheme();
      expect(themeViewModel.themeMode, ThemeMode.dark);
      expect(themeViewModel.isDarkMode, isTrue);

      themeViewModel.toggleTheme();
      expect(themeViewModel.themeMode, ThemeMode.light);
      expect(themeViewModel.isDarkMode, isFalse);
    });

    test('setThemeMode updates theme and notifies listeners', () {
      final themeViewModel = ThemeViewModel();
      bool notified = false;
      themeViewModel.addListener(() {
        notified = true;
      });

      themeViewModel.setThemeMode(ThemeMode.dark);
      expect(themeViewModel.themeMode, ThemeMode.dark);
      expect(notified, isTrue);
    });
  });
}
