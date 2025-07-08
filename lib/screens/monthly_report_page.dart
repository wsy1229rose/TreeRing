import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';

class MonthlyReportPage extends StatefulWidget {
  static const routeName = '/monthlyReport';
  const MonthlyReportPage({super.key});
  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class MoodEntry {
  final int rating;
  final String? note;
  final String? photoPath;
  final int day;
  MoodEntry({required this.rating, this.note, this.photoPath, required this.day});
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  late String month;
  late List<MoodEntry> entries;
  late double avg, median, stddev;
  late int high, low;
  Offset? _imageBoxOffset;
  MoodEntry? _tappedEntry;
  bool _showHigh = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    month = ModalRoute.of(context)!.settings.arguments as String? ??
        DateTime.now().month.toString();

    final rng = Random();
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthIdx = monthNames.indexWhere((m) => m.startsWith(month));
    final days = DateTime(DateTime.now().year, monthIdx + 2, 0).day;

    entries = List.generate(days, (i) {
      final rating = rng.nextInt(5) - 2;
      final note = rng.nextBool() ? 'Felt ${["good", "meh", "bad"][rng.nextInt(3)]}' : null;
      final photo = rng.nextBool() ? null : '/path/to/fake/image_${i + 1}.jpg';
      return MoodEntry(rating: rating, note: note, photoPath: photo, day: i + 1);
    });

    final ratings = entries.map((e) => e.rating).toList();
    final sorted = [...ratings]..sort();
    final n = ratings.length;
    median = n % 2 == 1
        ? sorted[n ~/ 2].toDouble()
        : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
    avg = ratings.reduce((a, b) => a + b) / n;
    stddev = sqrt(ratings.map((v) => pow(v - avg, 2)).reduce((a, b) => a + b) / n);
    high = sorted.last;
    low = sorted.first;
  }

  void _showFullscreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  Widget buildStatBox(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget buildPeakToggleBox() {
    return GestureDetector(
      onTap: () => setState(() => _showHigh = !_showHigh),
      child: Column(
        children: [
          const Text(
            'Peak',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _showHigh ? 'High: $high' : 'Low: $low',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = entries
        .map((e) => FlSpot((e.day - 1).toDouble(), e.rating.toDouble()))
        .toList();
    final avgLine = List.generate(
      entries.length,
      (i) => FlSpot(i.toDouble(), avg),
    );
    final cumulativeAvgSpots = <FlSpot>[];
    double runningSum = 0;
    for (int i = 0; i < entries.length; i++) {
      runningSum += entries[i].rating;
      final runningAvg = runningSum / (i + 1);
      cumulativeAvgSpots.add(FlSpot(i.toDouble(), runningAvg));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, 
        centerTitle: true,
        title: Text(
          month,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            SizedBox(
              height: 460,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) {
                  setState(() {
                    _imageBoxOffset = null;
                    _tappedEntry = null;
                  });
                },
                child: Stack(
                  children: [
                    LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            if (event is FlTapUpEvent && response != null) {
                              final spot = response.lineBarSpots?.first;
                              if (spot == null) return;
                              final index = spot.x.toInt();
                              final entry = entries[index];
                              if (entry.photoPath != null) {
                                final dx = event.localPosition.dx.clamp(10.0, MediaQuery.of(context).size.width - 110);
                                final dy = event.localPosition.dy.clamp(10.0, 460 - 140);
                                setState(() {
                                  _imageBoxOffset = Offset(dx.toDouble(), dy.toDouble());
                                  _tappedEntry = entry;
                                });
                              }
                            }
                          },
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((s) {
                                final idx = s.x.toInt();
                                final entry = entries[idx];
                                return LineTooltipItem(
                                  'Mood: ${entry.rating}',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
			lineBarsData: [
			  // main mood data
			  LineChartBarData(
			    spots: spots,
			    isCurved: false,
			    barWidth: 2,
			    dotData: const FlDotData(show: true),
			  ),

			  // average dashed line
			  LineChartBarData(
			    spots: List.generate(entries.length, (i) => FlSpot(i.toDouble(), avg)),
			    isCurved: false,
			    barWidth: 1.5,
			    color: Colors.grey,
			    dotData: const FlDotData(show: false),
			    dashArray: [5, 5],
			  ),

			  // changing average curve
			  LineChartBarData(
			    spots: cumulativeAvgSpots,
			    isCurved: true,
 			    barWidth: 2,
			    color: Colors.yellow.shade200,
			    dotData: const FlDotData(show: false),
			  ),
			],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, _) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final day = value.toInt() + 1;
                                return (day % 5 == 0)
                                    ? Text('$day', style: const TextStyle(color: Colors.white, fontSize: 12))
                                    : const SizedBox.shrink();
                              },
                              interval: 1,
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                    if (_imageBoxOffset != null && _tappedEntry != null)
                      Positioned(
                        left: _imageBoxOffset!.dx,
                        top: _imageBoxOffset!.dy,
                        child: Container(
                          width: 110,
                          height: 130,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
                            ],
                          ),
                          child: Column(
                            children: [
			      GestureDetector(
  				onTap: () => _showFullscreenImage(_tappedEntry!.photoPath!),
  				child: ClipRRect(
    				  borderRadius: BorderRadius.circular(6),
    				  child: Image.file(
      				    File(_tappedEntry!.photoPath!),
      				    height: 80,
      				    width: 100,
      				    fit: BoxFit.cover,
    				  ),
  				),
			      ),
                              if (_tappedEntry!.note != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _tappedEntry!.note!,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildStatBox('Median', median),
                buildStatBox('Std Dev', stddev),
                buildPeakToggleBox(),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Plot Against…'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
