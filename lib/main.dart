import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/factor_page.dart';
import 'screens/plot_page.dart';
import 'screens/report_page.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    FactorPage(),
    PlotPage(),
    ReportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Factors'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Plot'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Report'),
        ],
      ),
    );
  }
} 