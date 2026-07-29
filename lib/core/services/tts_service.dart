import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._() {
    _tts.setLanguage('es-MX');
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
    _tts.setStartHandler(_onStart);
    _tts.setCompletionHandler(_onEnd);
    _tts.setCancelHandler(_onEnd);
    _tts.setErrorHandler((_) => _onEnd());
  }

  static final TtsService instance = TtsService._();
  final FlutterTts _tts = FlutterTts();

  final Stopwatch _playback = Stopwatch();

  void _onStart() => _playback.start();

  void _onEnd() {
    if (_playback.isRunning) _playback.stop();
  }

  int get playbackMs => _playback.elapsedMilliseconds;

  void resetPlaybackTimer() => _playback
    ..stop()
    ..reset();

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _onEnd();
    await _tts.stop();
  }
}
