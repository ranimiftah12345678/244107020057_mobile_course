import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/todo_provider.dart';

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({required this.index, super.key});

  final int? index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final todoIndex = index;
    final isValidIndex =
        todoIndex != null && todoIndex >= 0 && todoIndex < todos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: isValidIndex
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todos[todoIndex].title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    todos[todoIndex].done ? 'Selesai' : 'Belum selesai',
                  ),
                ],
              ),
            )
          : const Center(child: Text('Tugas tidak ditemukan')),
    );
  }
}
