import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/mood_entry.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/widgets/mood_wheel.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';
import 'package:treering/screens/plot_page.dart';

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

  void _onInteract([_]) {
    if (!_interacted) setState(() => _interacted = true);
  }

  Future<void> _save() async {
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

    final today = DateTime.now().toIso8601String().split('T').first;

    // collect Moodidi responses
    final moodidis = await DatabaseHelper.instance.getMoodidiList();
    for (var m in moodidis) {
      final response = await _askMoodidi(m);
      _responses[m.keyword] = response;
    }

    final entry = MoodEntry(
      date: today,
      rating: _moodValue,
      description: _description,
      photoPath: _photo?.path,
      responses: _responses.isEmpty ? null : _responses,
    );
    await DatabaseHelper.instance.insertMoodEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content successfully updated!')),
    );
    setState(() {
      _photo = null;
      _description = null;
      _responses.clear();
    });
  }

  Future<dynamic> _askMoodidi(Moodidi m) {
    return showDialog<dynamic>(
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter number'),
            ),
            actions: [
              TextButton(
                  onPressed: () =>
                      Navigator.pop(_, int.tryParse(ctrl.text) ?? 0),
                  child: const Text('Submit')),
            ],
          );
        }
      },
    );
  }

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
                    const Text('or drop a '),
                    ElevatedButton(
                      onPressed: () async {
                        final img = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxHeight: 800,
                          maxWidth: 800,
                        );
                        if (img != null) setState(() => _photo = img);
                      },
                      child: const Text('photo'),
                    ),
                    if (_photo == null) const SizedBox(width: 8),
                    if (_photo != null) const Text('picture selected'),
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNav(
      currentIndex: 0,
      interacted: _interacted,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onInteract,
        onPanUpdate: _onInteract,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _interacted ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: const Text(
                  'How was the day...',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),

              // ✅ MoodWheel is always visible
              MoodWheel(
                interacted: _interacted,
                onInteracted: () => setState(() => _interacted = true),
                value: _moodValue,
                onChanged: (v) => setState(() => _moodValue = v),
              ),

              const SizedBox(height: 30),

              AnimatedOpacity(
                opacity: _interacted ? 1.0 : 0.0,
                duration: const Duration(seconds: 3),
                child: ElevatedButton(
                  onPressed: _showSavePopup,
                  child: const Text(
                    'save',
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
