import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../domain/entities/screening_entity.dart';
import '../viewmodels/calendario_viewmodel.dart';

/// Qué aplicación le toca a cada alumno. El backend ya prioriza la línea base
/// (BATERIA_INICIAL) primero: sin una evaluación de partida no hay con qué
/// comparar el avance.
class CalendarioScreen extends StatelessWidget {
  final List<CalendarioEntryEntity> entradas;
  const CalendarioScreen({super.key, required this.entradas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Qué evaluar y cuándo'), actions: const [ThemeToggleButton()]),
      body: entradas.isEmpty
          ? const Center(child: Text('Nadie tiene evaluaciones pendientes.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entradas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _Fila(entradas[i]),
            ),
    );
  }
}

class _Fila extends StatelessWidget {
  final CalendarioEntryEntity e;
  const _Fila(this.e);

  ({String texto, Color color, IconData icono}) get _accion => switch (e.queToca) {
        'BATERIA_INICIAL' => (texto: 'Primera evaluación', color: AppTheme.riskRed, icono: Icons.flag_rounded),
        'BATERIA' => (texto: 'Batería completa', color: AppTheme.pendingOrange, icono: Icons.assignment_rounded),
        'MONITOREO' => (texto: 'Monitoreo mensual', color: AppTheme.primary, icono: Icons.trending_up_rounded),
        _ => (texto: 'Al día', color: AppTheme.activeGreen, icono: Icons.check_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final a = _accion;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Icon(a.icono, color: a.color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.studentName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text('${e.grade}º grado', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: a.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Text(a.texto, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: a.color, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

/// Envoltura con estado para la ruta: crea el viewmodel, dispara la carga y
/// muestra la pantalla según el estado. La pantalla pura (CalendarioScreen)
/// queda testeable sin cablear el viewmodel.
class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});
  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  late final CalendarioViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.calendarioViewModel()..cargar();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (_, __) => switch (_vm.status) {
        CalendarioStatus.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
        CalendarioStatus.error => Scaffold(
            appBar: AppBar(title: const Text('Qué evaluar y cuándo'), actions: const [ThemeToggleButton()]),
            body: Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_vm.error ?? 'No se pudo cargar el calendario.', textAlign: TextAlign.center))),
          ),
        CalendarioStatus.loaded => CalendarioScreen(entradas: _vm.entradas),
      },
    );
  }
}
