import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

/// TABIBI (طبيبي) - Dual-Server Resilient HTTP Client
class ApiClient {
  late final Dio _dio;
  late final Dio _backupDio;
  final SecureStorage _storage = SecureStorage();

  ApiClient() {
    // إعداد السيرفر الأساسي (Java Ngrok)
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'ngrok-skip-browser-warning': 'true', // لتخطي صفحة تحذير ngrok تلقائياً
        },
      ),
    );

    // إعداد السيرفر الاحتياطي (PHP Web)
    _backupDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    _setupInterceptors(_dio);
    _setupInterceptors(_backupDio);
  }

  void _setupInterceptors(Dio client) {
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// طلب GET مع ميزة التحويل التلقائي للسيرفر الاحتياطي
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (primaryError) {
      if (_shouldFallback(primaryError)) {
        try {
          return await _backupDio.get(path, queryParameters: queryParameters);
        } on DioException catch (backupError) {
          throw _handleDioError(backupError);
        }
      }
      throw _handleDioError(primaryError);
    }
  }

  /// طلب POST مع ميزة التحويل التلقائي للسيرفر الاحتياطي
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (primaryError) {
      if (_shouldFallback(primaryError)) {
        try {
          return await _backupDio.post(path, data: data, queryParameters: queryParameters);
        } on DioException catch (backupError) {
          throw _handleDioError(backupError);
        }
      }
      throw _handleDioError(primaryError);
    }
  }

  bool _shouldFallback(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        (error.response?.statusCode != null && error.response!.statusCode! >= 500);
  }

  String _handleDioError(DioException error) {
    if (error.response?.data != null && error.response?.data is Map) {
      final message = error.response?.data['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال، يرجى التحقق من سرعة الإنترنت.';
      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالسيرفر، يرجى التأكد من تشغيل الإنترنت في هاتفك.';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401) return 'جلسة الدخول غير صالحة، يرجى تسجيل الدخول.';
        if (status == 403) return 'ليس لديك الصلاحية الكافية للوصول لهذا القسم.';
        if (status == 404) return 'الخدمة المطلوبة غير متوفرة حالياً.';
        return 'حدث خطأ أثناء معالجة الطلب (كود: $status).';
      default:
        return 'حدث خطأ غير متوقع أثناء الاتصال بالشبكة.';
    }
  }
}
