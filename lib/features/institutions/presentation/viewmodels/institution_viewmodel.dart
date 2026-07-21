import 'package:flutter/foundation.dart';
import '../../domain/entities/institution_entity.dart';
import '../../domain/usecases/register_institution_usecase.dart';
import '../../domain/usecases/get_pending_institutions_usecase.dart';
import '../../domain/usecases/approve_institution_usecase.dart';
import '../../domain/usecases/reject_institution_usecase.dart';

enum RegisterInstitutionStatus { idle, loading, success, error }

class InstitutionViewModel extends ChangeNotifier {
  final RegisterInstitutionUseCase _register;
  final GetPendingInstitutionsUseCase _getPending;
  final ApproveInstitutionUseCase _approve;
  final RejectInstitutionUseCase _reject;

  InstitutionViewModel({
    required RegisterInstitutionUseCase register,
    required GetPendingInstitutionsUseCase getPending,
    required ApproveInstitutionUseCase approve,
    required RejectInstitutionUseCase reject,
  })  : _register = register,
        _getPending = getPending,
        _approve = approve,
        _reject = reject;

  RegisterInstitutionStatus registerStatus = RegisterInstitutionStatus.idle;
  String? registerError;

  List<InstitutionEntity> _pending = [];
  bool _isLoading = false;
  String? _error;

  List<InstitutionEntity> get pending => _pending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> registerInstitution(RegisterInstitutionParams params) async {
    registerStatus = RegisterInstitutionStatus.loading;
    registerError = null;
    notifyListeners();
    try {
      await _register(params);
      registerStatus = RegisterInstitutionStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      registerStatus = RegisterInstitutionStatus.error;
      registerError = 'No se pudo registrar la institución. Verifica los datos e intenta de nuevo.';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadPending() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _pending = await _getPending();
    } catch (e) {
      _error = 'No se pudo cargar la lista de instituciones pendientes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveInstitution(String institutionId) async {
    try {
      await _approve(institutionId);
      _pending = [for (final i in _pending) if (i.id != institutionId) i];
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'No se pudo aprobar la institución';
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectInstitution(String institutionId, {String? reason}) async {
    try {
      await _reject(institutionId, reason: reason);
      // Sale de la lista de pendientes: el backend ya la excluye de /pending.
      await loadPending();
      return true;
    } catch (_) {
      _error = 'No se pudo rechazar la institución';
      notifyListeners();
      return false;
    }
  }
}
