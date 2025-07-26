import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

double mean(List<double> xs) {
  if (xs.isEmpty) return 0.0;
  return xs.reduce((a, b) => a + b) / xs.length;
}

double stdDev(List<double> xs) {
  if (xs.isEmpty) return 0.0;
  final meanValue = mean(xs);
  final variance = xs.map((x) => pow(x - meanValue, 2)).reduce((a, b) => a + b) / xs.length;
  return sqrt(variance);
}

/// Returns a list of FlSpot where moodidi values are normalized to the mood scale.
/// Nulls in rawSeries are skipped (no spot is plotted at that index).
List<FlSpot> normalizeSeries({
  required List<double> original,
  required List<dynamic> rawSeries, // can contain nulls
}) {
  final cleanSeries = rawSeries
      .where((v) => v != null)
      .map((v) => (v as num).toDouble())
      .toList();

  final meanMood = mean(original);
  final stdMood = stdDev(original);
  final meanSeries = mean(cleanSeries);
  final stdSeries = stdDev(cleanSeries);

  if (stdSeries == 0) {
    // fallback to flat line at mood mean if std-dev is zero
    return List.generate(original.length, (i) {
      final v = rawSeries[i];
      return v != null ? FlSpot(i.toDouble(), meanMood) : null;
    }).whereType<FlSpot>().toList();
  }

  int normIdx = 0;
  final normalizedSpots = <FlSpot>[];

  for (int i = 0; i < rawSeries.length; i++) {
    final rawVal = rawSeries[i];
    if (rawVal != null) {
      final v = cleanSeries[normIdx++];
      final normalized = ((v - meanSeries) / stdSeries) * stdMood + meanMood;
      normalizedSpots.add(FlSpot(i.toDouble(), normalized));
    }
  }

  return normalizedSpots;
}


/// Normalizes [series] so it has the same mean and std-dev as [original].
/*List<double> normalizeSeries({
  required List<double> original,
  required List<double> series,
}) {
  final meanVMood = mean(original);
  final sdMood = stdDev(original);
  final meanVMi   = mean(series);
  final sdMi   = stdDev(series);

  if (sdMi == 0) {
    // avoid division by zero—just shift series to the mood mean
    return series.map((v) => meanVMood).toList();
  }

  return series.map((v) {
    return ((v - meanVMi) / sdMi) * sdMood + meanVMood;
  }).toList();
}*/
