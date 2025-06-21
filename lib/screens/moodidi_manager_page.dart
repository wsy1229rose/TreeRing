import 'package:flutter/material.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/screens/moodidi_creation_page.dart';

class MoodidiManagerPage extends StatefulWidget {
  static const routeName = '/moodidiManager';
  const MoodidiManagerPage({super.key});
  @override
  State<MoodidiManagerPage> createState() => _MoodidiManagerPageState();
}

class _MoodidiManagerPageState extends State<MoodidiManagerPage> {
  List<Moodidi> _list = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future _refresh() async {
    final l = await DatabaseHelper.instance.getMoodidiList();
    setState(() => _list = l);
  }

  void _showWhatIs() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('What is a Moodidi?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'You could use this feature to study whether something …'),
          GestureDetector(
            onTap: () {
              Navigator.pop(_);
              _showInspiration();
            },
            child: const Text('suggestions',
                style: TextStyle(color: Colors.blue)),
          ),
        ]),
      ),
    );
  }

  void _showInspiration() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Have you ever wondered how…'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          for (var kw in ['Weather', 'Sleeping time', 'Active'])
            ListTile(
              title: Text(kw),
              trailing: TextButton(
                onPressed: () {
                  Navigator.pop(_);
                  Navigator.pushNamed(
                    context,
                    MoodidiCreationPage.routeName,
                    arguments: kw,
                  ).then((_) => _refresh());
                },
                child: const Text('set up'),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moodidi'),
        actions: [
          IconButton(onPressed: _showWhatIs, icon: const Icon(Icons.help)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _list.map((m) {
          return Card(
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(m.keyword),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteMoodidi(m.id!);
                  _refresh();
                },
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, MoodidiCreationPage.routeName)
              .then((_) => _refresh());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
