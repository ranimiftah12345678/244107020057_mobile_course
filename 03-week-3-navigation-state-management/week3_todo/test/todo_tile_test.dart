import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_provider.dart';
import 'package:week3_todo/widgets/todo_tile.dart';

void main() {
  testWidgets('menampilkan tugas dan memanggil callback interaksi',
      (tester) async {
    var toggleCalled = false;
    var deleteCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoTile(
            todo: Todo('Belajar Flutter'),
            onToggle: () => toggleCalled = true,
            onDelete: () => deleteCalled = true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Belajar Flutter'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byIcon(Icons.delete));

    expect(toggleCalled, isTrue);
    expect(deleteCalled, isTrue);
  });
}
