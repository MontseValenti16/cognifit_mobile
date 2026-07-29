/// El tiempo de respuesta es la señal con más peso del diagnóstico
/// (avg_time_norm es la feature #1 de las 28 del modelo). Estas pruebas fijan
/// que ese número mida lo que dice medir: el tiempo que el niño tardó en
/// resolver, y no el audio de apoyo que escuchó mientras tanto.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cognifit_mobile/features/exercise/presentation/viewmodels/exercise_viewmodel.dart';
import 'package:cognifit_mobile/features/tests/di/tests_providers.dart';
import 'package:cognifit_mobile/features/tests/domain/entities/screening_entity.dart';
import 'package:cognifit_mobile/features/tests/domain/repositories/screening_repository.dart';

SessionItemEntity _item(String id) => SessionItemEntity(
      itemId: id,
      itemOrder: 1,
      itemCode: 'IT_$id',
      stimulusText: 'casa',
      expectedResponse: 'casa',
      itemKind: 'palabra',
      difficulty: 1,
      tags: const [],
      isPractice: false,
      moduleCode: 'M04_REAL_WORDS',
      moduleTitle: 'Palabras reales',
      inputModes: const ['teclado'],
    );

class _FakeRepo implements ScreeningRepository {
  List<ItemResponseSubmission> enviadas = [];

  @override
  Future<SessionItemsResultEntity> getSessionItems(String sessionId) async =>
      SessionItemsResultEntity(sessionId: sessionId, totalItems: 1, items: [_item('a')]);

  @override
  Future<List<ResponseResultEntity>> submitResponses(
      String sessionId, List<ItemResponseSubmission> responses) async {
    enviadas = responses;
    return const [];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Construye un ProviderContainer con el repo falso inyectado y el
  /// notifier ya expuesto — el reemplazo Riverpod de instanciar el
  /// ChangeNotifier directamente con un constructor a mano.
  ({ProviderContainer container, ExerciseNotifier notifier}) build(_FakeRepo repo, {required int ttsMs}) {
    final container = ProviderContainer(overrides: [
      screeningRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(exerciseViewModelProvider.notifier);
    notifier.debugSetTtsHooks(playbackMs: () => ttsMs, resetPlayback: () {});
    return (container: container, notifier: notifier);
  }

  test('el tiempo de reproduccion del TTS se descuenta de la respuesta', () async {
    final repo = _FakeRepo();
    final vm = build(repo, ttsMs: 4000).notifier;
    await vm.loadSession('s1');

    // El niño escucha 4s de audio y responde; su tiempo real de resolución
    // debe excluir esa reproducción.
    await Future<void>.delayed(const Duration(milliseconds: 60));
    vm.answer('casa');

    final enviado = vm.debugCollected.single.responseTimeMs;
    expect(enviado, 0,
        reason: 'con 4s de audio y ~60ms de respuesta, el neto debe quedar en 0, no en 4060');
  });

  test('sin audio, el tiempo medido se conserva', () async {
    final repo = _FakeRepo();
    final vm = build(repo, ttsMs: 0).notifier;
    await vm.loadSession('s1');

    await Future<void>.delayed(const Duration(milliseconds: 60));
    vm.answer('casa');

    expect(vm.debugCollected.single.responseTimeMs, greaterThan(0));
  });

  test('el tiempo nunca queda negativo', () async {
    final repo = _FakeRepo();
    final vm = build(repo, ttsMs: 999999).notifier;
    await vm.loadSession('s1');
    vm.answer('casa');

    expect(vm.debugCollected.single.responseTimeMs, greaterThanOrEqualTo(0));
  });
}
