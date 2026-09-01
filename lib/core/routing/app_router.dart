import 'package:go_router/go_router.dart';

// 1. شاشات المصادقة والحسابات
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// 2. لوحة الإدارة المركزية والمسؤول
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

// 3. الهيكل الرئيسي وشريط التنقل السفلي للمريض
import '../../features/home/presentation/screens/main_nav_screen.dart';

// 4. شاشات المريض
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/search_and_book_screen.dart';
import '../../features/patient/presentation/screens/records_and_prescriptions_screen.dart';

// 5. شاشات الطبيب
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/doctor/presentation/screens/schedule_settings_screen.dart';

// 6. المحادثات والمكتبة ثلاثية الأبعاد
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/medical_3d/presentation/screens/anatomy_viewer_screen.dart';

/// TABIBI (طبيبي) - Master Universal Navigation Router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // مسارات الدخول
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // لوحة الإدارة والمسؤول المركزية
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // الشاشة الرئيسية الكبرى للمريض بشريط التنقل السفلي
      GoRoute(
        path: '/patient-home',
        builder: (context, state) => const MainNavScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // مسارات المريض الفرعية
      GoRoute(
        path: '/patient-search-book',
        builder: (context, state) => const SearchAndBookScreen(),
      ),
      GoRoute(
        path: '/patient-records',
        builder: (context, state) => const RecordsAndPrescriptionsScreen(),
      ),

      // مسارات الطبيب
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor-schedule',
        builder: (context, state) => const ScheduleSettingsScreen(),
      ),

      // المحادثات والمكتبة 3D
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/anatomy-3d',
        builder: (context, state) => const AnatomyViewerScreen(),
      ),
    ],
  );
}
