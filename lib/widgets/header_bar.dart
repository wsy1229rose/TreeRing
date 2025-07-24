import 'package:flutter/material.dart';

/// A reusable header bar for TreeRing screens.
class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  static const Color backgrounColor = Color(0xFFA0CFA0);

  /// Match the green‐tone from your mockup
//static const Color backgroundColor = Color(0xFFA0CFA0);

  const HeaderBar({super.key, this.title = 'TreeRing'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      color: Colors.white,
      alignment: const Alignment(0, 0.5), // x: 0 (centered horizontally), y: 0.5 (slightly lower)
      child: Text(
        title,
        style: const TextStyle(
       // color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
