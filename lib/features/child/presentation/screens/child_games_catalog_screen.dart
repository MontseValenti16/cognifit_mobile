import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/child_grid_games.dart';
import 'child_grid_game_screen.dart';

/// Nombre visible de cada categoría en el catálogo.
String nombreCategoria(GridCategory c) => switch (c) {
      GridCategory.buscaLetra => 'Busca la letra',
      GridCategory.silabas => 'Busca la sílaba',
      GridCategory.flechas => 'Las flechas',
      GridCategory.orientacion => 'Misma orientación',
      GridCategory.cualEsDiferente => '¿Cuál es diferente?',
    };

/// Orden pedagógico: de lo más concreto (letras) a lo más abstracto.
const _ordenCategorias = [
  GridCategory.buscaLetra,
  GridCategory.silabas,
  GridCategory.flechas,
  GridCategory.orientacion,
  GridCategory.cualEsDiferente,
];

/// Catálogo de dos niveles: categoría → juegos. El niño elige un juego o toda
/// una categoría, en vez de recorrer una corrida lineal que se reinicia.
class ChildGamesCatalogScreen extends StatelessWidget {
  final String studentName;

  /// Permite inyectar otra lista en las pruebas.
  final List<GridGame> juegos;

  ChildGamesCatalogScreen({
    super.key,
    required this.studentName,
    List<GridGame>? juegos,
  }) : juegos = juegos ?? kTodosLosGridGames;

  void _jugar(BuildContext context, List<GridGame> seleccion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChildGridGameScreen(
          studentName: studentName,
          juegos: seleccion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Agrupar respetando el orden pedagógico y sin categorías vacías.
    final porCategoria = <GridCategory, List<GridGame>>{};
    for (final cat in _ordenCategorias) {
      final delGrupo = juegos.where((j) => j.categoria == cat).toList();
      if (delGrupo.isNotEmpty) porCategoria[cat] = delGrupo;
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Mis juegos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in porCategoria.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(nombreCategoria(entry.key),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  if (entry.value.length > 1)
                    TextButton(
                      onPressed: () => _jugar(context, entry.value),
                      child: const Text('Jugar todos'),
                    ),
                ],
              ),
            ),
            for (final j in entry.value)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(j.question,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _jugar(context, [j]),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
