import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = darkMode;
  bool darkModeBool = false;
  bool unlockall = false;

  ThemeData get getThemeData {
    return _themeData;
  }

  ThemeProvider() {
    loadSettings();
  }

  void setDarkMode(bool value) {
    darkModeBool = value;
    if (darkModeBool) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    notifyListeners();
    saveSettings();
  }

  void setUnlockAll(bool value) {
    unlockall = value;
    notifyListeners();
    saveSettings();
  }

  // Call this after any setting changes
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {'darkModeBool': darkModeBool, 'unlockall': unlockall};
    prefs.setString('theme_settings', jsonEncode(settings));
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('theme_settings');
    if (jsonString == null) {
      resetAllSettings();
      return;
    }
    final settings = jsonDecode(jsonString);
    darkModeBool = settings['darkModeBool'] ?? false;
    if (darkModeBool) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    unlockall = settings['unlockall'] ?? false;
    notifyListeners();
  }

  void resetAllSettings() {
    // Set all settings to their default values
    darkModeBool = false;
    unlockall = false;
    if (darkModeBool) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    saveSettings();
    notifyListeners();
  }
}
