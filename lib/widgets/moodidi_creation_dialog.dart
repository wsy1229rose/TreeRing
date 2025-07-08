import 'package:flutter/material.dart';
import 'package:treering/db/database_helper.dart';
import 'package:treering/models/moodidi.dart';

class MoodidiCreationDialog extends StatefulWidget {
  final String? initialKeyword;
  const MoodidiCreationDialog({super.key, this.initialKeyword});

  @override
  State<MoodidiCreationDialog> createState() => _MoodidiCreationDialogState();
}

class _MoodidiCreationDialogState extends State<MoodidiCreationDialog> {
  int _step = 1;
  final _kwCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();
  String _type = 'yesno';

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null) {
      _kwCtrl.text = widget.initialKeyword!;
    }
  }

  Future<void> _finish() async {
    final m = Moodidi(
      keyword: _kwCtrl.text.trim(),
      type: _type,
      prompt: _promptCtrl.text.trim(),
    );
    await DatabaseHelper.instance.insertMoodidi(m);
    if (mounted) Navigator.of(context).pop(); // close dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a Moodidi'),
      content: SizedBox(
        width: 300,
        child: _step == 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _kwCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Key word'),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _kwCtrl.text.trim().isEmpty
                        ? null
                        : () => setState(() => _step = 2),
                    child: const Text('Next'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _promptCtrl,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'How would you want to be prompted…',
                    ),
                  ),
                  const SizedBox(height: 20),
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
