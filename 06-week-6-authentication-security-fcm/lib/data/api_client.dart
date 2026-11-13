import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshToken = await store.readRefresh();
          if (refreshToken == null) return handler.next(e);
          try {
            final renewed = await auth.refresh(refreshToken);
            await store.save(access: renewed, refresh: refreshToken);
            final retryOptions = e.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $renewed';
            final retry = await dio.fetch(retryOptions);
            return handler.resolve(retry);
          } catch (_) {
            await store.clear();
          }
        }
        handler.next(e);
      },
    ),
  );
  return dio;
}
