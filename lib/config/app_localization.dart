import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _languageKey = 'language';
final List<String> _supportedLanguages = [LangCode.vi.code, LangCode.en.code];

class AppLocalization {
  /// ----------------------------------------------------------
  /// SINGLETON
  /// ----------------------------------------------------------
  AppLocalization._privateConstructor();

  static final AppLocalization instance = AppLocalization._privateConstructor();

  /// Variables
  Locale _locale = const Locale('vi', 'VN');
  LangCode _currentLangCode = LangCode.vi;
  Map<String, dynamic>? _localizedStrings;
  VoidCallback? onLocaleChangedCallback;

  /// Returns the current language code
  LangCode get currentLangCode => _currentLangCode;

  /// Returns the current Locale
  Locale get locale => _locale;

  /// return the current currency symbol
  String get currentCurrencySymbol =>
      NumberFormat.simpleCurrency(locale: _locale.toString()).currencySymbol;

  /// return the VND currency symbol
  String get vndSymbol =>
      NumberFormat.simpleCurrency(locale: LangCode.vi.code).currencySymbol;

  /// Return a list of supported language
  Iterable<Locale> supportedLocales() =>
      _supportedLanguages.map<Locale>((lang) => Locale(lang, ''));

  /// Returns the translation that corresponds to the [key]
  String text(String key) {
    return (_localizedStrings == null || _localizedStrings?[key] == null)
        ? key
        : _localizedStrings?[key];
  }

  /// One-time initialization
  Future init([LangCode? langCode]) async {
    if (langCode != null) {
      await setNewLanguage(langCode: langCode);
    } else {
      LangCode? langCode;
      final String currentCode = await getPreferredLanguage();
      for (final LangCode code in LangCode.values) {
        if (code.code == currentCode) {
          langCode = code;
          break;
        }
      }
      await setNewLanguage(langCode: langCode ?? LangCode.vi);
    }
    return null;
  }

  /// Change the language
  Future setNewLanguage({
    LangCode langCode = LangCode.vi,
    bool saveInPrefs = false,
  }) async {
    _currentLangCode = langCode;
    _locale = Locale(langCode.code, '');

    final String jsonContent = await rootBundle.loadString(
      'lang/${_locale.languageCode}.json',
    );
    _localizedStrings = json.decode(jsonContent);

    if (saveInPrefs) {
      await setPreferredLanguage(langCode);
    }
    onLocaleChangedCallback?.call();
    return null;
  }

  /// ----------------------------------------------------------
  /// Method that saves/restores the preferred language
  /// ----------------------------------------------------------
  Future getPreferredLanguage() async {
    return _getString(_languageKey);
  }

  Future setPreferredLanguage(LangCode langCode) async {
    return _setString(_languageKey, langCode.code);
  }

  Future<String> _getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  Future<void> _setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}

// Instantiate the singleton
AppLocalization appLocalization = AppLocalization.instance;

String l(String key) {
  return AppLocalization.instance.text(key);
}

enum LangCode { vi, en }

extension LanguageExtension on LangCode {
  String get code {
    switch (this) {
      case LangCode.vi:
        return 'vi';
      case LangCode.en:
        return 'en';
    }
  }
}
