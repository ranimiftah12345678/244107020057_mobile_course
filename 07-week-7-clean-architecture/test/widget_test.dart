import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean/features/notes/domain/entities/note.dart';

void main() {
  test('Note dirty default adalah false', () {
    final note = Note(title: 'Test', updatedAt: DateTime(2026));
    expect(note.dirty, false);
  });

  test('Note copyWith mengubah field yang diminta', () {
    final note = Note(id: 1, title: 'A', updatedAt: DateTime(2026));
    final copy = note.copyWith(title: 'B', dirty: true);
    expect(copy.title, 'B');
    expect(copy.dirty, true);
    expect(copy.id, 1);
  });
}
