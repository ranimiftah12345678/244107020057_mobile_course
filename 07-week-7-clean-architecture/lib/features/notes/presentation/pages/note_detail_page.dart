import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers.dart';
import '../../domain/entities/note.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});
  final int noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  Note? _note;
  bool _loading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(noteRepositoryProvider);
    // Ambil langsung dari repository untuk detail view
    final result = await repo.fetchNotes();
    if (!mounted) return;
    final note = result.notes.where((n) => n.id == widget.noteId).firstOrNull;
    setState(() {
      _note = note;
      _titleCtrl.text = note?.title ?? '';
      _bodyCtrl.text = note?.body ?? '';
      _loading = false;
    });
    _titleCtrl.addListener(() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    });
    _bodyCtrl.addListener(() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    });
  }

  Future<void> _save() async {
    if (_note == null) return;
    final updated = _note!.copyWith(
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      dirty: true,
      updatedAt: DateTime.now(),
    );
    final repo = ref.read(noteRepositoryProvider);
    await repo.updateNote(updated);
    ref.invalidate(noteListProvider);
    if (!mounted) return;
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Catatan disimpan')));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Catatan')),
        body: const Center(child: Text('Catatan tidak ditemukan')),
      );
    }
    final dateStr =
        DateFormat('dd MMM yyyy, HH:mm').format(_note!.updatedAt.toLocal());
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan #${widget.noteId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _save,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              labelText: 'Judul',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(
              labelText: 'Isi catatan',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 10,
            minLines: 4,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14),
              const SizedBox(width: 4),
              Text('Diperbarui: $dateStr',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 10),
              if (_note!.dirty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'belum sync',
                    style:
                        TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: _hasChanges
          ? FloatingActionButton.extended(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            )
          : null,
    );
  }
}
