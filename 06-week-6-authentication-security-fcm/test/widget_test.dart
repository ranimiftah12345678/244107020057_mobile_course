import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/data/announcement.dart';

void main() {
  test('Announcement.fromJson semua field hadir', () {
    final a = Announcement.fromJson({
      'id': 1,
      'title': 'Test',
      'body': 'Isi test',
    });
    expect(a.id, '1');
    expect(a.title, 'Test');
    expect(a.body, 'Isi test');
  });

  test('Announcement.fromJson field null → default kosong', () {
    final a = Announcement.fromJson({'id': null, 'title': null, 'body': null});
    expect(a.id, '');
    expect(a.title, '');
    expect(a.body, '');
  });
}
