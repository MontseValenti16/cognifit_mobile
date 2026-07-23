/// El backend manda varios campos como slugs en snake_case (p. ej.
/// "sin_riesgo", "visual_superficial"). Esto los pasa a algo presentable:
/// "Sin Riesgo", "Visual Superficial".
String slugToLabel(String value) => value
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');
