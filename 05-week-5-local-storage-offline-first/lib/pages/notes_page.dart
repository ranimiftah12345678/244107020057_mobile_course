import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteListProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        actions: [
          // Badge jumlah catatan belum sync
          dirtyAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Badge(
                      label: Text('$count'),
                      child: IconButton(
                        icon: const Icon(Icons.cloud_upload_outlined),
                        tooltip: 'Sync catatan',
                        onPressed: syncState.isLoading
                            ? null
                            : () => ref.read(syncProvider.notifier).sync(),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.cloud_done_outlined),
                    tooltip: 'Semua tersync',
                    onPressed: null,
                  ),
            loading: () => const SizedBox(
              width: 48,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, st) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(noteListProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada catatan.\nTap + untuk menambah.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(noteListProvider.notifier).build(),
            child: ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteTile(
                  note: note,
                  onTap: () => context.go('/note/${note.id}'),
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus catatan?'),
                        content: Text(
                            '"${note.title.isEmpty ? '(tanpa judul)' : note.title}" akan dihapus permanen.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && note.id != null) {
                      await ref
                          .read(noteListProvider.notifier)
                          .delete(note.id!);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catatan Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Isi'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              final body = bodyCtrl.text.trim();
              Navigator.pop(ctx);
              await ref.read(noteListProvider.notifier).add(title, body);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
