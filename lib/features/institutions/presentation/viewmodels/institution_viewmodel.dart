import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/institutions_providers.dart';
import '../../domain/entities/institution_entity.dart';
import '../../domain/usecases/register_institution_usecase.dart';
import '../../domain/usecases/get_pending_institutions_usecase.dart';
import '../../domain/usecases/approve_institution_usecase.dart';
import '../../domain/usecases/reject_institution_usecase.dart';

class InstitutionState {
  final AsyncValue<void> registerOp;
  final AsyncValue<void> pendingOp;
  final List<InstitutionEntity> pending;

  const InstitutionState({
    this.registerOp = const AsyncValue.data(null),
    this.pendingOp = const AsyncValue.data(null),
    this.pending = const [],
  });

  bool get isLoading => pendingOp.isLoading;
  String? get error => pendingOp.hasError ? 'No se pudo completar la operación.' : null;
  bool get isRegistering => registerOp.isLoading;
  String? get registerError => registerOp.hasError
      ? 'No se pudo registrar la institución. Verifica los datos e intenta de nuevo.'
      : null;

  InstitutionState copyWith({AsyncValue<void>? registerOp, AsyncValue<void>? pendingOp, List<InstitutionEntity>? pending}) {
    return InstitutionState(
      registerOp: registerOp ?? this.registerOp,
      pendingOp: pendingOp ?? this.pendingOp,
      pending: pending ?? this.pending,
    );
  }
}

class InstitutionNotifier extends Notifier<InstitutionState> {
  late RegisterInstitutionUseCase _register;
  late GetPendingInstitutionsUseCase _getPending;
  late ApproveInstitutionUseCase _approve;
  late RejectInstitutionUseCase _reject;

  @override
  InstitutionState build() {
    final repo = ref.watch(institutionRepositoryProvider);
    _register = RegisterInstitutionUseCase(repo);
    _getPending = GetPendingInstitutionsUseCase(repo);
    _approve = ApproveInstitutionUseCase(repo);
    _reject = RejectInstitutionUseCase(repo);
    return const InstitutionState();
  }

  Future<bool> registerInstitution(RegisterInstitutionParams params) async {
    state = state.copyWith(registerOp: const AsyncValue.loading());
    try {
      await _register(params);
      state = state.copyWith(registerOp: const AsyncValue.data(null));
      return true;
    } catch (e, st) {
      state = state.copyWith(registerOp: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<void> loadPending() async {
    state = state.copyWith(pendingOp: const AsyncValue.loading());
    try {
      final pending = await _getPending();
      state = state.copyWith(pendingOp: const AsyncValue.data(null), pending: pending);
    } catch (e, st) {
      state = state.copyWith(pendingOp: AsyncValue.error(e, st));
    }
  }

  Future<bool> approveInstitution(String institutionId) async {
    try {
      await _approve(institutionId);
      state = state.copyWith(pending: [for (final i in state.pending) if (i.id != institutionId) i]);
      return true;
    } catch (e, st) {
      state = state.copyWith(pendingOp: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> rejectInstitution(String institutionId, {String? reason}) async {
    try {
      await _reject(institutionId, reason: reason);
      await loadPending();
      return true;
    } catch (e, st) {
      state = state.copyWith(pendingOp: AsyncValue.error(e, st));
      return false;
    }
  }
}

final institutionViewModelProvider = NotifierProvider<InstitutionNotifier, InstitutionState>(InstitutionNotifier.new);
