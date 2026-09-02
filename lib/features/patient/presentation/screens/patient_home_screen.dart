import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../../auth/logic/auth_bloc.dart';

/// TABIBI (طبيبي) - Ultra-Modern Patient Unified Health Portal Screen
/// Matched 100% with the official Patient Dashboard screenshots (Images 2 & 5)
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  // بيانات المريض الحقيقية المطابقة للصورة
  final Map<String, dynamic> _patientData = {
    'name': 'Moi Hi',
    'mrn': 'MR-2026-00010',
    'blood_group': 'B-',
    'dob': '2026-08-08',
    'gender': 'ذكر',
    'allergies': 'لا يوجد حساسيات مسجلة.',
    'chronic': 'لا يوجد أمراض مزمنة مسجلة.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| ملفي الصحي الرقمي', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              // 1. بانر الترحيب الأخضر المطابق للصورة
              _buildPatientHeroBanner(),
              const SizedBox(height: 18),

              // 2. بطاقة المؤشرات الصحية الحيوية (فصيلة الدم B-، تاريخ الميلاد...)
              _buildSectionTitle('🩸 المؤشرات الصحية الحيوية'),
              const SizedBox(height: 8),
              _buildVitalsSummaryCard(),
              const SizedBox(height: 22),

              // 3. شبكة روابط الوصول السريع (7 أزرار Bento تفاعلية)
              _buildSectionTitle('⚡ روابط الوصول السريع'),
              const SizedBox(height: 10),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 24),

              // 4. التقارير وصور الأشعة والتحاليل المرفوعة
              _buildSectionTitle('🩻 التقارير وصور الأشعة والتحاليل الطبية المرفوعة'),
              const SizedBox(height: 8),
              _buildEmptySectionCard(
                icon: Icons.image_not_supported_outlined,
                message: 'لا توجد صور أشعة (راديو) أو تحاليل طبية مرفوعة لملفك الموحد حالياً.',
              ),
              const SizedBox(height: 22),

              // 5. سجل قياس علاماتي الحيوية التاريخية
              _buildSectionTitle('📊 سجل قياس علاماتي الحيوية التاريخية'),
              const SizedBox(height: 8),
              _buildEmptySectionCard(
                icon: Icons.bar_chart_rounded,
                message: 'لا توجد أي قياسات علامات حيوية (ضغط، نبض، حرارة) مسجلة لملفك الطبي حتى الآن.',
              ),
              const SizedBox(height: 22),

              // 6. المواعيد الطبية الحديثة
              _buildSectionTitle('📅 المواعيد الطبية الحديثة'),
              const SizedBox(height: 8),
              _buildAppointmentsCard(context),
              const SizedBox(height: 22),

              // 7. الوصفات الطبية الرقمية المتوفرة
              _buildSectionTitle('✍️ الوصفات الطبية الرقمية المتوفرة'),
              const SizedBox(height: 8),
              _buildEmptySectionCard(
                icon: Icons.draw_outlined,
                message: 'لا توجد وصفات طبية رقمية مرسلة لملفك حتى الآن.',
                actionLabel: 'استعراض الأرشيف 💊',
                onAction: () => context.push('/patient-records'),
              ),
              const SizedBox(height: 30),

              // 8. الفوتر وأرقام الطوارئ الجزائرية
              _buildFooterEmergency(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF047857)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: const Color(0xFF065F46).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مرحباً بك مجدداً، ${_patientData['name']}',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.folder_shared_rounded, color: Colors.amberAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('ملف طبي: ${_patientData['mrn']}', style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'أهلاً بك في ملفك الصحي الرقمي الموحد. يمكنك مراجعة حالتك الصحية وتتبع المواعيد وتحميل ملفات الأشعة والتحاليل والاطلاع على علاماتك الحيوية.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSummaryCard() {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('فصيلة الدم:', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(_patientData['blood_group'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.redAccent)),
              ),
            ],
          ),
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('تاريخ الميلاد:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: Colors.grey.shade700)),
              Text(_patientData['dob'], style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الجنس:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: Colors.grey.shade700)),
              Text(_patientData['gender'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الحساسيات المعروفة:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
              Text(_patientData['allergies'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الأمراض المزمنة:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
              Text(_patientData['chronic'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildBentoActionButton('البحث عن طبيب', '🔍', AppTheme.primary, () => context.push('/patient-search-doctors'))),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoActionButton('المحادثات', '💬', AppTheme.secondary, () => context.push('/doctor-chat'))),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoActionButton('حجز موعد', '📅', const Color(0xFF0284C7), () => context.push('/patient-book-appointment'))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildBentoActionButton('المواعيد', '🗓️', const Color(0xFF8B5CF6), () => context.push('/patient-appointments'))),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoActionButton('الوصفات', '✍️', const Color(0xFF10B981), () => context.push('/patient-records'))),
            const SizedBox(width: 8),
            Expanded(child: _buildBentoActionButton('مشاركة ملفي', '🤝', const Color(0xFFF59E0B), () => context.push('/patient-share-record'))),
          ],
        ),
        const SizedBox(height: 8),
        _buildFullWidthBentoButton('مكتبة TABIBI 3D التشريحية التفاعلية 🧬', 'استكشف أعضاء جسم الإنسان ومسارات الفحص الطبي التفاعلي', const Color(0xFF6366F1), () => context.push('/anatomy-3d')),
      ],
    );
  }

  Widget _buildBentoActionButton(String label, String emoji, Color color, VoidCallback onTap) {
    return GlassBentoCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      onTap: onTap,
      enableGlow: true,
      glowColor: color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 11.5, color: AppTheme.textMain),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthBentoButton(String title, String subtitle, Color color, VoidCallback onTap) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      enableGlow: true,
      glowColor: color,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Text('🧬', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12.5, color: AppTheme.textMain)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAppointmentsCard(BuildContext context) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), shape: BoxShape.circle),
            child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF0284C7), size: 32),
          ),
          const SizedBox(height: 10),
          const Text('لا تمتلك أي مواعيد طبية مسجلة حالياً.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            label: const Text('حجز أول موعد لك 📅', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => context.push('/patient-book-appointment'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySectionCard({required IconData icon, required String message, String? actionLabel, VoidCallback? onAction}) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 32),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 10),
              TextButton(onPressed: onAction, child: Text(actionLabel, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.primary))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterEmergency() {
    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEmergencyPill('🚒 الحماية المدنية', '14', Colors.redAccent),
          _buildEmergencyPill('🚑 المساعدة الاستعجالية (SAMU)', '115', const Color(0xFF0284C7)),
        ],
      ),
    );
  }

  Widget _buildEmergencyPill(String label, String number, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(number, style: TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
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
        content: const Text('هل تريد تسجيل الخروج من ملفك الصحي؟', style: TextStyle(fontFamily: 'Cairo')),
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
