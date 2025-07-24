class MoodidiEntry {
  final String keyword;
  final double entry;
  final DateTime createdAt;

  MoodidiEntry({
    required this.keyword,
    required this.entry,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'keyword': keyword,
        'entry': entry,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MoodidiEntry.fromMap(Map<String, dynamic> m) {
    //print('[MoodidiEntry] map: $map');
    return MoodidiEntry(
      keyword: m['keyword'] as String,
      entry: (m['entry'] as num).toDouble(),
      createdAt: DateTime.parse(m['createdAt'] as String),
    );
  }
}
