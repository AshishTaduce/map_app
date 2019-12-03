import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData themeData;

  ThemeChanger(this.themeData);

  getTheme() => themeData;

  setTheme(ThemeData theme) {
    themeData = theme;
    notifyListeners();
  }
}
