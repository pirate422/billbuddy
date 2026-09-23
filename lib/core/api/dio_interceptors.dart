import 'package:dio/dio.dart';

/// Interceptor to attach headers and catch HTTP errors across the app
class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Set standard JSON headers for all outgoing requests
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // You can handle logging or token refreshes here
    super.onError(err, handler);
  }
}