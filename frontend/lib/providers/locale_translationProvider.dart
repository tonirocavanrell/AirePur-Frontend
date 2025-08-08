import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();

  factory TranslationService() {
    return _instance;
  }

  TranslationService._internal();

  Map<String, dynamic>? _translations;

  Future<void> loadTranslations(String languageCode) async {
  try {
    String jsonString = await rootBundle.loadString('i18n/$languageCode.json');
    _translations = json.decode(jsonString);
  } catch (e) {
    if (kDebugMode) {
      print("Error loading translation file: $e");
    }
    _translations = {};  // Asegúrate de tener algún manejo predeterminado.
  }
}


  String translate(String key) {
    return _translations?[key] ?? 'Translation not found';
  }
}



