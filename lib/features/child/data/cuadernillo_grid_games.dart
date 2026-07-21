/// Banco de cuadrículas derivado del "Cuadernillo de apoyo para la dislexia".
///
/// Se suma a los juegos que ya existían (banco de letras + "cuál es diferente"),
/// no los reemplaza. Acá viven las categorías nuevas: orientación (figuras),
/// sílabas y flechas. Las de letras se quedan en child_grid_games.dart.
library;

import 'child_grid_games.dart';

/// Construye un juego de orientación: marca como objetivo cada casilla cuya
/// figura sea igual al [modelo] (misma forma, giro y espejo). Evita listar
/// índices a mano.
GridGame _porOrientacion({
  required String id,
  required String question,
  required FigureSpec modelo,
  required List<FigureSpec> figuras,
  required String explanation,
  int difficulty = 1,
}) {
  assert(figuras.length == 20, '$id debe tener 20 figuras');
  final objetivos = <int>{};
  for (var i = 0; i < figuras.length; i++) {
    if (figuras[i] == modelo) objetivos.add(i);
  }
  return GridGame(
    id: id,
    sectionLabel: 'MISMA ORIENTACIÓN',
    question: question,
    instruction: 'Toca todas las que están igual que el modelo. '
        'Las volteadas o giradas no cuentan.',
    celdas: [for (final f in figuras) FigureCell(f)],
    objetivos: objetivos,
    explanation: explanation,
    categoria: GridCategory.orientacion,
    modelo: modelo,
    difficulty: difficulty,
  );
}

/// Atajos para no repetir `FigureSpec(...)` en cada casilla.
FigureSpec _f(FiguraForma forma, {int giro = 0, bool esp = false}) =>
    FigureSpec(forma, cuartosDeGiro: giro, espejada: esp);

final List<GridGame> kJuegosOrientacion = [
  // 1) Pez mirando a la derecha vs. pez espejado (mira a la izquierda).
  //    Es el caso más parecido a b/d: misma figura, solo cambia el lado.
  _porOrientacion(
    id: 'ORI_pez_espejo',
    question: 'Peces que miran igual',
    modelo: _f(FiguraForma.pez),
    figuras: [
      _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez),
      _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez),
      _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true),
      _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true),
      _f(FiguraForma.pez), _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true),
      _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez),
      _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true),
      _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true),
    ],
    explanation:
        'El pez del modelo mira a la derecha. El espejado mira al otro lado, '
        'igual que la b y la d: son la misma forma volteada.',
  ),

  // 2) Botita en su posición vs. girada.
  _porOrientacion(
    id: 'ORI_botita_giro',
    question: 'Botas paradas igual',
    modelo: _f(FiguraForma.botita),
    figuras: [
      _f(FiguraForma.botita), _f(FiguraForma.botita, giro: 1), _f(FiguraForma.botita),
      _f(FiguraForma.botita, giro: 2), _f(FiguraForma.botita),
      _f(FiguraForma.botita, giro: 1), _f(FiguraForma.botita), _f(FiguraForma.botita, giro: 3),
      _f(FiguraForma.botita), _f(FiguraForma.botita, giro: 2),
      _f(FiguraForma.botita), _f(FiguraForma.botita, giro: 1), _f(FiguraForma.botita),
      _f(FiguraForma.botita, giro: 3), _f(FiguraForma.botita, giro: 2),
      _f(FiguraForma.botita), _f(FiguraForma.botita, giro: 1), _f(FiguraForma.botita),
      _f(FiguraForma.botita, giro: 2), _f(FiguraForma.botita, giro: 3),
    ],
    explanation:
        'Girar una figura cambia hacia dónde apunta. Solo las que están paradas '
        'igual que el modelo cuentan.',
    difficulty: 2,
  ),

  // 3) Banderín igual vs. espejado y girado (mezcla, más difícil).
  _porOrientacion(
    id: 'ORI_banderin_mix',
    question: 'Banderines iguales',
    modelo: _f(FiguraForma.banderin),
    figuras: [
      _f(FiguraForma.banderin), _f(FiguraForma.banderin, esp: true), _f(FiguraForma.banderin, giro: 2),
      _f(FiguraForma.banderin), _f(FiguraForma.banderin, giro: 1),
      _f(FiguraForma.banderin, esp: true), _f(FiguraForma.banderin), _f(FiguraForma.banderin, giro: 3),
      _f(FiguraForma.banderin, esp: true), _f(FiguraForma.banderin),
      _f(FiguraForma.banderin, giro: 2), _f(FiguraForma.banderin), _f(FiguraForma.banderin, esp: true),
      _f(FiguraForma.banderin, giro: 1), _f(FiguraForma.banderin),
      _f(FiguraForma.banderin, esp: true), _f(FiguraForma.banderin, giro: 2), _f(FiguraForma.banderin),
      _f(FiguraForma.banderin, giro: 3), _f(FiguraForma.banderin, esp: true),
    ],
    explanation:
        'Aquí hay banderines volteados y girados. Solo el que está exactamente '
        'igual que el modelo cuenta.',
    difficulty: 3,
  ),

  // 4) Pez del modelo entre peces espejados Y botitas (otra forma). Una forma
  //    distinta nunca es "igual al modelo": ayuda a separar "qué figura es" de
  //    "cómo está orientada".
  _porOrientacion(
    id: 'ORI_pez_entre_botas',
    question: 'Solo los peces que miran igual',
    modelo: _f(FiguraForma.pez),
    figuras: [
      _f(FiguraForma.pez), _f(FiguraForma.botita), _f(FiguraForma.pez, esp: true),
      _f(FiguraForma.pez), _f(FiguraForma.botita, giro: 1),
      _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez), _f(FiguraForma.botita),
      _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true),
      _f(FiguraForma.botita, giro: 2), _f(FiguraForma.pez), _f(FiguraForma.pez, esp: true),
      _f(FiguraForma.pez), _f(FiguraForma.botita),
      _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez), _f(FiguraForma.botita, giro: 3),
      _f(FiguraForma.pez, esp: true), _f(FiguraForma.pez),
    ],
    explanation:
        'Las botas no son peces: nunca cuentan. De los peces, solo los que '
        'miran igual que el modelo.',
    difficulty: 3,
  ),
];

/// Todo el contenido nuevo del cuadernillo. Se amplía en la Task 5.
List<GridGame> get kCuadernilloGridGames => [
      ...kJuegosOrientacion,
    ];
