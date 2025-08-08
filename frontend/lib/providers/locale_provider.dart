import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('es');  // Valor por defecto
  String _lastScreen = 'login';  // Valor por defecto o inicial
  bool _languageChangeOccurred = false;  // Indicador de cambio de idioma

  Locale get locale => _locale;
  String get lastScreen => _lastScreen;
  bool get languageChangeOccurred => _languageChangeOccurred;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

    void setLocale(Locale newLocale, String screen, {bool languageChanged = false}) {
    if (_locale != newLocale || _languageChangeOccurred != languageChanged) {
      _locale = newLocale;
      _lastScreen = screen;
      _languageChangeOccurred = languageChanged;
      notifyListeners();
    }
  }

  void resetLanguageChangeFlag() {
    if (_languageChangeOccurred) {
      _languageChangeOccurred = false;
      //notifyListeners();
    }
  }

}
