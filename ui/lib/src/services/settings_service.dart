import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class SettingsService {
  static const String _localeKey = "app_lang";
  static const String _rememberLoginKey = "remember_login";

  static const bool showItemId = false;

  Future<Locale> locale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lang = prefs.getString(_localeKey);

    if (lang != null) {
      Locale? target =
          supportedLocales.firstWhereOrNull((ele) => ele.toString() == lang);
      if (target != null) {
        return target;
      }
    }

    return supportedLocales[0];
  }

  static const List<Locale> supportedLocales = [
    Locale('en', "US"),
    Locale('th', "TH")
  ];

  Future<void> updateLocale(Locale locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.toString());
  }

  Future<bool> isRememberLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isRemeber = prefs.getBool(_rememberLoginKey);
    return isRemeber ?? false;
  }

  Future<void> updateIsRememberLogin(bool isRemeber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberLoginKey, isRemeber);
  }
}
