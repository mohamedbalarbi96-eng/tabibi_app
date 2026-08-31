/// TABIBI (طبيبي) - Core API Endpoints Configuration
class ApiEndpoints {
  // عند التشغيل على جهازك المحلي نربطه بسيرفر الجافا المحلي مباشرة
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';

  // مهلة الاتصال بالخادم
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // مسارات المصادقة والحسابات
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot_password';

  // مسارات المريض
  static const String patientProfile = '/patient/dashboard';
  static const String doctorsList = '/doctors/list';
  static const String doctorDetails = '/doctors/details';
  static const String bookAppointment = '/appointments/book';
  static const String patientAppointments = '/patient/appointments';
  static const String patientPrescriptions = '/patient/prescriptions';
  static const String patientShares = '/patient/shares';
  static const String rateDoctor = '/patient/rate';

  // مسارات الطبيب
  static const String doctorQueue = '/doctor/clinical';
  static const String doctorVisit = '/doctor/clinical';
  static const String doctorSchedule = '/doctor/schedule';

  // مسارات المحادثات
  static const String chatMessages = '/chat/messages';
  static const String notificationsPoll = '/notifications/poll';
}
