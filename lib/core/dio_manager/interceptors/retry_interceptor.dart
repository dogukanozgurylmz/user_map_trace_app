import 'dart:developer';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Önceki retry sayısını kontrol et
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      // Retry sayısını artır
      err.requestOptions.extra['retry_count'] = retryCount + 1;

      log(
        '🔄 Retry attempt ${retryCount + 1}/$maxRetries for ${err.requestOptions.uri}',
      );

      await Future.delayed(retryDelay);

      try {
        final response = await dio.fetch(err.requestOptions);
        log('✅ Retry successful after ${retryCount + 1} attempts');
        return handler.resolve(response);
      } catch (e) {
        log('❌ Retry ${retryCount + 1} failed: $e');
        // Eğer bu son deneme ise veya yeni hata retry edilemezse, hatayı ilet
        if (e is DioException &&
            (retryCount + 1 >= maxRetries || !_shouldRetry(e))) {
          return handler.next(e);
        }
        // Aksi halde recursive olarak tekrar dene
        return onError(e as DioException, handler);
      }
    }

    if (retryCount > 0) {
      log(
        '⛔ Max retry attempts ($maxRetries) reached for ${err.requestOptions.uri}',
      );
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Connection hatalarında retry yap
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // 500 ve üzeri server hatalarında retry yap (ama sadece 3 kez)
    if (err.response != null && err.response!.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      // 500, 502, 503, 504 gibi geçici server hatalarında retry yap
      return statusCode >= 500 && statusCode < 600;
    }

    return false;
  }
}
