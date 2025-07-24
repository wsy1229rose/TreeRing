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
  final _kwCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();
  String _type = 'yesno';
  bool _showPromptField = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null) {
      _kwCtrl.text = widget.initialKeyword!;
    }

    _promptCtrl.addListener(() => setState(() {})); // Refresh for Finish button
  }

  Future<void> _finish() async {
    final m = Moodidi(
      keyword: _kwCtrl.text.trim(),
      type: _type,
      prompt: _promptCtrl.text.trim(),
    );
    try {
      //print('Inserting Moodidi: ${m.toMap()}');
      await DatabaseHelper.instance.insertMoodidi(m);
      print('Insert successful.');
      if (mounted) Navigator.of(context, rootNavigator: true).pop(true);
    } catch (e, stack) {
      print('creation_dialog:41: Insert failed: $e');
      print(stack);
      // Optionally show error UI:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insert failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _kwCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a Moodidi'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _kwCtrl,
              decoration: const InputDecoration(labelText: 'Key word'),
            ),
            const SizedBox(height: 26),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose the type of your moodidi:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            RadioListTile(
              title: const Text('Yes/No question'),
              value: 'yesno',
              groupValue: _type,
              onChanged: (v) => setState(() => _type = v!),
            ),
            RadioListTile(
              title: const Text('numerical'),
              value: 'numerical',
              groupValue: _type,
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 26),

            // Show either the Next button or the prompt input + Finish button
            if (!_showPromptField)
              ElevatedButton(
                onPressed: _kwCtrl.text.trim().isEmpty
                    ? null
                    : () => setState(() => _showPromptField = true),
                child: const Text('Next'),
              )
            else ...[
              TextField(
                controller: _promptCtrl,
                maxLines: null, 
                decoration: const InputDecoration(
                  labelText: 'Prompt line',
                  hintText: 'How would you want to be prompted…',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _promptCtrl.text.trim().isEmpty ? null : _finish,
                child: const Text('Finish'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}