import 'dart:math';

/// Computes the mean of [xs].
double mean(List<double> xs) {
  if (xs.isEmpty) return 0.0;
  return xs.reduce((a, b) => a + b) / xs.length;
}

/// Computes the population standard deviation of [xs].
double stdDev(List<double> xs) {
  if (xs.isEmpty) return 0.0;
  final meanValue = mean(xs);
  final variance = xs
      .map((x) => (x - meanValue) * (x - meanValue))
      .reduce((a, b) => a + b) /
    xs.length;
  return sqrt(variance);
}

/// Normalizes [series] so it has the same mean and std-dev as [original].
List<double> normalizeSeries({
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
}
