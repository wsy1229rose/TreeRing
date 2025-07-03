import 'package:flutter/material.dart';

/// A reusable header bar for TreeRing screens.
class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  static const Color backgrounColor = Color(0xFFA0CFA0);

  /// Match the green‐tone from your mockup
  static const Color backgroundColor = Color(0xFFA0CFA0);

  const HeaderBar({super.key, this.title = 'TreeRing'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
