import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/comment_providers.dart';
import '../data/models/post.dart';
import '../data/network_errors.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentListProvider(post.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Post #${post.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(post.body),
          const Divider(height: 32),
          Text(
            'Komentar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          commentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    friendlyErrorMessage(err),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(commentListProvider(post.id)),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return const Text('Belum ada komentar.');
              }
              return Column(
                children: comments
                    .map(
                      (c) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                c.email,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(c.body),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
