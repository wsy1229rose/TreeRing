import 'dart:convert';

class MoodEntry {
  final String date; // yyyy-MM-dd
  final int rating;
  final String? description;
  final String? photoPath;
  final Map<String, dynamic>? responses; // moodidi responses

  MoodEntry({
    required this.date,
    required this.rating,
    this.description,
    this.photoPath,
    this.responses,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'rating': rating,
        'description': description,
        'photoPath': photoPath,
        'responses': responses == null ? null : jsonEncode(responses),
      };

  factory MoodEntry.fromMap(Map<String, dynamic> m) {
    return MoodEntry(
      date: m['date'] as String,
      rating: m['rating'] as int,
      description: m['description'] as String?,
      photoPath: m['photoPath'] as String?,
      responses: m['responses'] == null
          ? null
          : Map<String, dynamic>.from(jsonDecode(m['responses'] as String)),
    );
  }
}