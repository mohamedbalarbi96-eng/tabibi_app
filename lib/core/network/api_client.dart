import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

/// TABIBI (طبيبي) - Secure HTTP / REST Client (Powered by Dio)
class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage = SecureStorage();

  ApiClient() {
    _dio = Dio(
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

    // إضافة معالج تلقائي لإرفاق التوكن مع كل طلب
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // يمكن تتبع أخطاء الاتصال هنا مستقبلاً
          return handler.next(error);
        },
      ),
    );
  }

  /// طلب GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// طلب POST (إرسال بيانات JSON)
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// دالة مخصصة لتحويل أخطاء الاتصال إلى رسائل مفهومة باللغة العربية
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
        return 'انتهت مهلة الاتصال بالخادم، يرجى التحقق من سرعة الإنترنت.';
      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالخادم، يرجى التأكد من تشغيل الإنترنت في هاتفك.';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401) return 'جلسة الدخول غير صالحة أو منتهية، يرجى تسجيل الدخول.';
        if (status == 403) return 'ليس لديك الصلاحية الكافية للوصول لهذا القسم.';
        if (status == 404) return 'الخدمة المطلوبة غير متوفرة حالياً على الخادم.';
        if (status == 500) return 'حدث خطأ داخلي في الخادم، يرجى المحاولة لاحقاً.';
        return 'حدث خطأ غير متوقع أثناء معالجة الطلب (كود: $status).';
      case DioExceptionType.cancel:
        return 'تم إلغاء عملية الاتصال.';
      default:
        return 'حدث خطأ غير متوقع أثناء الاتصال بالشبكة.';
    }
  }
}