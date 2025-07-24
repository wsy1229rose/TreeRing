import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/mood_entry.dart';
import 'package:treering/models/moodidi_entry.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/widgets/mood_wheel.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _interacted = false;
  int _moodValue = 0;
  String? _description;
  XFile? _photo;
  Map<String, dynamic> _responses = {};

  //Future<void> _save() async {
    // check existing
    // final today = DateTime.now().toIso8601String().split('T').first;
    // final existing = await DatabaseHelper.instance.getEntryByDate(today);
    // if (existing != null) {
    //   final ok = await showDialog<bool>(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: const Text('Overwrite entry?'),
    //       content: const Text(
    //           'You already saved a rating today. Overwrite it?'),
    //       actions: [
    //         TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('No')),
    //         TextButton(onPressed: () => Navigator.pop(_, true), child: const Text('Yes')),
    //       ],
    //     ),
    //   );
    //   if (ok != true) return;
    //   DateTime parsedDate = DateTime.parse(today);
    //   await DatabaseHelper.instance.deleteEntry(parsedDate);
    // }

  Future<void> _showSavePopup() async {
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setSt) {
          return AlertDialog(
            title: const Text('Want to drop some notes?', style: TextStyle(fontSize: 32,)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  minLines: 1,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: 'something to say about the day…',
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  onChanged: (s) => _description = s,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_photo == null) ...[
                      const Text('or drop a '),
                      ElevatedButton(
                        onPressed: () async {
                          final img = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            maxHeight: 800,
                            maxWidth: 800,
                          );
                          if (img != null) setSt(() => _photo = img);
                        },
                        child: const Text('photo'),
                      )
                    ] else
                      const Text('picture selected'), 
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(_, null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(_, true);
                  _save();
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final moodidis = await DatabaseHelper.instance.getMoodidiList();

    // Ask all Moodidi questions and store responses
    for (var m in moodidis) {
      final response = await _askMoodidi(m);
      _responses[m.keyword] = response;
    }

    final entry = MoodEntry(
      id: null,
      date: today,
      rating: _moodValue,
      description: _description,
      photoPath: _photo?.path,
      responses: _responses.isEmpty ? null : _responses,
    );
    await DatabaseHelper.instance.insertMoodEntry(entry);
    debugPrint('[RESPONSES] ${jsonEncode(entry.responses)}');

    // Save each MoodidiEntry based on MoodEntry.responses
    for (final kv in (entry.responses ?? {}).entries) {
      final e = MoodidiEntry(
        keyword: kv.key,
        entry: (kv.value is bool)
            ? (kv.value == true ? 1.0 : 0.0)
            : (kv.value as num).toDouble(),
      );
      await DatabaseHelper.instance.insertMoodidiEntry(e);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content successfully updated!')),
    );
    setState(() {
      _photo = null;
      _description = null;
      _responses.clear();
    });
  }

  Future<dynamic> _askMoodidi(Moodidi m) async {
    dynamic result = await showDialog<dynamic>(
      context: context,
      builder: (_) {
        if (m.type == 'yesno') {
          return AlertDialog(
            title: Text(m.prompt),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(_, true),
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () => Navigator.pop(_, false),
                  child: const Text('No')),
            ],
          );
        } else {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: Text(m.prompt),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Enter number'),
            ),
            actions: [
              TextButton(
                  onPressed: () =>
                      Navigator.pop(_, double.tryParse(ctrl.text) ?? 0.0),
                  child: const Text('Submit')),
            ],
          );
        }
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNav(
      currentIndex: 0,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
         child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'How was the day...',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),  
              const SizedBox(height: 30),
              MoodWheel(
                interacted: _interacted,
                onInteracted: () => setState(() => _interacted = true),
                value: _moodValue,
                onChanged: (v) => setState(() => _moodValue = v),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _showSavePopup,
                child: const Text(
                  'save',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
