import 'package:flutter/material.dart';
import 'package:treering/screens/home_page.dart';
import 'package:treering/screens/plot_page.dart';
import 'header_bar.dart';

class ScaffoldWithNav extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const ScaffoldWithNav({
    super.key,
    required this.body,
    required this.currentIndex,
  });

void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, HomePage.routeName, (r) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, PlotPage.routeName, (r) => false);
        break;
    } 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderBar(),
          Expanded(child: body),      // <-- the page’s own content
        ],
      ),
      bottomNavigationBar:
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Plot'),
          ],
        )
    );
  }
}
