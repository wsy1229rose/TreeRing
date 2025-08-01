import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/plot_page.dart';
import 'screens/record_page.dart';
import 'screens/monthly_report_page.dart';
import 'screens/moodidi_manager_page.dart';
import 'widgets/start_page.dart';

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
          seedColor: const Color(0xFF004D40), // dark green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF004D40), // background color for all screens
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004D40),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF004D40), // text color
          ),
        ),
      ),
      initialRoute: '/start',
      routes: {
        '/start': (context) => const StartPage(),
        '/': (context) => const HomePage(initialMood: 0),
        PlotPage.routeName: (_) => const PlotPage(),
        RecordPage.routeName: (_) => const RecordPage(),
        MonthlyReportPage.routeName: (_) => const MonthlyReportPage(),
        MoodidiManagerPage.routeName: (_) => const MoodidiManagerPage(),
      },
    );
  }
}