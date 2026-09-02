import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import '../storage/secure_storage.dart';

/// TABIBI (طبيبي) - Ultra-Resilient ApiClient with Auto-Failover
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final SecureStorage _storage = SecureStorage();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.javaBaseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // إضافة التوكن والتبديل التلقائي عند انقطاع السيرفر
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // إذا فشل الاتصال بسيرفر Java، نحول تلقائياً إلى سيرفر PHP
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown) {
            
            if (e.requestOptions.baseUrl == ApiEndpoints.javaBaseUrl) {
              final newOptions = e.requestOptions;
              newOptions.baseUrl = ApiEndpoints.phpBaseUrl;
              ApiEndpoints.baseUrl = ApiEndpoints.phpBaseUrl;

              try {
                final response = await _dio.fetch(newOptions);
                return handler.resolve(response);
              } catch (err) {
                return handler.next(e);
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
