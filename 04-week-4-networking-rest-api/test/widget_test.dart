import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/post_list_page.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository() : super(Dio());

  @override
  Future<List<Post>> fetchPosts() async {
    return const [
      Post(
        userId: 1,
        id: 1,
        title: 'Judul contoh',
        body: 'Isi contoh dari API',
      ),
    ];
  }
}

void main() {
  testWidgets('App shows posts page with mock data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
        child: const MaterialApp(home: PostListPage()),
      ),
    );

    await tester.pump();

    expect(find.text('Posts API'), findsOneWidget);
    expect(find.text('Judul contoh'), findsOneWidget);
    expect(find.text('Isi contoh dari API'), findsOneWidget);
  });

  test('friendlyErrorMessage untuk berbagai tipe error', () {
    final timeout = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionTimeout,
    );
    expect(friendlyErrorMessage(timeout), contains('timeout'));

    final connErr = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionError,
    );
    expect(friendlyErrorMessage(connErr), contains('terhubung'));
  });
}
