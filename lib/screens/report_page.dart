import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/mood_entry.dart';
import 'dart:math';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<MoodEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    final entries = await DatabaseHelper().getMoodEntries();
    setState(() {
      _entries = entries;
    });
  }

  double get average => _entries.isEmpty
      ? 0
      : _entries.map((e) => e.rating).reduce((a, b) => a + b) / _entries.length;

  double get median {
    if (_entries.isEmpty) return 0;
    List<int> sorted = _entries.map((e) => e.rating).toList()..sort();
    int middle = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  double get stddev {
    if (_entries.isEmpty) return 0;
    double avg = average;
    double sumSq = _entries.map((e) => pow(e.rating - avg, 2).toDouble()).reduce((a, b) => a + b);
    return sqrt(sumSq / _entries.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _entries.isEmpty
            ? Center(child: Text('No data yet.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average: [${average.toStringAsFixed(2)}'),
                  Text('Median: ${median.toStringAsFixed(2)}'),
                  Text('Std. Dev.: ${stddev.toStringAsFixed(2)}'),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final e = _entries[index];
                        return ListTile(
                          title: Text('${e.date.toLocal().toString().split(' ')[0]}: ${e.rating}'),
                          subtitle: Text('Factors: ${e.factors}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 