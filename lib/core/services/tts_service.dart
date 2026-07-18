import 'package:flutter_tts/flutter_tts.dart';

/// Lectura en voz alta (apoyo auditivo) para HU-FL-09/FL-10/FL-12.
///
/// Además de reproducir, contabiliza cuánto tiempo estuvo sonando el audio.
/// Esto es necesario para el diagnóstico: el cronómetro de respuesta corre
/// mientras suena la bocina, así que sin descontar la reproducción un niño
/// que usa el apoyo auditivo parece más lento de lo que es — y la lentitud
/// es la señal que más peso tiene en el modelo (subtipo "fluidez"). El apoyo
/// está diseñado para usarse; usarlo no debe empeorar el diagnóstico.
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

  /// Acumulado desde el último [resetPlaybackTimer].
  final Stopwatch _playback = Stopwatch();

  void _onStart() => _playback.start();

  void _onEnd() {
    if (_playback.isRunning) _playback.stop();
  }

  /// Milisegundos que el TTS estuvo sonando desde el último reset.
  int get playbackMs => _playback.elapsedMilliseconds;

  /// Se llama al empezar cada ítem, para medir solo su propia reproducción.
  void resetPlaybackTimer() => _playback
    ..stop()
    ..reset();

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    // stop() dispara el cancel handler; el start handler vuelve a arrancar el
    // cronómetro cuando el audio realmente empieza a sonar.
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _onEnd();
    await _tts.stop();
  }
}
