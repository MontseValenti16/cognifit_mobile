import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tracking_entity.dart';

class LearningCurveChart extends StatelessWidget {
  final LearningCurveEntity curve;
  const LearningCurveChart({super.key, required this.curve});

  @override
  Widget build(BuildContext context) {
    final diagPoints = _diagSpots();
    final exerPoints = _exerSpots();

    if (diagPoints.isEmpty && exerPoints.isEmpty) {
      return _EmptyChart();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Legend(),
      const SizedBox(height: 12),
      SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppTheme.outline.withValues(alpha: 0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 25,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF9E9CAD))),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, _) => Text('S${v.toInt()}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF9E9CAD))),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                  '${s.y.toStringAsFixed(0)}%',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                )).toList(),
              ),
            ),
            lineBarsData: [
              if (diagPoints.isNotEmpty)
                _line(diagPoints, AppTheme.primary),
              if (exerPoints.isNotEmpty)
                _line(exerPoints, AppTheme.tertiary),
            ],
          ),
        ),
      ),
    ]);
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) => LineChartBarData(
    spots: spots,
    isCurved: true,
    curveSmoothness: 0.3,
    color: color,
    barWidth: 2.5,
    dotData: FlDotData(
      show: true,
      getDotPainter: (spot, xp, bar, idx) => FlDotCirclePainter(
        radius: 3.5,
        color: color,
        strokeWidth: 0,
      ),
    ),
    belowBarData: BarAreaData(
      show: true,
      color: color.withValues(alpha: 0.08),
    ),
  );

  List<FlSpot> _diagSpots() => curve.diagnosticSessions
      .asMap()
      .entries
      .map((e) => FlSpot((e.key + 1).toDouble(), (e.value.accuracy * 100).clamp(0, 100)))
      .toList();

  List<FlSpot> _exerSpots() => curve.exerciseSessions
      .asMap()
      .entries
      .map((e) => FlSpot((e.key + 1).toDouble(), (e.value.accuracyPct * 100).clamp(0, 100)))
      .toList();
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
    _LegendDot(color: AppTheme.primary, label: 'Diagnóstico'),
    const SizedBox(width: 16),
    _LegendDot(color: AppTheme.tertiary, label: 'Ejercicios'),
  ]);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B6880))),
  ]);
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 160,
    decoration: BoxDecoration(
      color: AppTheme.outline.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.outline.withValues(alpha: 0.3)),
    ),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.show_chart_rounded, size: 36, color: AppTheme.outline.withValues(alpha: 0.5)),
      const SizedBox(height: 8),
      Text('Aún no hay sesiones registradas',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD))),
    ])),
  );
}
