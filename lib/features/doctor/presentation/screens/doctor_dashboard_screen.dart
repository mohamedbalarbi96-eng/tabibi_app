import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../../auth/logic/auth_bloc.dart';

/// TABIBI (طبيبي) - Ultra-Luxury Doctor Dashboard Screen
/// Matched 100% with the official Doctor Dashboard screenshot
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final TextEditingController _searchPatientCtrl = TextEditingController();

  // بيانات مواعيد الطبيب قيد الانتظار المطابقة للصورة
  final List<Map<String, dynamic>> _pendingAppointments = [
    {
      'id': 1,
      'name': 'Azer Azee',
      'mrn': 'MR-2026-00015',
      'date': '2026-08-13',
      'time': '10:00',
      'service': 'فحص تخطيط القلب الكهربائي (ECG)',
      'is_confirmed': false,
    },
    {
      'id': 2,
      'name': 'jtjrjjrrj dndnc cm',
      'mrn': 'MR-2026-00021',
      'date': '2026-08-17',
      'time': '08:00',
      'service': 'فحص متخصص متقدم',
      'is_confirmed': false,
    },
    {
      'id': 3,
      'name': 'بلعربي الهادي',
      'mrn': 'MR-2026-00002',
      'date': '2026-08-19',
      'time': '15:00',
      'service': 'فحص عام واستشارة طبية',
      'is_confirmed': false,
    },
    {
      'id': 4,
      'name': 'محمد بلعربي',
      'mrn': 'MR-2026-00014',
      'date': '2026-08-31',
      'time': '12:30',
      'service': 'فحص عام واستشارة طبية',
      'is_confirmed': false,
    },
  ];

  @override
  void dispose() {
    _searchPatientCtrl.dispose();
    super.dispose();
  }

  void _confirmAppointment(int index) {
    setState(() {
      _pendingAppointments[index]['is_confirmed'] = true;
    });
    final appt = _pendingAppointments[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم قبول وتأكيد حجز المريض ${appt['name']} بنجاح!', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _searchPatient() {
    final query = _searchPatientCtrl.text.trim();
    if (query.isEmpty) return;

    // توجيه الطبيب لملف المريض المطابق للصورة
    context.push('/doctor-patient-record', extra: {
      'name': query.contains('بلعربي') ? 'بلعربي الهادي' : query,
      'mrn': query.startsWith('MR-') ? query : 'MR-2026-00002',
      'phone': '0673906336',
      'blood_group': '+AB',
      'dob': '2026-08-04',
      'gender': 'ذكر',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| لوحة الطبيب المعالج', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: AmbientLightBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. أزرار الوصول السريع العلوية (المحادثات وأوقات العمل)
              _buildTopActionBar(context),
              const SizedBox(height: 16),

              // 2. شبكة المؤشرات الأربعة
              _buildDoctorStatsGrid(),
              const SizedBox(height: 20),

              // 3. بطاقة البحث السريع عن ملف المريض والمكتبة 3D
              _buildPatientSearchCard(context),
              const SizedBox(height: 22),

              // 4. المرضى الموجودين في قاعة الانتظار لليوم
              _buildSectionTitle('🚶 المرضى الموجودين في قاعة الانتظار لليوم'),
              const SizedBox(height: 8),
              _buildWaitingRoomEmptyCard(),
              const SizedBox(height: 22),

              // 5. طلبات المواعيد الواردة قيد الانتظار
              _buildSectionTitle('📅 طلبات المواعيد الواردة قيد الانتظار (${_pendingAppointments.where((a) => !a['is_confirmed']).length})'),
              const SizedBox(height: 8),
              _buildPendingAppointmentsList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopActionBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => context.push('/doctor-chat'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_rounded, color: Color(0xFF2E7D32), size: 16),
                  SizedBox(width: 6),
                  Text('مركز الرسائل', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  SizedBox(width: 4),
                  CircleAvatar(radius: 8, backgroundColor: Colors.redAccent, child: Text('1', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () => context.push('/doctor-schedule'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, color: Color(0xFF0284C7), size: 16),
                  SizedBox(width: 6),
                  Text('ضبط أوقات العمل والإجازات', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('مواعيد اليوم المجدولة', '0', '📅', AppTheme.primary, const Color(0xFFE8F5E9))),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('في قاعة الانتظار', '0', '🚶', AppTheme.secondary, const Color(0xFFE0F2FE))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard('إجمالي الوصفات', '0', '✍️', const Color(0xFF8B5CF6), const Color(0xFFF3E8FF))),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('إجمالي مداخيلي المالية', '0.00 د.ج', '🪙', const Color(0xFFF59E0B), const Color(0xFFFEF3C7))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color fg, Color bg) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enableGlow: true,
      glowColor: fg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: fg)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSearchCard(BuildContext context) {
    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      enableGlow: true,
      glowColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_search_rounded, color: AppTheme.primary, size: 22),
                  SizedBox(width: 6),
                  Text('البحث واستعراض السجل السريري لمريض', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12.5, color: AppTheme.textMain)),
                ],
              ),
              InkWell(
                onTap: () => context.push('/doctor-3d-anatomy'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.view_in_ar_rounded, color: Color(0xFF8B5CF6), size: 14),
                      SizedBox(width: 4),
                      Text('المكتبة الطبية 3D 🩻', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchPatientCtrl,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'اكتب الاسم الكامل أو رقم الملف (مثال: MR-2026-00002)...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  onSubmitted: (_) => _searchPatient(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.search_rounded, size: 16, color: Colors.white),
                label: const Text('ابحث 🔍', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _searchPatient,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingRoomEmptyCard() {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: const Center(
        child: Column(
          children: [
            Text('🚶', style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text('قاعة الانتظار فارغة حالياً. لا يوجد مرضى بانتظار الكشف.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 11.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingAppointmentsList() {
    return Column(
      children: List.generate(_pendingAppointments.length, (index) {
        final appt = _pendingAppointments[index];
        final bool isConfirmed = appt['is_confirmed'] == true;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: GlassBentoCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(appt['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.textMain)),
                    Text('⏰ ${appt['date']} | ${appt['time']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('الخدمة: ${appt['service']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      icon: Icon(isConfirmed ? Icons.check_circle_rounded : Icons.done_rounded, size: 14, color: Colors.white),
                      label: Text(isConfirmed ? 'تم قبول الحجز بنجاح ✓' : 'قبول وتأكيد الحجز ✔️', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConfirmed ? const Color(0xFF059669) : const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isConfirmed ? null : () => _confirmAppointment(index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل تريد تسجيل الخروج من حساب الطبيب؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/landing');
            },
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
