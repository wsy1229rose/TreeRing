class MoodEntry {
  final int? id;
  final DateTime date;
  final int rating;
  final Map<String, bool> factors;

  MoodEntry({this.id, required this.date, required this.rating, required this.factors});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'rating': rating,
      'factors': factors.toString(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      rating: map['rating'],
      factors: Map.fromEntries(
        (map['factors'] as String)
            .replaceAll('{', '')
            .replaceAll('}', '')
            .split(', ')
            .where((e) => e.contains(':'))
            .map((e) => MapEntry(
                  e.split(':')[0],
                  e.split(':')[1] == 'true',
                )),
      ),
    );
  }
} 