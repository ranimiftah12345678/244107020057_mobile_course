import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/post_list_page.dart';

// ---------------------------------------------------------------------------
// Fake repository (tanpa HTTP sungguhan)
// ---------------------------------------------------------------------------

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    return fetchPosts();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // --- Unit test: Post.fromJson ---
  group('Post.fromJson', () {
    test('semua field hadir', () {
      final post = Post.fromJson({
        'userId': 1,
        'id': 2,
        'title': 'Judul',
        'body': 'Isi',
      });
      expect(post.userId, 1);
      expect(post.id, 2);
      expect(post.title, 'Judul');
      expect(post.body, 'Isi');
    });

    test('semua field null → nilai default', () {
      final post = Post.fromJson(
          {'userId': null, 'id': null, 'title': null, 'body': null});
      expect(post.userId, 0);
      expect(post.id, 0);
      expect(post.title, '');
      expect(post.body, '');
    });

    test('field hilang sepenuhnya → nilai default', () {
      final post = Post.fromJson({'id': 7});
      expect(post.id, 7);
      expect(post.title, '');
      expect(post.userId, 0);
    });
  });

  // --- Unit test: Comment.fromJson ---
  group('Comment.fromJson', () {
    test('semua field hadir', () {
      final c = Comment.fromJson({
        'postId': 1,
        'id': 5,
        'name': 'Nama',
        'email': 'a@b.com',
        'body': 'Isi',
      });
      expect(c.postId, 1);
      expect(c.id, 5);
      expect(c.name, 'Nama');
      expect(c.email, 'a@b.com');
    });

    test('field hilang → nilai default', () {
      final c = Comment.fromJson({'id': 3});
      expect(c.id, 3);
      expect(c.postId, 0);
      expect(c.name, '');
      expect(c.email, '');
      expect(c.body, '');
    });

    test('field null → nilai default', () {
      final c = Comment.fromJson({
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      });
      expect(c.postId, 0);
      expect(c.id, 0);
      expect(c.name, '');
    });
  });

  // --- Unit test: friendlyErrorMessage ---
  group('friendlyErrorMessage', () {
    test('connectionTimeout → pesan timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(friendlyErrorMessage(err), contains('timeout'));
    });

    test('connectionError → pesan terhubung', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyErrorMessage(err), contains('terhubung'));
    });

    test('badResponse 404 → pesan tidak ditemukan', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts'),
          statusCode: 404,
        ),
      );
      expect(friendlyErrorMessage(err), contains('404'));
    });

    test('badResponse 500 → pesan server bermasalah', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts'),
          statusCode: 500,
        ),
      );
      expect(friendlyErrorMessage(err), contains('500'));
    });

    test('error non-Dio → pesan tak terduga', () {
      expect(
        friendlyErrorMessage(Exception('ups')),
        contains('tak terduga'),
      );
    });
  });

  // --- Unit test: postListProvider dengan fake repository ---
  group('postListProvider', () {
    test('sukses → mengembalikan list post', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(
              items: [const Post(userId: 1, id: 1, title: 'Tes', body: 'Isi')],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final posts = await readPostsOnce(container);
      expect(posts.length, 1);
      expect(posts.first.title, 'Tes');
    });

    test('error → AsyncError berisi DioException', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);
      final err = await readPostsErrorOnce(container);
      expect(err, isA<DioException>());
      expect(friendlyErrorMessage(err!), contains('terhubung'));
    });
  });

  // --- Widget test: PostListPage ---
  group('PostListPage widget', () {
    testWidgets('menampilkan data post dari repository', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postRepositoryProvider.overrideWithValue(
              FakePostRepository(items: [
                const Post(
                    userId: 1, id: 1, title: 'Judul contoh', body: 'Isi contoh'),
              ]),
            ),
          ],
          child: const MaterialApp(home: PostListPage()),
        ),
      );
      await tester.pump();
      expect(find.text('Judul contoh'), findsOneWidget);
      expect(find.text('Isi contoh'), findsOneWidget);
    });

    testWidgets('menampilkan pesan error ketika repository gagal',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postRepositoryProvider.overrideWithValue(
              FakePostRepository(throwError: true),
            ),
          ],
          child: const MaterialApp(home: PostListPage()),
        ),
      );
      await tester.pump();
      expect(find.text('Coba lagi'), findsOneWidget);
    });
  });
}
