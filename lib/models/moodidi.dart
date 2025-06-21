class Moodidi {
  final int? id;
  final String keyword;
  final String type; // 'yesno' or 'fill'
  final String prompt;
  final DateTime createdAt;

  Moodidi({
    this.id,
    required this.keyword,
    required this.type,
    required this.prompt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'keyword': keyword,
        'type': type,
        'prompt': prompt,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Moodidi.fromMap(Map<String, dynamic> m) {
    return Moodidi(
      id: m['id'] as int?,
      keyword: m['keyword'] as String,
      type: m['type'] as String,
      prompt: m['prompt'] as String,
      createdAt: DateTime.parse(m['createdAt'] as String),
    );
  }
}
