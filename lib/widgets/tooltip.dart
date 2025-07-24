import 'dart:io';
import 'package:flutter/material.dart';
import 'package:treering/models/mood_entry.dart';

/// Opens a fullscreen dialog to display an image from a file path.
void showFullscreenImage(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.file(File(imagePath), fit: BoxFit.contain),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

/// Builder function to render a mood entry tooltip.
Widget buildMoodTooltip(BuildContext context, MoodEntry entry) {
  return Container(
    width: 120,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 100, 96, 96),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(color: Color.fromARGB(66, 176, 168, 168), blurRadius: 4, offset: Offset(2, 2)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'mood: ${entry.rating}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        if (entry.description?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            entry.description!,
            style: const TextStyle(color: Colors.white, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (entry.photoPath?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => showFullscreenImage(context, entry.photoPath!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(entry.photoPath!),
                height: 60,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Builder function to render a cumulative average tooltip.
Widget buildAvgTooltip(BuildContext context, double value) {
  return Container(
    width: 140,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color:  Color.fromARGB(66, 176, 168, 168),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(color: Color.fromARGB(66, 176, 168, 168), blurRadius: 4, offset: Offset(2, 2)),
      ],
    ),
    child: Text(
      'cumulative avg: ${value.toStringAsFixed(2)}',
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}