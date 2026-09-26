import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Service providing Google ML Kit on-device Language Identification and Translation Fallback.
///
/// Features:
/// 1. On-device language detection for incoming messages.
/// 2. Translation fallback when Gemini cannot generate in target language.
/// 3. Graceful fallback on non-mobile platforms (Windows, Web, Linux) and tests.
/// 4. Preserves official scholarship terms and never breaks chat flow.
class JagoMlKitService {
  static final JagoMlKitService _instance = JagoMlKitService._internal();
  factory JagoMlKitService() => _instance;
  JagoMlKitService._internal();

  LanguageIdentifier? _languageIdentifier;
  final Map<String, OnDeviceTranslator> _translators = {};

  bool get _isMlKitSupportedPlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  LanguageIdentifier _getLanguageIdentifier() {
    _languageIdentifier ??= LanguageIdentifier(confidenceThreshold: 0.5);
    return _languageIdentifier!;
  }

  /// Identifies the language of the provided text.
  ///
  /// Uses Google ML Kit Language Identification on Android & iOS.
  /// Falls back to script/Unicode heuristic detection on Windows, Web, or if ML Kit fails.
  Future<String> identifyLanguage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return 'en';

    if (_isMlKitSupportedPlatform) {
      try {
        final identifier = _getLanguageIdentifier();
        final identified = await identifier.identifyLanguage(clean);
        if (identified.isNotEmpty && identified != 'und') {
          return identified;
        }
      } catch (e) {
        debugPrint('[JAGO ML Kit] Language identification error: $e');
      }
    }

    // Heuristic script detection fallback
    return detectScriptLanguage(clean);
  }

  /// Script-based language detector supporting all 9 official JAGO languages.
  static String detectScriptLanguage(String text) {
    int devanagari = 0;
    int gujarati = 0;
    int bengali = 0;
    int tamil = 0;
    int telugu = 0;
    int kannada = 0;
    int malayalam = 0;

    for (final rune in text.runes) {
      if (rune >= 0x0900 && rune <= 0x097F) {
        devanagari++;
      } else if (rune >= 0x0A80 && rune <= 0x0AFF) {
        gujarati++;
      } else if (rune >= 0x0980 && rune <= 0x09FF) {
        bengali++;
      } else if (rune >= 0x0B80 && rune <= 0x0BFF) {
        tamil++;
      } else if (rune >= 0x0C00 && rune <= 0x0C7F) {
        telugu++;
      } else if (rune >= 0x0C80 && rune <= 0x0CFF) {
        kannada++;
      } else if (rune >= 0x0D00 && rune <= 0x0D7F) {
        malayalam++;
      }
    }

    if (gujarati > 0) return 'gu';
    if (bengali > 0) return 'bn';
    if (tamil > 0) return 'ta';
    if (telugu > 0) return 'te';
    if (kannada > 0) return 'kn';
    if (malayalam > 0) return 'ml';
    if (devanagari > 0) {
      // Check for Marathi-specific characters/words
      if (text.contains('आहे') || text.contains('नाही') || text.contains('माझे')) {
        return 'mr';
      }
      return 'hi';
    }

    return 'en';
  }

  /// Maps a standard BCP-47 language code to ML Kit [TranslateLanguage].
  /// Note: ML Kit supports 59 on-device translation languages (including Bengali,
  /// Gujarati, Hindi, Kannada, Marathi, Tamil, Telugu). For Malayalam, Gemini
  /// directly generates Malayalam without requiring translation fallback.
  static TranslateLanguage? mapToTranslateLanguage(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return TranslateLanguage.english;
      case 'hi':
        return TranslateLanguage.hindi;
      case 'gu':
        return TranslateLanguage.gujarati;
      case 'mr':
        return TranslateLanguage.marathi;
      case 'bn':
        return TranslateLanguage.bengali;
      case 'ta':
        return TranslateLanguage.tamil;
      case 'te':
        return TranslateLanguage.telugu;
      case 'kn':
        return TranslateLanguage.kannada;
      default:
        return null;
    }
  }

  /// Translates text on-device from [sourceLangCode] to [targetLangCode] as a fallback.
  ///
  /// Returns null if translation is unavailable or fails, allowing the original response to be retained.
  Future<String?> translateFallback({
    required String text,
    required String sourceLangCode,
    required String targetLangCode,
  }) async {
    if (sourceLangCode.toLowerCase() == targetLangCode.toLowerCase()) {
      return text;
    }

    if (!_isMlKitSupportedPlatform) {
      return null;
    }

    final source = mapToTranslateLanguage(sourceLangCode);
    final target = mapToTranslateLanguage(targetLangCode);

    if (source == null || target == null) {
      return null;
    }

    final key = '${source.bcpCode}_${target.bcpCode}';

    try {
      if (!_translators.containsKey(key)) {
        _translators[key] = OnDeviceTranslator(
          sourceLanguage: source,
          targetLanguage: target,
        );
      }

      final translator = _translators[key]!;
      final result = await translator.translateText(text);
      return result;
    } catch (e) {
      debugPrint('[JAGO ML Kit] Translation fallback error: $e');
      return null;
    }
  }

  /// Releases resources when done.
  Future<void> dispose() async {
    await _languageIdentifier?.close();
    _languageIdentifier = null;
    for (final translator in _translators.values) {
      await translator.close();
    }
    _translators.clear();
  }
}
