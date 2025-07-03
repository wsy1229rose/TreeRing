import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/mood_entry.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/screens/moodidi_manager_page.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';
import 'dart:math';

class PlotPage extends StatefulWidget {
  static const routeName = '/plot';
  const PlotPage({super.key});
  @override
  State<PlotPage> createState() => _PlotPageState();
}

class _PlotPageState extends State<PlotPage> {
  List<MoodEntry> _entries = [];
  double medianValue = 0.0;
  double averageValue = 0.0;
  double stdDevValue = 0.0;
  String _dayOfWeekAbbrev(int weekday) {
    const days = ['Mon.', 'Tue.', 'Wed.', 'Thu.', 'Fri.', 'Sat.', 'Sun.'];
    return days[weekday % 7];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
      print('[DEBUG] fetching entries...');
      final all = await DatabaseHelper.instance.getMoodEntries();
      print('[DEBUG] retrieved ${all.length} entries');

      for (var entry in all) {
        print('[DEBUG] entry: ${entry.date} → ${entry.rating}');
      }

    // sort descending by date
    all.sort((a, b) =>
      DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    // show last 10 or fewer
    setState(() => _entries = all.take(10).toList());

    // compute statistics
    final latest = all.take(10).toList();
    final ratings = latest.map((e) => e.rating).toList();
    ratings.sort();
    final n = ratings.length;

    double median = n % 2 == 1
        ? ratings[n ~/ 2].toDouble()
        : (ratings[n ~/ 2 - 1] + ratings[n ~/ 2]) / 2.0;

    double avg = ratings.reduce((a, b) => a + b) / n;

    double variance = ratings
        .map((r) => pow(r - avg, 2))
        .reduce((a, b) => a + b) / n;

    double stddev = sqrt(variance);

    setState(() {
      _entries = latest;
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
                onPressed: () => Navigator.pop(_),
                child: const Text('Manage Moodidi'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: actually plot against sel
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

  Widget buildStatBox(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          //margin: const EdgeInsets.symmetric(horizontal: 4),
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


  @override
  Widget build(BuildContext context) {

    // newest entry shows up from the right (before showing up from the left)
    final reversedEntries = _entries.reversed.toList();

    final spots = <FlSpot>[];
    for (var i = 0; i < _entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), reversedEntries[i].rating.toDouble()));
    }
    return ScaffoldWithNav(
      currentIndex: 1,
      interacted: true,
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: _entries.isEmpty
            ? const Center(child: Text('No data yet.'))
            : Column(
                children: [
                  SizedBox(
                    height: 460,
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((touchedSpot) {
                                final index = touchedSpot.x.toInt();
                                final entry = reversedEntries[index];
                                return LineTooltipItem(
                                  'Mood: ${entry.rating}\n'
                                  '${entry.description?.isNotEmpty == true ? "note: ${entry.description}" : ""}\n'
                                  '${entry.photoPath != null ? "📷 Attached" : ""}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: false,
                            barWidth: 2,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final int index = value.toInt();
                                if (index < 0 || index >= reversedEntries.length) return const SizedBox();
                                final date = DateTime.parse(reversedEntries[index].date);
                                final dayLabel = _dayOfWeekAbbrev(date.weekday);
                                return Text(
                                  dayLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
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
                          onPressed: () =>
                              Navigator.pushNamed(context, '/record'),
                          child: const Text('View History')),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}