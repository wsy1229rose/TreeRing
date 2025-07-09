import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/mood_entry.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/screens/moodidi_manager_page.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';

class PlotPage extends StatefulWidget {
  static const routeName = '/plot';
  const PlotPage({super.key});
  @override
  State<PlotPage> createState() => _PlotPageState();
}

class _PlotPageState extends State<PlotPage> {
  List<MoodEntry> _allEntries = [];
  List<MoodEntry> _entries = [];
  int _visibleCount = 7;

  Offset? _imageBoxOffset;
  MoodEntry? _tappedEntry;

  double medianValue = 0.0;
  double averageValue = 0.0;
  double stdDevValue = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    final all = await DatabaseHelper.instance.getMoodEntries();
    all.sort((a, b) =>
        DateTime.parse(b.date).compareTo(DateTime.parse(a.date))); // newest first

    setState(() {
      _allEntries = all;
      _entries = all.take(_visibleCount).toList().reversed.toList(); // oldest to newest
    });

    _computeStats();
  }

  void _computeStats() {
    final ratings = _entries.map((e) => e.rating).toList();
    if (ratings.isEmpty) return;
    final n = ratings.length;
    final sorted = [...ratings]..sort();
    final median = n % 2 == 1
        ? sorted[n ~/ 2].toDouble()
        : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
    final avg = ratings.reduce((a, b) => a + b) / n;
    final stddev = sqrt(ratings.map((r) => pow(r - avg, 2)).reduce((a, b) => a + b) / n);

    setState(() {
      medianValue = median;
      averageValue = avg;
      stdDevValue = stddev;
    });
  }

  void _showPlotAgainst() async {
    final moodidis = await DatabaseHelper.instance.getMoodidiList();
    if (moodidis.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('My Moodidi'),
          content: const Text('You currently have none.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(_);
                Future.delayed(Duration(milliseconds: 100), () {
                  Navigator.pushNamed(context, MoodidiManagerPage.routeName);
                });
              },
              child: const Text('Manage Moodidi'),
            ),
          ],
        ),
      );
    } else {
      String? sel;
      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (_, st) {
          return AlertDialog(
            title: const Text('Plot Against…'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: moodidis.map((m) {
                return RadioListTile<String>(
                  title: Text(m.keyword),
                  value: m.keyword,
                  groupValue: sel,
                  onChanged: (v) => st(() => sel = v),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(_);
                  Future.delayed(const Duration(milliseconds: 100), () async {
                    await Navigator.pushNamed(context, MoodidiManagerPage.routeName);
                    _showPlotAgainst(); 
                  });
                },
                child: const Text('Manage Moodidi'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: plot against selected Moodidi
                  Navigator.pop(_);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        }),
      );
    }
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
            Expanded(child: Image.file(File(imagePath), fit: BoxFit.contain)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reversed = _entries;
    final spots = <FlSpot>[];
    final cumulativeAvgSpots = <FlSpot>[];
    double sum = 0;

    for (int i = 0; i < reversed.length; i++) {
      final r = reversed[i].rating.toDouble();
      spots.add(FlSpot(i.toDouble(), r));
      sum += r;
      cumulativeAvgSpots.add(FlSpot(i.toDouble(), sum / (i + 1)));
    }

    return ScaffoldWithNav(
      currentIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: _entries.isEmpty
            ? const Center(child: Text('No data yet.'))
            : Column(
                children: [
                  SizedBox(
                    height: 460,
                    child: GestureDetector(
                      onScaleUpdate: (details) {
                        if (details.scale < 0.9) {
                          setState(() {
                            _visibleCount = _visibleCount < 30 ? 30 : (_visibleCount < 100 ? 100 : _allEntries.length);
                            _entries = _allEntries.take(_visibleCount).toList().reversed.toList();
                            _computeStats();
                          });
                        }
                      },
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
                                    final entry = reversed[index];
                                    if (entry.photoPath != null && entry.photoPath!.isNotEmpty) {
                                      final localPos = event.localPosition;

                                      // Adjust to avoid going offscreen
                                      final dx = localPos.dx.clamp(10.0, MediaQuery.of(context).size.width - 110);
                                      final dy = localPos.dy.clamp(10.0, 460 - 110);

                                      setState(() {
                                        _imageBoxOffset = Offset(dx.toDouble(), dy.toDouble());
                                        _tappedEntry = entry;
                                      });
                                    }
                                  }
                                },
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: false,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: true),
                                ),
                                LineChartBarData(
                                  spots: List.generate(spots.length, (i) => FlSpot(i.toDouble(), averageValue)),
                                  isCurved: false,
                                  barWidth: 1.5,
                                  color: Colors.grey,
                                  dashArray: [5, 5],
                                  dotData: const FlDotData(show: false),
                                ),
                                LineChartBarData(
                                  spots: cumulativeAvgSpots,
                                  isCurved: true,
                                  barWidth: 2,
                                  color: Colors.yellow.shade200,
                                  dotData: const FlDotData(show: false),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: (_visibleCount / 7).ceilToDouble(),
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= reversed.length) return const SizedBox();
                                      final date = DateTime.parse(reversed[index].date);
                                      return Text(
                                        "${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}",
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      );
                                    },
                                  ),
                                ),
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
                                    if (_tappedEntry!.description != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _tappedEntry!.description!,
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
                      buildStatBox('Median', medianValue),
                      buildStatBox('Average', averageValue),
                      buildStatBox('Std Dev', stdDevValue),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: _showPlotAgainst,
                          child: const Text('Plot Against…')),
                      ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/record'),
                          child: const Text('View History')),
                    ],
                  ),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
}