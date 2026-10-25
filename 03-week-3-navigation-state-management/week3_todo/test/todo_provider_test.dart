import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  test('hanya menampilkan tugas yang belum selesai', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(todoListProvider.notifier);
    notifier.add('Tugas selesai');
    notifier.add('Tugas aktif');
    notifier.toggle(0);

    final incompleteTodos = container.read(incompleteTodosProvider);

    expect(incompleteTodos, hasLength(1));
    expect(incompleteTodos.single.title, 'Tugas aktif');
  });
}
