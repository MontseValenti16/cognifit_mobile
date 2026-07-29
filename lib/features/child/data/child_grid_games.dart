library;

import 'dart:math';

import 'child_exercises.dart';
import 'cuadernillo_grid_games.dart';

enum GridCategory { buscaLetra, silabas, flechas, orientacion, cualEsDiferente }

enum FiguraForma { botita, pez, banderin }

class FigureSpec {
  final FiguraForma forma;
  final int cuartosDeGiro;
  final bool espejada;
  const FigureSpec(this.forma, {this.cuartosDeGiro = 0, this.espejada = false});

  @override
  bool operator ==(Object other) =>
      other is FigureSpec &&
      other.forma == forma &&
      other.cuartosDeGiro == cuartosDeGiro &&
      other.espejada == espejada;

  @override
  int get hashCode => Object.hash(forma, cuartosDeGiro, espejada);
}

sealed class GridCell {
  const GridCell();

  String get semanticLabel;
}

class TextCell extends GridCell {
  final String texto;
  const TextCell(this.texto);

  @override
  String get semanticLabel => texto;

  @override
  bool operator ==(Object other) => other is TextCell && other.texto == texto;

  @override
  int get hashCode => texto.hashCode;
}

class FigureCell extends GridCell {
  final FigureSpec figura;
  const FigureCell(this.figura);

  @override
  String get semanticLabel {
    final giro = figura.cuartosDeGiro == 0 ? '' : ' girada';
    final espejo = figura.espejada ? ' espejada' : '';
    return 'figura ${figura.forma.name}$giro$espejo';
  }

  @override
  bool operator ==(Object other) =>
      other is FigureCell && other.figura == figura;

  @override
  int get hashCode => figura.hashCode;
}

class GridGame {
  final String id;
  final String sectionLabel;
  final String question;
  final String instruction;

  final List<GridCell> celdas;

  final Set<int> objetivos;

  final String explanation;

  final GridCategory categoria;

  final FigureSpec? modelo;

  final int columnas;
  final int difficulty;

  const GridGame({
    required this.id,
    required this.sectionLabel,
    required this.question,
    required this.instruction,
    required this.celdas,
    required this.objetivos,
    required this.explanation,
    required this.categoria,
    this.modelo,
    this.columnas = 5,
    this.difficulty = 1,
  });

  int get totalObjetivos => objetivos.length;
}

List<GridGame> gridGamesDesdeEjercicios(List<ChildExercise> ejercicios) {
  final posiciones = List<int>.generate(15, (i) => i + 5)..shuffle(Random(7));
  var n = 0;

  return ejercicios.map((e) {
    final pos = posiciones[n++ % posiciones.length];
    final celdas = List<GridCell>.filled(20, TextCell(e.mainOption));
    celdas[pos] = TextCell(e.oddOption);
    return GridGame(
      id: 'GRID_${e.id}',
      sectionLabel: e.sectionLabel,
      question: e.question,
      instruction: 'Toca la que es diferente. Están entre otras 19.',
      celdas: celdas,
      objetivos: {pos},
      explanation: e.explanation,
      categoria: GridCategory.cualEsDiferente,
      difficulty: e.difficulty,
    );
  }).toList();
}

List<GridGame> get kTodosLosGridGames => [
      ...kGridGames,
      ...gridGamesDesdeEjercicios(kChildExercises),
      ...kCuadernilloGridGames,
    ];

GridGame porTextoObjetivo({
  required String id,
  required String sectionLabel,
  required String question,
  required String instruction,
  required List<String> celdas,
  required String objetivo,
  required String explanation,
  required GridCategory categoria,
  int difficulty = 1,
}) {
  final objetivos = <int>{};
  for (var i = 0; i < celdas.length; i++) {
    if (celdas[i] == objetivo) objetivos.add(i);
  }
  return GridGame(
    id: id,
    sectionLabel: sectionLabel,
    question: question,
    instruction: instruction,
    celdas: [for (final c in celdas) TextCell(c)],
    objetivos: objetivos,
    explanation: explanation,
    categoria: categoria,
    difficulty: difficulty,
  );
}

final List<GridGame> kGridGames = [
  porTextoObjetivo(
    id: 'GRID_b_entre_d',
    sectionLabel: 'BUSCA LA LETRA',
    question: 'Encuentra todas las b',
    instruction: 'Toca cada b que veas. Cuidado: la d se le parece mucho.',
    celdas: const [
      'd', 'b', 'd', 'd', 'b',
      'b', 'd', 'd', 'b', 'd',
      'd', 'd', 'b', 'd', 'b',
      'b', 'd', 'b', 'd', 'd',
    ],
    objetivo: 'b',
    categoria: GridCategory.buscaLetra,
    explanation:
        'La b tiene la panza a la derecha; la d, a la izquierda. Si dudas, '
        'piensa en la palabra "bota": empieza con b y la panza mira hacia '
        'adelante.',
  ),
  porTextoObjetivo(
    id: 'GRID_p_entre_q',
    sectionLabel: 'BUSCA LA LETRA',
    question: 'Encuentra todas las p',
    instruction: 'Toca cada p. La q es parecida pero mira al otro lado.',
    celdas: const [
      'q', 'p', 'q', 'p', 'q',
      'p', 'q', 'q', 'q', 'p',
      'q', 'p', 'q', 'p', 'q',
      'p', 'q', 'p', 'q', 'q',
    ],
    objetivo: 'p',
    categoria: GridCategory.buscaLetra,
    explanation:
        'La p tiene la panza a la derecha, como la b. La q la tiene a la '
        'izquierda y suele venir acompañada de la u: "queso", "quince".',
  ),
  porTextoObjetivo(
    id: 'GRID_b_entre_p_d',
    sectionLabel: 'BUSCA LA LETRA',
    question: 'Encuentra todas las b',
    instruction: 'Ahora hay tres letras parecidas. Toca solo las b.',
    celdas: const [
      'p', 'b', 'd', 'b', 'p',
      'd', 'p', 'b', 'd', 'b',
      'b', 'd', 'p', 'p', 'd',
      'd', 'b', 'p', 'b', 'p',
    ],
    objetivo: 'b',
    categoria: GridCategory.buscaLetra,
    explanation:
        'La b sube y la p baja. Si la letra tiene el palito hacia arriba y la '
        'panza a la derecha, es una b.',
    difficulty: 2,
  ),
  porTextoObjetivo(
    id: 'GRID_d_entre_todas',
    sectionLabel: 'BUSCA LA LETRA',
    question: 'Encuentra todas las d',
    instruction: 'Están las cuatro letras difíciles. Toca solo las d.',
    celdas: const [
      'b', 'd', 'q', 'p', 'd',
      'd', 'p', 'b', 'q', 'b',
      'q', 'b', 'd', 'd', 'p',
      'p', 'd', 'q', 'b', 'q',
    ],
    objetivo: 'd',
    categoria: GridCategory.buscaLetra,
    explanation:
        'La d sube y tiene la panza a la izquierda. Piensa en "dedo": el '
        'palito va arriba.',
    difficulty: 3,
  ),
  porTextoObjetivo(
    id: 'GRID_silaba_pa',
    sectionLabel: 'BUSCA LA SÍLABA',
    question: 'Encuentra todas las "pa"',
    instruction: 'Toca cada sílaba "pa". Fíjate bien, hay otras parecidas.',
    celdas: const [
      'pa', 'ap', 'pa', 'ba', 'pa',
      'ap', 'pa', 'ba', 'pa', 'ab',
      'pa', 'ba', 'ap', 'pa', 'pa',
      'ba', 'pa', 'ap', 'ba', 'pa',
    ],
    objetivo: 'pa',
    categoria: GridCategory.buscaLetra,
    explanation:
        '"pa" empieza con p y termina con a. "ap" tiene las mismas letras '
        'pero al revés, y suena distinto.',
    difficulty: 2,
  ),
  porTextoObjetivo(
    id: 'GRID_silaba_los',
    sectionLabel: 'BUSCA LA SÍLABA',
    question: 'Encuentra todas las "los"',
    instruction: 'Toca cada "los". Hay otras que se le parecen al leerlas rápido.',
    celdas: const [
      'sol', 'los', 'sol', 'los', 'lso',
      'los', 'lso', 'sol', 'los', 'sol',
      'lso', 'los', 'los', 'sol', 'lso',
      'sol', 'lso', 'los', 'sol', 'los',
    ],
    objetivo: 'los',
    categoria: GridCategory.buscaLetra,
    explanation:
        '"los" y "sol" tienen las mismas tres letras en distinto orden. '
        'Leerlas de izquierda a derecha, sin adivinar, es lo que las separa.',
    difficulty: 3,
  ),
  porTextoObjetivo(
    id: 'GRID_palabra_casa',
    sectionLabel: 'BUSCA LA PALABRA',
    question: 'Encuentra todas las "casa"',
    instruction: 'Toca cada "casa". Las otras se parecen pero no son iguales.',
    celdas: const [
      'casa', 'caza', 'casa', 'cosa', 'caza',
      'cosa', 'casa', 'caza', 'casa', 'cosa',
      'casa', 'cosa', 'caza', 'caza', 'casa',
      'caza', 'casa', 'cosa', 'caza', 'cosa',
    ],
    objetivo: 'casa',
    categoria: GridCategory.buscaLetra,
    explanation:
        '"casa" lleva s, "caza" lleva z y "cosa" cambia la primera vocal. '
        'Una sola letra cambia el significado por completo.',
    difficulty: 3,
  ),
  porTextoObjetivo(
    id: 'GRID_numero_espejo',
    sectionLabel: 'BUSCA EL NÚMERO',
    question: 'Encuentra todos los 6',
    instruction: 'Toca cada 6. El 9 es el mismo número volteado.',
    celdas: const [
      '9', '6', '9', '6', '9',
      '6', '9', '6', '9', '9',
      '9', '6', '9', '6', '6',
      '6', '9', '9', '6', '9',
    ],
    objetivo: '6',
    categoria: GridCategory.buscaLetra,
    explanation:
        'El 6 tiene la panza abajo y el 9 arriba. La misma confusión de '
        'orientación que pasa con b y d ocurre también con los números.',
    difficulty: 2,
  ),
];
