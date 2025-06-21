import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/plot_page.dart';
import 'screens/record_page.dart';
import 'screens/monthly_report_page.dart';
import 'screens/moodidi_manager_page.dart';
import 'screens/moodidi_creation_page.dart';

void main() {
  runApp(const TreeRingApp());
}

class TreeRingApp extends StatelessWidget {
  const TreeRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TreeRing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E4C2F), // dark green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF2E4C2F), // background color for all screens
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E4C2F),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF2E4C2F), // text color
          ),
        ),
      ),
      home: const HomePage(),
      routes: {
        PlotPage.routeName: (_) => const PlotPage(),
        RecordPage.routeName: (_) => const RecordPage(),
        MonthlyReportPage.routeName: (_) => const MonthlyReportPage(),
        MoodidiManagerPage.routeName: (_) => const MoodidiManagerPage(),
        MoodidiCreationPage.routeName: (_) => const MoodidiCreationPage(),
      },
    );
  }
}