class Note {
  final int? id;
  final String title;
  final String body;
  final bool dirty;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.body,
    this.dirty = true,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      dirty: ((map['dirty'] as int?) ?? 1) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'dirty': dirty ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? body,
    bool? dirty,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      dirty: dirty ?? this.dirty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Note(id:$id, title:"$title", dirty:$dirty)';
}
