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
        title: const Center(child: Text('What is a Moodidi?'),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text:
                    '          You could use this feature to study whether something (a factor) can positively / negatively / not influence your mood by looking at its correlation with your happiness. If you don’t know what might influence your mood, here is where you can ',
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Have you ever wondered how the following factors might influence your mood …?', style: TextStyle(fontSize: 16),),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          for (var kw in ['Weather', 'Sleeping time', 'Physical Activeness', ])
            ListTile(
              title: Text(kw),
              trailing: TextButton(
                onPressed: () {
                  Navigator.pop(_);   // close the inspiration dialog first
                  showDialog(
                    context: context,
                    builder: (_) => MoodidiCreationDialog(initialKeyword: kw),
                  ).then((_) => _refresh());
                },

       //         final created = await showDialog(
       //           context: context,
       //           builder: (_) => MoodidiCreationDialog(initialKeyword: kw),
       //         );
       //         if (created == true) {
       //           _refresh(); //Refresh only if new Moodidi was created
       //         }
       //       },

                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 4),
                    Text('set up'),
                  ],
                ),
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
          // Main content: list of Moodidis
          ListView(
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

          // Orange "+" button (left of center)
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
    		  _refresh();             // Refresh only if new Moodidi was created
  		}
              },
              child: const Icon(Icons.add),
            ),
          ),

          // Yellow "−" button (right of center)
          Positioned(
            bottom: 80,
            left: MediaQuery.of(context).size.width * 0.6,
            child: FloatingActionButton(
              backgroundColor: Colors.yellow,
              onPressed: () {
                // Temporary placeholder action
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
