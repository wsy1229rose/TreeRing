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
  List<MoodEntry> _entries = [];

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

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < _entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _entries[i].rating.toDouble()));
    }
    return ScaffoldWithNav(
      currentIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _entries.isEmpty
            ? const Center(child: Text('No data yet.'))
            : Column(
                children: [
                  Expanded(
                    child: LineChart(
                LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: false,
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
                    children: const [
                      Text('Median:'),
                      Text('Average:'),
                      Text('S.D.:'),
                    ],
                  ),
                  const SizedBox(height: 8),
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