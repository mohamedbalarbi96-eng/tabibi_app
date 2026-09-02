/// TABIBI (طبيبي) - Smart Dual Backend Endpoints (Java Primary + PHP Fallback)
class ApiEndpoints {
  // سيرفر Java (Spring Boot) الأساسي
  static const String javaBaseUrl = 'http://127.0.0.1:8080/api';

  // سيرفر PHP الاحتياطي في حال توقف سيرفر Java
  static const String phpBaseUrl = 'http://127.0.0.1/tabibi_api/api';

  // الرابط النشط الافتراضي
  static String baseUrl = javaBaseUrl;
}
