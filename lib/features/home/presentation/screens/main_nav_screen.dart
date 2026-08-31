import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../patient/presentation/screens/patient_home_screen.dart';
import '../../../patient/presentation/screens/search_and_book_screen.dart';
import '../../../patient/presentation/screens/records_and_prescriptions_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// TABIBI (طبيبي) - Master Navigation Shell with Floating Curved Bottom Bar
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PatientHomeScreen(),             // 0: الرئيسية والملف الموحد
    SearchAndBookScreen(),           // 1: حجز المواعيد والأطباء
    RecordsAndPrescriptionsScreen(), // 2: السجل والوصفات والأشعة
    ChatScreen(),                    // 3: المحادثات الطبية
    ProfileScreen(),                 // 4: حسابي والإحصائيات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 11),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 24),
                activeIcon: Icon(Icons.home_rounded, size: 28),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined, size: 24),
                activeIcon: Icon(Icons.calendar_month_rounded, size: 28),
                label: 'المواعيد',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_shared_outlined, size: 24),
                activeIcon: Icon(Icons.folder_shared_rounded, size: 28),
                label: 'السجل الطبي',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded, size: 24),
                activeIcon: Icon(Icons.chat_bubble_rounded, size: 28),
                label: 'المحادثات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 24),
                activeIcon: Icon(Icons.person_rounded, size: 28),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
