import 'package:flutter_tts/flutter_tts.dart';

/// Lectura en voz alta (apoyo auditivo) para HU-FL-09/FL-10/FL-12.
class TtsService {
  TtsService._() {
    _tts.setLanguage('es-MX');
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
  }

  static final TtsService instance = TtsService._();
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
