import 'package:dio/dio.dart';
import 'dio_interceptors.dart';

/// Centralized Dio HTTP Client for BillBuddy
class ApiClient {
  final Dio dio;

  ApiClient({String baseUrl = 'https://api.billbuddy.com/v1'})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(AppInterceptors());
  }
}