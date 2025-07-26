import 'dart:math';
import 'package:flutter/material.dart';
import '../models/moodidi.dart';
import 'line_chart.dart'; // ← Import chart data

// A widget that displays average, median, and standard deviation
/// statistics for mood entries. If a yes/no moodidi is selected, it
/// shows separate stats for yes and no days. Otherwise, it shows
/// overall stats for all mood entries.
class ComputeStats extends StatelessWidget {
  final Moodidi? moodidi;

  const ComputeStats({
    Key? key,
    this.moodidi,
  }) : super(key: key);

  double _mean(List<double> xs) {
    if (xs.isEmpty) return 0.0;
    return xs.reduce((a, b) => a + b) / xs.length;
  }

  double _stdDev(List<double> xs) {
    if (xs.isEmpty) return 0.0;
    final meanValue = _mean(xs);
    final variance = xs.map((x) => (x - meanValue) * (x - meanValue)).reduce((a, b) => a + b) / xs.length;
    return sqrt(variance);
  }

  double _median(List<double> xs) {
    if (xs.isEmpty) return 0.0;
    final sorted = [...xs]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final chartState = context.findAncestorStateOfType<LineChartWidgetState>();

    if (chartState == null) {
      return const Text('Error: No chart state found');
    }

    if (moodidi != null && !moodidi!.isNumeric) {
      final yesVals = chartState.yesSpots.map((s) => s.y).toList();
      final noVals  = chartState.noSpots.map((s) => s.y).toList();

      final avgYes = _mean(yesVals).toStringAsFixed(1);
      final medYes = _median(yesVals).toStringAsFixed(1);
      final stdYes = _stdDev(yesVals).toStringAsFixed(1);
      final avgNo  = _mean(noVals).toStringAsFixed(1);
      final medNo  = _median(noVals).toStringAsFixed(1);
      final stdNo  = _stdDev(noVals).toStringAsFixed(1);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildStatBox('Median', '$medYes/$medNo'),
          const SizedBox(width: 24),
          buildStatBox('Average', '$avgYes/$avgNo'),
          const SizedBox(width: 24),
          buildStatBox('Std Dev', '$stdYes/$stdNo'),
        ],
      );
    }

    final allVals = chartState.moodSpots.map((s) => s.y).toList();
    final avg = _mean(allVals).toStringAsFixed(1);
    final med = _median(allVals).toStringAsFixed(1);
    final std = _stdDev(allVals).toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildStatBox('Median', med),
        const SizedBox(width: 24),
        buildStatBox('Average', avg),
        const SizedBox(width: 24),
        buildStatBox('Std Dev', std),
      ],
    );
  }

  Widget buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 80,
          height: 40,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(value, style: const TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ],
    );
  }
}