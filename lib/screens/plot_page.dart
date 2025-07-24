import 'package:flutter/material.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/screens/moodidi_manager_page.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';
import 'package:treering/widgets/compute_stats.dart';
import 'package:treering/widgets/line_chart.dart';

class PlotPage extends StatefulWidget {
  static const routeName = '/plot';
  const PlotPage({Key? key}) : super(key: key);

  @override
  State<PlotPage> createState() => _PlotPageState();
}

class _PlotPageState extends State<PlotPage> {
  Moodidi? _selectedMoodidi;
  final int _visibleCount = 20;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _loadEntries();  // always refresh entries
  // }

  Future<void> _loadEntries() async {
    setState(() {
      _selectedMoodidi = null;
    });
  }

  Future<void> _loadEntriesFor(Moodidi m) async {
    setState(() {
      _selectedMoodidi = m;
    });
  }

  void _showPlotAgainst() async {
    final moodidis = await DatabaseHelper.instance.getMoodidiList();
    if (!mounted) return;
    if (moodidis.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('My Moodidi', textAlign: TextAlign.center),
          content: const Text('You currently have none.', textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(_);
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pushNamed(context, MoodidiManagerPage.routeName);
                });
              },
              child: const Text('Manage Moodidi'),
            ),
          ],
        ),
      );
      return;
    }
    String? sel;
    await showDialog(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
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
                    Navigator.of(context).pop();
                    if (sel != null) {
                      final chosen = moodidis.firstWhere((md) => md.keyword == sel);
                      _loadEntriesFor(chosen);
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ]
            )
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNav(
      currentIndex: 1,
      body: SafeArea(
        child:SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              // Replaced internal LineChart + tooltip stack with our new widget ---
              LineChartWidget(
                key: ValueKey(_selectedMoodidi?.id),
                selectedMoodidi: _selectedMoodidi,
                visibleCount: _visibleCount,
                //buildMoodTooltip: (entry) => buildMoodTooltip(context, entry),
                //buildAvgTooltip: (value) => buildAvgTooltip(context, value),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ComputeStats(
                    moodidi: _selectedMoodidi,
                  ),
                ]
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
      ),
    );
  }
}