import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1A73E8),
      secondary: Color(0xFF43A047),
      surface: Colors.white,
      background: Color(0xFFF5F5F7),
      error: Color(0xFFB00020),
    ),
    scaffoldBackgroundColor: Color(0xFFF5F5F7),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      secondary: Color(0xFF81C784),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Color(0xFFCF6679),
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
  );
}
