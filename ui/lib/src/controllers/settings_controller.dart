import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vservesafe/src/services/settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  static const bool isDebugMode = kDebugMode;

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  late Locale _locale;
  late bool _isRememberLogin;

  static List<Locale> get supportedLocales => SettingsService.supportedLocales;

  Locale get locale => _locale;
  bool get isRememberLogin => _isRememberLogin;

  Future<void> loadSettings() async {
    _locale = await _settingsService.locale();
    _isRememberLogin = await _settingsService.isRememberLogin();

    developer.log("Locale: ${_locale.toString()}", name: "Setting");
    developer.log("RememberLogin: ${_isRememberLogin.toString()}",
        name: "Setting");

    notifyListeners();
  }

  Future<void> updateLocale(Locale locale) async {
    await _settingsService.updateLocale(locale);
    _locale = await _settingsService.locale();

    developer.log("Locale: ${_locale.toString()}", name: "Setting");

    notifyListeners();
  }

  Future<void> updateRememberUser(bool isRemeber) async {
    await _settingsService.updateIsRememberLogin(isRemeber);
    _isRememberLogin = await _settingsService.isRememberLogin();

    developer.log("RememberLogin: ${_isRememberLogin.toString()}",
        name: "Setting");

    notifyListeners();
  }
}
