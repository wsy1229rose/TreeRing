import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyReportPage extends StatefulWidget {
  static const routeName = '/monthlyReport';
  const MonthlyReportPage({super.key});
  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  late String month;
  late List<int> data;
  late double avg, median, stddev;
  late int high, low;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    month = ModalRoute.of(context)!.settings.arguments as String? ??
        DateTime.now().month.toString();
    final rng = Random();
    final days = DateTime(
            DateTime.now().year,
            ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
                .indexOf(month) +
            1,
            0)
        .day;
    data = List.generate(days, (_) => rng.nextInt(5) - 2);
    final sorted = [...data]..sort();
    median = sorted.length.isOdd
        ? sorted[sorted.length ~/ 2].toDouble()
        : (sorted[sorted.length ~/ 2 - 1] +
                sorted[sorted.length ~/ 2]) /
            2;
    avg = data.reduce((a, b) => a + b) / data.length;
    stddev = sqrt(data
            .map((v) => pow(v - avg, 2))
            .reduce((a, b) => a + b) /
        data.length);
    high = sorted.last;
    low = sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].toDouble()),
    );
    // pick season color
    final mIdx = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
        .indexOf(month);
    Color lineColor;
    if (mIdx >= 2 && mIdx <= 4) lineColor = Colors.green;
    else if (mIdx >= 5 && mIdx <= 7) lineColor = Colors.blue;
    else if (mIdx >= 8 && mIdx <= 10) lineColor = Colors.orange;
    else lineColor = Colors.grey;

    return Scaffold(
      appBar: AppBar(title: Text(month)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: lineColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Median: ${median.toStringAsFixed(1)}'),
                Text('Std. Dev.: ${stddev.toStringAsFixed(1)}'),
                Text('Peaks: $high / $low'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Plot Against…'),
            ),
          ],
        ),
      ),
    );
  }
}
