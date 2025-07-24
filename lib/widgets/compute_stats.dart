import 'dart:math';
import 'package:flutter/material.dart';
import '../models/moodidi.dart';
import '../models/mood_entry.dart';
import 'package:treering/db/database_helper.dart';

// A widget that displays average, median, and standard deviation
/// statistics for mood entries. If a yes/no moodidi is selected, it
/// shows separate stats for yes and no days. Otherwise, it shows
/// overall stats for all mood entries.
class ComputeStats extends StatefulWidget {
  final Moodidi? moodidi;

  const ComputeStats({
    Key? key,
    this.moodidi,
  }) : super(key: key);

  @override
  State<ComputeStats> createState() => _ComputeStatsState();
}

class _ComputeStatsState extends State<ComputeStats> {
  List<MoodEntry> moodEntries = [];
  List<MoodEntry> yesEntries = [];
  List<MoodEntry> noEntries = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final all = await DatabaseHelper.instance.getAllMoodEntries();
    final moodidi = widget.moodidi;

    final yes = <MoodEntry>[];
    final no = <MoodEntry>[];

    if (moodidi != null) {
      for (final entry in all) {
        final response = entry.responses?[moodidi.keyword];
        if (response == true) {
          yes.add(entry);
        } else if (response == false) {
          no.add(entry);
        }
      }
    }

    setState(() {
      moodEntries = all;
      yesEntries = yes;
      noEntries = no;
    });
  }

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
    // Case: yes/no moodidi selected
    if (widget.moodidi != null && !widget.moodidi!.isNumeric) {
      final yesVals = yesEntries.map((e) => e.rating.toDouble()).toList();
      final noVals  = noEntries.map((e) => e.rating.toDouble()).toList();

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

    // Default case: no moodidi selected or numeric moodidi: overall stats
    final allVals = moodEntries.map((e) => e.rating.toDouble()).toList();
    final avg   = _mean(allVals).toStringAsFixed(1);
    final med   = _median(allVals).toStringAsFixed(1);
    final std   = _stdDev(allVals).toStringAsFixed(1);

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