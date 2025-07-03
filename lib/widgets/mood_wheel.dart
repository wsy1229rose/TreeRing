import 'package:flutter/material.dart';

typedef MoodChanged = void Function(int);

class MoodWheel extends StatefulWidget {
  final int value;
  final MoodChanged onChanged;
  final bool interacted;
  final VoidCallback onInteracted;
  const MoodWheel({super.key, required this.value, required this.onChanged, required this.interacted, required this.onInteracted});

  @override
  State<MoodWheel> createState() => _MoodWheelState();
}

class _MoodWheelState extends State<MoodWheel> {
  late FixedExtentScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: -widget.value + 10000);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: ListWheelScrollView.useDelegate(
        controller: _ctrl,
        itemExtent: 75,
        onSelectedItemChanged: (i) {
          if (!widget.interacted) {
            widget.onInteracted();
          }
          widget.onChanged(-(i - 10000));
        },
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, idx) {
            if (idx < 0 || idx > 20000) return null;
            final val = -(idx - 10000);
            return Center(
              child: Text(
                '$val',
                style: TextStyle(
                  fontSize: val == widget.value ? 56 : 36,
                  color: val == widget.value ? Colors.white : Colors.grey[400],
                ),
              ),
            );
          },
          childCount: 20001,  // -10,000 to 10,000
        ),
      ),
    );
  }
}