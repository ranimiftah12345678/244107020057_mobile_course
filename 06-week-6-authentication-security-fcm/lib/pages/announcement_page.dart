import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(announcementDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengumuman #$id'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (announcement) {
          if (announcement == null) {
            return const Center(child: Text('Pengumuman tidak ditemukan'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Badge deep link dari FCM
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 14,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Deep link: /pengumuman/$id',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                announcement.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                announcement.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Catatan FCM:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const _FcmStateTable(),
            ],
          );
        },
      ),
    );
  }
}

class _FcmStateTable extends StatelessWidget {
  const _FcmStateTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Foreground', 'onMessage → local notification manual'),
      ('Background', 'Banner sistem → onMessageOpenedApp'),
      ('Terminated', 'getInitialMessage() saat startup'),
    ];
    return Table(
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('State', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Handler', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        for (final row in rows)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(row.$1),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(row.$2, style: const TextStyle(fontSize: 12)),
            ),
          ]),
      ],
    );
  }
}
