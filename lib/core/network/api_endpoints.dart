/// TABIBI (طبيبي) - Core API Endpoints Configuration
class ApiEndpoints {
  // الرابط الأساسي الحقيقي لموقعك
  static const String baseUrl = 'https://doctor29.gamer.free/api/v1';

  // مهلة الاتصال بالخادم (بالثواني)
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // مسارات المصادقة والحسابات (Auth Endpoints)
  static const String login = '/auth/login.php';
  static const String register = '/auth/register.php';
  static const String forgotPassword = '/auth/forgot_password.php';

  // مسارات المريض (ستُفعل في مراحلها المخصصة)
  static const String patientProfile = '/patient/profile.php';
  static const String doctorsList = '/doctors/list.php';
  static const String doctorDetails = '/doctors/details.php';
  static const String bookAppointment = '/appointments/book.php';
  static const String patientAppointments = '/patient/appointments.php';
  static const String patientPrescriptions = '/patient/prescriptions.php';
  static const String patientShares = '/patient/shares.php';
  static const String rateDoctor = '/patient/rate.php';

  // مسارات الطبيب
  static const String doctorQueue = '/doctor/queue.php';
  static const String doctorVisit = '/doctor/visit.php';
  static const String doctorSchedule = '/doctor/schedule.php';

  // مسارات المحادثات والإشعارات
  static const String chatMessages = '/chat/messages.php';
  static const String notificationsPoll = '/notifications/poll.php';
}