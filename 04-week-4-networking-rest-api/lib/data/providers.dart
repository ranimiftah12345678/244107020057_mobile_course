import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(postRepositoryProvider);
      final posts = await repository.fetchPosts();
      state = AsyncData(posts);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final postListProvider = AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  retry: (retryCount, error) => null,
);

Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final subscription = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) {
        return;
      }

      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
        return;
      }

      next.whenData((posts) {
        if (!completer.isCompleted) {
          completer.complete(posts);
        }
      });
    },
    fireImmediately: true,
  );

  return completer.future.whenComplete(subscription.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final subscription = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) {
        return;
      }

      if (next.hasError) {
        completer.complete(next.error);
      }
    },
    fireImmediately: true,
  );

  return completer.future.whenComplete(subscription.close);
}
