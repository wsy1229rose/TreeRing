import 'package:flutter/material.dart';
import '../widgets/mood_wheel.dart';
import '../db/database_helper.dart';
import '../models/mood_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _moodValue = 0;
  Map<String, bool> _factors = {
    'Physically Active': false,
    'Screen Time > 1h': false,
    'At Home': false,
  };

  void _submitMood() async {
    final entry = MoodEntry(
      date: DateTime.now(),
      rating: _moodValue,
      factors: Map.from(_factors),
    );
    await DatabaseHelper().insertMoodEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mood saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TreeRing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('How was your day?', style: TextStyle(fontSize: 20)),
            MoodWheel(
              value: _moodValue,
              onChanged: (index) {
                setState(() {
                  _moodValue = index - 10;
                });
              },
            ),
            SizedBox(height: 20),
            ..._factors.keys.map((factor) => CheckboxListTile(
                  title: Text(factor),
                  value: _factors[factor],
                  onChanged: (val) {
                    setState(() {
                      _factors[factor] = val ?? false;
                    });
                  },
                )),
            Spacer(),
            ElevatedButton(
              onPressed: _submitMood,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
} 