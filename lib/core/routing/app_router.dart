import 'package:go_router/go_router.dart';

// 1. شاشات المصادقة والحسابات
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// 2. شاشات المريض
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/search_and_book_screen.dart';
import '../../features/patient/presentation/screens/records_and_prescriptions_screen.dart';

// 3. شاشات الطبيب
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/doctor/presentation/screens/schedule_settings_screen.dart';

// 4. المحادثات والمكتبة ثلاثية الأبعاد
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/medical_3d/presentation/screens/anatomy_viewer_screen.dart';

/// TABIBI (طبيبي) - Master Navigation Router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // 1. Auth Routes
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
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // 2. Patient Routes
      GoRoute(
        path: '/patient-home',
        builder: (context, state) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: '/patient-search-book',
        builder: (context, state) => const SearchAndBookScreen(),
      ),
      GoRoute(
        path: '/patient-records',
        builder: (context, state) => const RecordsAndPrescriptionsScreen(),
      ),

      // 3. Doctor Routes
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor-schedule',
        builder: (context, state) => const ScheduleSettingsScreen(),
      ),

      // 4. Chat & 3D Routes
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