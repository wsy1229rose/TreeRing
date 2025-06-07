import 'package:flutter/material.dart';

class FactorPage extends StatefulWidget {
  const FactorPage({super.key});

  @override
  State<FactorPage> createState() => _FactorPageState();
}

class _FactorPageState extends State<FactorPage> {
  final _controller = TextEditingController();
  List<String> _factors = [
    'Physically Active',
    'Screen Time > 1h',
    'At Home',
  ];

  void _addFactor() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _factors.add(_controller.text.trim());
        _controller.clear();
      });
    }
  }

  void _removeFactor(int index) {
    setState(() {
      _factors.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customize Factors')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add new factor',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addFactor,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _factors.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_factors[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeFactor(index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 