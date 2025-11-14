import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central theme provider that manages app theme mode and persistence.
/// Supports system default, light, and dark themes.
class ThemeProvider with ChangeNotifier {
  static const String _key = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getInt(_key);
      if (value != null && value >= 0 && value < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[value];
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, use system default
      _themeMode = ThemeMode.system;
    }
  }

  /// Set and save theme preference
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, mode.index);
    } catch (e) {
      // Handle error silently or log it
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Get light theme
  ThemeData get lightTheme => MyAppTheme.lightTheme;

  /// Get dark theme
  ThemeData get darkTheme => MyAppTheme.darkTheme;
}
