import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

/// Dictado por voz (HU-FL-10): captura la respuesta hablada del alumno
/// y la transcribe junto con la confianza del reconocimiento.
class SttService {
  SttService._();
  static final SttService instance = SttService._();

  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  bool get isListening => _stt.isListening;

  Future<bool> _ensureInitialized() async {
    if (_available) return true;
    _available = await _stt.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _available;
  }

  /// Escucha hasta que el alumno termine de hablar (o expire el silencio) y
  /// devuelve la transcripción final + confianza. Null si no hay micrófono
  /// disponible o el usuario no dio permiso.
  Future<({String text, double confidence})?> listenOnce() async {
    final ready = await _ensureInitialized();
    if (!ready) return null;

    String text = '';
    double confidence = 0;
    final completer = Completer<({String text, double confidence})?>();

    await _stt.listen(
      onResult: (result) {
        text = result.recognizedWords;
        confidence = result.confidence;
        if (result.finalResult && !completer.isCompleted) {
          completer.complete((text: text, confidence: confidence));
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: false,
        listenMode: ListenMode.dictation,
        localeId: 'es_MX',
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 20),
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 22),
      onTimeout: () => text.isEmpty ? null : (text: text, confidence: confidence),
    );
  }

  Future<void> stop() => _stt.stop();
}
