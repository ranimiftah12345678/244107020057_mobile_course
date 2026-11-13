import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers.dart';
import '../../domain/entities/note.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteListProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Notes'),
        actions: [
          dirtyAsync.when(
            data: (count) => count > 0
                ? Badge(
                    label: Text('$count'),
                    child: IconButton(
                      icon: const Icon(Icons.cloud_upload_outlined),
                      tooltip: 'Sync catatan',
                      onPressed: syncState.isLoading
                          ? null
                          : () => ref.read(syncProvider.notifier).sync(),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.cloud_done_outlined),
                    tooltip: 'Semua tersync',
                    onPressed: null,
                  ),
            loading: () => const SizedBox(
              width: 48,
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
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
          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];
              return _NoteTile(
                note: note,
                onTap: () => context.go('/note/${note.id}'),
                onDelete: () => _confirmDelete(context, ref, note),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text(
            '"${note.title.isEmpty ? '(tanpa judul)' : note.title}" akan dihapus.'),
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
    if (confirmed == true && note.id != null) {
      await ref.read(noteListProvider.notifier).delete(note.id!);
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
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
              maxLines: 3,
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

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy, HH:mm').format(note.updatedAt.toLocal());
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              note.title.isEmpty ? '(tanpa judul)' : note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (note.dirty)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'belum sync',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
        ],
      ),
      subtitle: Text(
        dateStr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
