import 'package:flutter/material.dart';
import 'package:treering/screens/monthly_report_page.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';

class RecordPage extends StatelessWidget {
  static const routeName = '/record';
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final months = ['May', 'June', 'July', 'August'];
    final monthColors = [
      Colors.pink[200],
      Colors.orange[200],
      Colors.lightGreen[200],
      Colors.lightBlue[200],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My Record',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double spacing = 12;
            final double itemSize = (constraints.maxWidth - 2 * spacing) / 3;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Year block
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: itemSize,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      onPressed: () {
                        // You can define a yearly report route if needed
                      },
                      child: const Text(
                        '2024',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                // Month blocks in a grid
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(months.length, (index) {
                    return SizedBox(
                      width: itemSize,
                      height: itemSize,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: monthColors[index],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            MonthlyReportPage.routeName,
                            arguments: months[index],
                          );
                        },
                        child: Text(
                          months[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
