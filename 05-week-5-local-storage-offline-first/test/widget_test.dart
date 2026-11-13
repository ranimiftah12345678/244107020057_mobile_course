import 'package:flutter_test/flutter_test.dart';
import 'package:week5_local/data/local/note.dart';

void main() {
  test('Note dirty flag default adalah true', () {
    final note = Note(title: 'Test', body: 'Body');
    expect(note.dirty, true);
  });

  test('Note copyWith mengubah field yang diminta', () {
    final note = Note(id: 1, title: 'A', body: 'B');
    final copy = note.copyWith(title: 'C', dirty: false);
    expect(copy.title, 'C');
    expect(copy.dirty, false);
    expect(copy.id, 1);
    expect(copy.body, 'B');
  });
}
