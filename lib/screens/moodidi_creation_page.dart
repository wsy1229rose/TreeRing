import 'package:flutter/material.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/moodidi.dart';

class MoodidiCreationPage extends StatefulWidget {
  static const routeName = '/moodidiCreate';
  const MoodidiCreationPage({super.key});
  @override
  State<MoodidiCreationPage> createState() => _MoodidiCreationPageState();
}

class _MoodidiCreationPageState extends State<MoodidiCreationPage> {
  int _step = 1;
  final _kwCtrl = TextEditingController();
  String _type = 'yesno';
  final _promptCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is String) _kwCtrl.text = arg;
  }

  Future _finish() async {
    final m = Moodidi(
      keyword: _kwCtrl.text.trim(),
      type: _type,
      prompt: _promptCtrl.text.trim(),
    );
    await DatabaseHelper.instance.insertMoodidi(m);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Moodidi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _step == 1
            ? Column(
                children: [
                  TextField(
                    controller: _kwCtrl,
                    decoration:
                        const InputDecoration(labelText: 'What might influence your mood… Key word'),
                  ),
                  RadioListTile(
                    title: const Text('yes/no question'),
                    value: 'yesno',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  RadioListTile(
                    title: const Text('fill in the blank'),
                    value: 'fill',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _kwCtrl.text.trim().isEmpty
                        ? null
                        : () => setState(() => _step = 2),
                    child: const Text('Next'),
                  ),
                ],
              )
            : Column(
                children: [
                  TextField(
                    controller: _promptCtrl,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'How would you want to be prompted…'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _promptCtrl.text.trim().isEmpty
                        ? null
                        : _finish,
                    child: const Text('Finish'),
                  ),
                ],
              ),
      ),
    );
  }
}
