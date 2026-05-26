import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:share_plus/share_plus.dart';
import 'shared_storage.dart';

class SilentModeException implements Exception {
  final String message;

  SilentModeException([
    this.message = 'Vui lòng tắt chế độ im lặng để nghe phản hồi.',
  ]);

  @override
  String toString() => message;
}

class TextToSpeechHelper {
  TextToSpeechHelper._();
  static final TextToSpeechHelper instance = TextToSpeechHelper._();

  final FlutterTts _flutterTts = FlutterTts();
  final LocalStorageManager _storage = LocalStorageManager.instance;

  static const String _ttsLocaleKey = 'tts_last_used_locale';
  String _localeId = 'vi-VN';
  bool _isSpeaking = false;
  bool _isInitialized = false;

  Future<void> _initTts() async {
    if (_isInitialized) return;

    await _loadSavedLocale();
    await _flutterTts.setLanguage(_localeId);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((message) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await _storage.getData(_ttsLocaleKey);

    if (savedLocale != null && savedLocale.isNotEmpty) {
      _localeId = savedLocale;
    } else {
      final deviceLocale = _getDeviceLocale();
      await _storage.saveData(deviceLocale, key: _ttsLocaleKey);
      _localeId = deviceLocale;
    }
  }

  String _getDeviceLocale() {
    final deviceLocale = Platform.localeName;
    return deviceLocale.isNotEmpty ? deviceLocale.replaceAll('_', '-') : 'vi-VN';
  }

  Future<void> speak(String text) async {
    final speechText = _sanitizeTextForSpeech(text);
    if (speechText.isEmpty) return;

    final ringerStatus = await SoundMode.ringerModeStatus;
    if (ringerStatus != RingerModeStatus.normal) {
      throw SilentModeException();
    }
    if (!_isInitialized) {
      await _initTts();
    }

    if (_isSpeaking) {
      await stop();
    }

    final ttsLocale = _mapTextToLocale(speechText);
    await _flutterTts.setLanguage(ttsLocale);
    await _flutterTts.speak(speechText);
  }

  String _sanitizeTextForSpeech(String text) {
    return text.removeEmojis().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _mapTextToLocale(String text) {
    // Elegant regex check for common Vietnamese characters
    final viRegex = RegExp(
        r'[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]');
    if (viRegex.hasMatch(text)) {
      return 'vi-VN';
    }
    return 'en-US';
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }
}

class ShareHelper {
  const ShareHelper._();
  static const ShareHelper instance = ShareHelper._();

  Future<bool> shareText({
    required String text,
    Rect? sharePositionOrigin,
  }) async {
    try {
      await Share.share(
        text,
        sharePositionOrigin: sharePositionOrigin,
      );
      return true;
    } catch (e) {
      debugPrint('Share text error: $e');
      return false;
    }
  }
}

// Simple String extensions ported from app_core
extension StringSpeechExtensions on String {
  String removeEmojis() {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}'
      r'\u{1F300}-\u{1F5FF}'
      r'\u{1F680}-\u{1F6FF}'
      r'\u{1F700}-\u{1F77F}'
      r'\u{1F780}-\u{1F7FF}'
      r'\u{1F800}-\u{1F8FF}'
      r'\u{1F900}-\u{1F9FF}'
      r'\u{1FA00}-\u{1FAFF}'
      r'\u{2600}-\u{26FF}'
      r'\u{2700}-\u{27BF}'
      r'\u{1F1E6}-\u{1F1FF}'
      r'\u{1F3FB}-\u{1F3FF}'
      r'\u{FE0F}\u{200D}\u{20E3}]',
      unicode: true,
    );
    return replaceAll(emojiRegex, '');
  }
}
