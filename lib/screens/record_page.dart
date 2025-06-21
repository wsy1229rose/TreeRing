import 'package:flutter/material.dart';
import 'package:treering/screens/monthly_report_page.dart';

class RecordPage extends StatelessWidget {
  static const routeName = '/record';
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final months = ['May', 'June', 'July', 'August'];
    return Scaffold(
      appBar: AppBar(title: const Text('Record')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: months.map((m) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.primaries[months.indexOf(m)],
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    MonthlyReportPage.routeName,
                    arguments: m,
                  );
                },
                child: Text(m, style: const TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
