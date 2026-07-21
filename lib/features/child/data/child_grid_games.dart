/// Juegos de cuadrícula para el modo niño.
///
/// A diferencia de los ejercicios de una fila —cuatro opciones, se toca una y
/// se acaba— acá el alumno recorre una cuadrícula de 20 casillas y marca
/// **todas** las que cumplen la consigna.
///
/// El cambio no es solo de tamaño. Elegir entre cuatro opciones puestas una al
/// lado de la otra permite compararlas; encontrar las mismas letras repartidas
/// entre distractores obliga a reconocer cada una por sí sola, mientras se
/// sostiene la búsqueda. Esa carga de rastreo es justamente donde aparecen las
/// confusiones b/d/p/q que el tamizaje busca, y es la mecánica de sopa de
/// letras que recomienda el catálogo de actividades del proyecto.
library;

import 'dart:math';

import 'child_exercises.dart';

/// Categorías con las que el catálogo agrupa los juegos. Es un valor estable,
/// distinto del `sectionLabel` de display (que puede repetirse o cambiar).
enum GridCategory { buscaLetra, silabas, flechas, orientacion, cualEsDiferente }

/// Silueta simple y asimétrica: al espejarla o girarla se nota, que es lo que
/// hace falta para discriminar orientación (la raíz de la confusión b/d).
enum FiguraForma { botita, pez, banderin }

/// Una figura y su orientación. Se compara por valor para poder decidir qué
/// casillas "se ven igual que el modelo" sin listar índices a mano.
class FigureSpec {
  final FiguraForma forma;
  final int cuartosDeGiro; // 0..3, giros de 90°
  final bool espejada; // reflejo horizontal
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

/// Una casilla de la cuadrícula: o una letra/sílaba/glifo, o una figura.
sealed class GridCell {
  const GridCell();

  /// Etiqueta para lectores de pantalla.
  String get semanticLabel;
}

class TextCell extends GridCell {
  final String texto;
  const TextCell(this.texto);

  @override
  String get semanticLabel => texto;
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
}

class GridGame {
  final String id;
  final String sectionLabel;
  final String question;
  final String instruction;

  /// Las 20 casillas, en el orden en que se muestran.
  final List<GridCell> celdas;

  /// Cuáles hay que tocar. El resto son distractores.
  final Set<int> objetivos;

  /// Qué se explica al terminar, sea que acertó o no.
  final String explanation;

  /// Categoría estable para agrupar en el catálogo.
  final GridCategory categoria;

  /// Figura de referencia para los juegos de orientación ("igual que esta").
  /// Nula en los juegos de texto.
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

/// Convierte los ejercicios de "¿cuál es diferente?" a cuadrícula.
///
/// Antes eran una fila de cuatro: tres iguales y una distinta. Con cuatro
/// opciones lado a lado el alumno las compara entre sí, y acertar por azar
/// tiene una probabilidad de uno en cuatro. En una cuadrícula de veinte tiene
/// que reconocer cada casilla por separado mientras sostiene la búsqueda, y el
/// azar baja a uno en veinte.
///
/// Conviene notar que no es una búsqueda fácil aunque haya una sola distinta:
/// las parejas del banco —b/d, p/q, n/u— son imágenes espejo, así que la
/// distinta **no salta a la vista** y obliga a revisar casilla por casilla.
/// Con un color entre otro color sí saltaría; con estas letras, no.
///
/// La conversión se hace acá y no duplicando el banco: los ejercicios siguen
/// definidos en un solo lugar.
List<GridGame> gridGamesDesdeEjercicios(List<ChildExercise> ejercicios) {
  // Semilla fija: la posición de la distinta no cambia entre sesiones, así el
  // desempeño de un alumno se puede comparar consigo mismo.
  //
  // Se excluye la primera fila. La lectura arranca arriba a la izquierda, así
  // que una distinta en esas cinco casillas se encuentra sin buscar y el
  // ejercicio deja de medir rastreo — con la semilla anterior, el primer juego
  // la ponía justo en la casilla 0.
  final posiciones = List<int>.generate(15, (i) => i + 5)..shuffle(Random(7));
  var n = 0;

  return ejercicios.map((e) {
    // Se recorren en orden barajado y se reparten: dos ejercicios seguidos no
    // repiten posición, que si no el alumno aprende dónde mirar.
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

/// Todos los juegos de cuadrícula: los de "toca todas" más los de "toca la
/// diferente" convertidos del banco original.
List<GridGame> get kTodosLosGridGames => [
      ...kGridGames,
      ...gridGamesDesdeEjercicios(kChildExercises),
    ];

/// Construye una cuadrícula marcando como objetivo cada casilla que sea igual
/// a [objetivo]. Evita listar los índices a mano, que es donde se cuelan los
/// errores al agregar juegos nuevos.
GridGame _porLetra({
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

/// Ocho cuadrículas de 5x4, ordenadas de menor a mayor dificultad.
///
/// Las parejas confundibles van juntas a propósito: b/d y p/q se distinguen
/// solo por la orientación, que es la confusión más común en dislexia. Las
/// últimas mezclan las cuatro, que es el caso difícil.
final List<GridGame> kGridGames = [
  _porLetra(
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
  _porLetra(
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
  _porLetra(
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
  _porLetra(
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
  _porLetra(
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
  _porLetra(
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
  _porLetra(
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
  _porLetra(
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
