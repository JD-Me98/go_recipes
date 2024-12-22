import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Toggle the current theme mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Set theme to dark mode
  void setDarkMode() {
    if (!_isDarkMode) {
      _isDarkMode = true;
      notifyListeners();
    }
  }

  // Set theme to light mode
  void setLightMode() {
    if (_isDarkMode) {
      _isDarkMode = false;
      notifyListeners();
    }
  }
  
  // Method to get the current ThemeMode
  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
