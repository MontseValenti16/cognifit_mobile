import 'dart:math';

enum ChildExerciseType { letter, syllable, word, direction }

class ChildExercise {
  final String id;
  final String sectionLabel;
  final String question;
  final String instruction;
  final String mainOption;
  final String oddOption;
  final String explanation;
  final ChildExerciseType type;
  final int difficulty;

  const ChildExercise({
    required this.id,
    required this.sectionLabel,
    required this.question,
    required this.instruction,
    required this.mainOption,
    required this.oddOption,
    required this.explanation,
    required this.type,
    this.difficulty = 1,
  });

  List<String> shuffledOptions(int seed) {
    final list = [mainOption, mainOption, mainOption, oddOption];
    list.shuffle(Random(seed));
    return list;
  }
}

const List<ChildExercise> kChildExercises = [
  // A1 — b / d  (confusión más frecuente en dislexia)
  ChildExercise(
    id: 'VD_01', sectionLabel: 'A1 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: 'Mira hacia dónde apunta la barriga de la letra.',
    mainOption: 'b', oddOption: 'd',
    explanation: '"d" tiene la barriga hacia el lado contrario de "b".',
    type: ChildExerciseType.letter, difficulty: 1,
  ),
  ChildExercise(
    id: 'VD_02', sectionLabel: 'A1 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: 'Mira la dirección de la barriga de cada letra.',
    mainOption: 'd', oddOption: 'b',
    explanation: '"b" tiene la barriga al otro lado que "d".',
    type: ChildExerciseType.letter, difficulty: 1,
  ),
  // A2 — p / q
  ChildExercise(
    id: 'VD_03', sectionLabel: 'A2 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: '¿Cuál letra tiene la cola diferente?',
    mainOption: 'p', oddOption: 'q',
    explanation: '"q" tiene la cola al lado contrario de "p".',
    type: ChildExerciseType.letter, difficulty: 1,
  ),
  ChildExercise(
    id: 'VD_04', sectionLabel: 'A2 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: '¿Cuál letra tiene la cola diferente?',
    mainOption: 'q', oddOption: 'p',
    explanation: '"p" tiene la cola al lado contrario de "q".',
    type: ChildExerciseType.letter, difficulty: 1,
  ),
  // A3 — n / u
  ChildExercise(
    id: 'VD_05', sectionLabel: 'A3 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: 'Una letra está girada. ¿Cuál es?',
    mainOption: 'n', oddOption: 'u',
    explanation: '"u" es "n" girada boca abajo.',
    type: ChildExerciseType.letter, difficulty: 1,
  ),
  ChildExercise(
    id: 'VD_06', sectionLabel: 'A3 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: 'Una letra está girada. ¿Cuál es?',
    mainOption: 'u', oddOption: 'n',
    explanation: '"n" es "u" girada boca arriba.',
    type: ChildExerciseType.letter, difficulty: 1,
  ),
  // A4 — b / p
  ChildExercise(
    id: 'VD_07', sectionLabel: 'A4 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: '¿Cuál tiene la barriga apuntando diferente?',
    mainOption: 'b', oddOption: 'p',
    explanation: '"p" tiene la barriga hacia abajo.',
    type: ChildExerciseType.letter, difficulty: 2,
  ),
  ChildExercise(
    id: 'VD_08', sectionLabel: 'A4 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: '¿Cuál tiene la barriga apuntando diferente?',
    mainOption: 'p', oddOption: 'b',
    explanation: '"b" tiene la barriga hacia arriba.',
    type: ChildExerciseType.letter, difficulty: 2,
  ),
  // A5 — d / q
  ChildExercise(
    id: 'VD_09', sectionLabel: 'A5 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: '¿Cuál letra tiene la cola diferente?',
    mainOption: 'd', oddOption: 'q',
    explanation: '"q" tiene la cola hacia abajo, "d" la tiene hacia arriba.',
    type: ChildExerciseType.letter, difficulty: 2,
  ),
  // A6 — m / n
  ChildExercise(
    id: 'VD_10', sectionLabel: 'A6 · DISCRIMINACIÓN VISUAL',
    question: '¿Cuál es diferente?',
    instruction: 'Cuenta las patas de cada letra.',
    mainOption: 'm', oddOption: 'n',
    explanation: '"n" tiene solo dos patas, "m" tiene tres.',
    type: ChildExerciseType.letter, difficulty: 2,
  ),
  // B — Sílabas
  ChildExercise(
    id: 'VD_11', sectionLabel: 'B1 · SÍLABAS',
    question: '¿Cuál sílaba es diferente?',
    instruction: '¿Cuál empieza con diferente letra?',
    mainOption: 'ba', oddOption: 'da',
    explanation: '"da" empieza con "d", no con "b".',
    type: ChildExerciseType.syllable, difficulty: 2,
  ),
  ChildExercise(
    id: 'VD_12', sectionLabel: 'B1 · SÍLABAS',
    question: '¿Cuál sílaba es diferente?',
    instruction: '¿Cuál empieza con diferente letra?',
    mainOption: 'de', oddOption: 'be',
    explanation: '"be" empieza con "b", no con "d".',
    type: ChildExerciseType.syllable, difficulty: 2,
  ),
  ChildExercise(
    id: 'VD_13', sectionLabel: 'B2 · SÍLABAS',
    question: '¿Cuál sílaba es diferente?',
    instruction: '¿Cuál empieza con diferente letra?',
    mainOption: 'pi', oddOption: 'bi',
    explanation: '"bi" empieza con "b", no con "p".',
    type: ChildExerciseType.syllable, difficulty: 2,
  ),
  ChildExercise(
    id: 'VD_14', sectionLabel: 'B2 · SÍLABAS',
    question: '¿Cuál sílaba es diferente?',
    instruction: '¿Cuál empieza con diferente letra?',
    mainOption: 'po', oddOption: 'bo',
    explanation: '"bo" empieza con "b", no con "p".',
    type: ChildExerciseType.syllable, difficulty: 2,
  ),
  // C — Palabras invertidas (inversiones especulares)
  ChildExercise(
    id: 'VD_15', sectionLabel: 'C1 · PALABRAS',
    question: '¿Cuál palabra está al revés?',
    instruction: 'Una palabra está escrita al revés. ¿Cuál es?',
    mainOption: 'sol', oddOption: 'los',
    explanation: '"los" es "sol" escrito al revés.',
    type: ChildExerciseType.word, difficulty: 3,
  ),
  ChildExercise(
    id: 'VD_16', sectionLabel: 'C1 · PALABRAS',
    question: '¿Cuál palabra está al revés?',
    instruction: 'Una está escrita al revés. ¿Cuál es?',
    mainOption: 'la', oddOption: 'al',
    explanation: '"al" es "la" escrito al revés.',
    type: ChildExerciseType.word, difficulty: 3,
  ),
  ChildExercise(
    id: 'VD_17', sectionLabel: 'C2 · PALABRAS',
    question: '¿Cuál palabra está al revés?',
    instruction: '¿Cuál está escrita diferente a las demás?',
    mainOption: 'nos', oddOption: 'son',
    explanation: '"son" es "nos" escrito al revés.',
    type: ChildExerciseType.word, difficulty: 3,
  ),
  ChildExercise(
    id: 'VD_18', sectionLabel: 'C2 · PALABRAS',
    question: '¿Cuál palabra está al revés?',
    instruction: '¿Cuál está escrita diferente a las demás?',
    mainOption: 'es', oddOption: 'se',
    explanation: '"se" es "es" escrito al revés.',
    type: ChildExerciseType.word, difficulty: 3,
  ),
  // D — Direcciones (flechas — del cuadernillo pág. 8)
  ChildExercise(
    id: 'VD_19', sectionLabel: 'D1 · DIRECCIONES',
    question: '¿Cuál flecha apunta diferente?',
    instruction: 'La mayoría apuntan igual. ¿Cuál es la diferente?',
    mainOption: '→', oddOption: '←',
    explanation: 'Esa flecha apunta a la izquierda, las demás a la derecha.',
    type: ChildExerciseType.direction, difficulty: 2,
  ),
  ChildExercise(
    id: 'VD_20', sectionLabel: 'D1 · DIRECCIONES',
    question: '¿Cuál flecha apunta diferente?',
    instruction: 'La mayoría apuntan igual. ¿Cuál es la diferente?',
    mainOption: '←', oddOption: '→',
    explanation: 'Esa flecha apunta a la derecha, las demás a la izquierda.',
    type: ChildExerciseType.direction, difficulty: 2,
  ),
];

/// Devuelve [count] ejercicios aleatorios usando [seed] como semilla — determinista
/// dentro de una sesión, diferente entre sesiones.
List<ChildExercise> pickExercises({int count = 10, required int seed}) {
  final shuffled = List<ChildExercise>.from(kChildExercises)..shuffle(Random(seed));
  return shuffled.take(count).toList();
}
