import 'dart:convert';

class MoodEntry {
  final int? id;
  final DateTime timestamp;
  final String date; // yyyy-MM-dd
  final int rating;
  final String? description;
  final String? photoPath;
  final Map<String, dynamic>? responses; // moodidi responses

  MoodEntry({
    this.id,
    required this.date,
    required this.rating,
    this.description,
    this.photoPath,
    this.responses,
  }) : timestamp = DateTime.parse(date);

  factory MoodEntry.fromMap(Map<String, dynamic> m) {
    return MoodEntry(
      id: m['id'] as int,
      date: m['date'] as String,
      rating: m['rating'] as int,
      description: m['description'] as String?,
      photoPath: m['photoPath'] as String?,
      responses: m['responses'] == null
          ? null
          : Map<String, dynamic>.from(jsonDecode(m['responses'] as String)),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'date': date,
      'rating': rating,
      'description': description,
      'photoPath': photoPath,
      'responses': responses == null ? null : jsonEncode(responses),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // For charts: timestamp in milliseconds as a double.
  double get timestampMillis => timestamp.millisecondsSinceEpoch.toDouble();
}

