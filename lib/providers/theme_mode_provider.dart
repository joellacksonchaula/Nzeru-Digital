import 'package:flutter/material.dart';

class ThemeModeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => false;

  void setDarkMode(bool enabled) {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void toggle() {
    setDarkMode(false);
  }
}
