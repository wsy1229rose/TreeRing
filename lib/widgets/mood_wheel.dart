import 'package:flutter/material.dart';

class MoodWheel extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const MoodWheel({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        diameterRatio: 1.2,
        perspective: 0.003,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            int moodValue = index - 10;
            return Center(
              child: Text(
                moodValue.toString(),
                style: TextStyle(
                  fontSize: 32,
                  color: moodValue == value ? Colors.green : Colors.grey,
                  fontWeight: moodValue == value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
          childCount: 21, // -10 to 10
        ),
      ),
    );
  }
} 