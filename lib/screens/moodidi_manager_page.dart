import 'package:flutter/material.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';
import 'package:treering/widgets/moodidi_creation_dialog.dart';
import 'package:flutter/gestures.dart';

class MoodidiManagerPage extends StatefulWidget {
  static const routeName = '/moodidiManager';
  const MoodidiManagerPage({super.key});

  @override
  State<MoodidiManagerPage> createState() => _MoodidiManagerPageState();
}

class _MoodidiManagerPageState extends State<MoodidiManagerPage> {
  Future<List<Moodidi>> _fetchMoodidis() {
    return DatabaseHelper.instance.getMoodidiList();
  }

  void _showWhatIs() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Center(child: Text('What is a Moodidi?')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text:
                    '          You could use this feature to find out whether something (a factor) can positively / negatively / not influence your mood by looking at its correlation with your happiness. If you don’t know what might influence your mood, here is where you can ',
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'start',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pop(_);
                        _showInspiration();
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



void _showInspiration() {
  final suggestions = [
    ['Weather', 'Are you a sun-day person or have a rainy mood'],
    ['Sleeping time', 'Sleep well always helps'],
    ['Socializing', 'Have I talked to someone today? Am I happier from this social interaction?'],
    ['Physical activeness', 'Have you see the sun!'],
    ['Screen time', 'Is scrolling that endless pit fueling us?'],
    ['Location', ''],
  ];

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        'Have you ever wondered how the following factors might influence your mood …?',
        style: TextStyle(fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions.map((entry) {
            final keyword = entry[0];
            final subtitle = entry[1];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              title: Text(keyword),
              subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
              trailing: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(_);
                  final created = await showDialog(
                    context: context,
                    builder: (_) => MoodidiCreationDialog(initialKeyword: keyword),
                  );
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('set up'),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Moodidi Manager',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(onPressed: _showWhatIs, icon: const Icon(Icons.help)),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // Moodidi list with auto-refreshing FutureBuilder
          FutureBuilder<List<Moodidi>>(
            future: _fetchMoodidis(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = snapshot.data!;
              if (list.isEmpty) {
                return const Center(child: Text('No Moodidis yet'));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: list.map((m) {
                  return Card(
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(m.keyword),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () async {
                          await DatabaseHelper.instance.deleteMoodidi(m.id!);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Orange "+" button
          Positioned(
            bottom: 80,
            left: MediaQuery.of(context).size.width * 0.3,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () async {
                final created = await showDialog(
                  context: context,
                  builder: (_) => const MoodidiCreationDialog(),
                );
                if (created == true) {
                  setState(() {}); // trigger refresh of FutureBuilder
                }
              },
              child: const Icon(Icons.add),
            ),
          ),

          // Yellow "−" button
          Positioned(
            bottom: 80,
            left: MediaQuery.of(context).size.width * 0.6,
            child: FloatingActionButton(
              backgroundColor: Colors.yellow,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Minus button pressed')),
                );
              },
              child: const Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }
}