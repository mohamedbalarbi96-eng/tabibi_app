import 'package:go_router/go_router.dart';

// 1. الشاشة الترحيبية والمصادقة
import '../../features/home/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// 2. البوابة الأولى: بوابة الإدارة المركزية والمسؤول
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_doctors_screen.dart';
import '../../features/admin/presentation/screens/admin_patients_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_backups_screen.dart';

// 3. البوابة الثانية: بوابة الطبيب المعالج
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/doctor/presentation/screens/doctor_schedule_screen.dart';
import '../../features/doctor/presentation/screens/doctor_patient_record_screen.dart';
import '../../features/doctor/presentation/screens/doctor_prescription_view_screen.dart';
import '../../features/doctor/presentation/screens/doctor_chat_screen.dart';
import '../../features/doctor/presentation/screens/doctor_3d_anatomy_screen.dart';

// 4. البوابة الثالثة: بوابة الاستقبال ومساعد الطبيب والفوترة
import '../../features/assistant/presentation/screens/assistant_dashboard_screen.dart';

// 5. البوابة الرابعة: بوابة المريض والمستخدم العادي
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/patient_search_doctors_screen.dart';
import '../../features/patient/presentation/screens/patient_share_record_screen.dart';
import '../../features/patient/presentation/screens/patient_book_and_records_screen.dart';

// 6. المكتبة الطبية ثلاثية الأبعاد 3D الشاملة
import '../../features/medical_3d/presentation/screens/anatomy_viewer_screen.dart';

/// TABIBI (طبيبي) - Master Universal Complete Multi-Portal Navigation Router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/landing', // الشاشة الترحيبية الافتتاحية الأولى عند فتح التطبيق
    routes: [
      // 1. الشاشة الترحيبية ومسارات المصادقة
      GoRoute(path: '/landing', builder: (context, state) => const LandingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),

      // 2. مسارات بوابة الإدارة المركزية والمسؤول
      GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin-doctors', builder: (context, state) => const AdminDoctorsScreen()),
      GoRoute(path: '/admin-patients', builder: (context, state) => const AdminPatientsScreen()),
      GoRoute(path: '/admin-settings', builder: (context, state) => const AdminSettingsScreen()),
      GoRoute(path: '/admin-backups', builder: (context, state) => const AdminBackupsScreen()),

      // 3. مسارات بوابة الطبيب المعالج
      GoRoute(path: '/doctor-dashboard', builder: (context, state) => const DoctorDashboardScreen()),
      GoRoute(path: '/doctor-schedule', builder: (context, state) => const DoctorScheduleScreen()),
      GoRoute(
        path: '/doctor-patient-record',
        builder: (context, state) => DoctorPatientRecordScreen(patientData: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/doctor-prescription-view',
        builder: (context, state) => DoctorPrescriptionViewScreen(prescriptionData: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(path: '/doctor-chat', builder: (context, state) => const DoctorChatScreen()),
      GoRoute(path: '/doctor-3d-anatomy', builder: (context, state) => const Doctor3DAnatomyScreen()),

      // 4. مسارات بوابة الاستقبال ومساعد الطبيب والفوترة
      GoRoute(path: '/assistant-dashboard', builder: (context, state) => const AssistantDashboardScreen()),

      // 5. مسارات بوابة المريض والمستخدم العادي
      GoRoute(path: '/patient-home', builder: (context, state) => const PatientHomeScreen()),
      GoRoute(path: '/patient-search-doctors', builder: (context, state) => const PatientSearchDoctorsScreen()),
      GoRoute(path: '/patient-share-record', builder: (context, state) => const PatientShareRecordScreen()),
      GoRoute(
        path: '/patient-book-appointment',
        builder: (context, state) => PatientBookAndRecordsScreen(initialDoctor: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(path: '/patient-appointments', builder: (context, state) => const PatientBookAndRecordsScreen()),
      GoRoute(path: '/patient-records', builder: (context, state) => const PatientBookAndRecordsScreen()),

      // 6. مسار المكتبة الطبية ثلاثية الأبعاد 3D
      GoRoute(path: '/anatomy-3d', builder: (context, state) => const AnatomyViewerScreen()),
    ],
  );
}
