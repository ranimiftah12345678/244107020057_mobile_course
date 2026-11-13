import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/local/note.dart';

class NoteTile extends ConsumerWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(note.updatedAt.toLocal());

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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        '${note.body.isEmpty ? '' : note.body.substring(0, note.body.length.clamp(0, 60))}  •  $dateStr',
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
