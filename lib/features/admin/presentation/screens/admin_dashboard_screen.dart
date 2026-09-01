import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../../auth/logic/auth_bloc.dart';

/// TABIBI (طبيبي) - Ultra-Modern Admin & System Management Dashboard
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // بيانات مطابقة لإحصائيات وسجلات موقعك الحقيقية
  final Map<String, dynamic> _adminData = {
    'total_doctors': 3,
    'total_patients': 22,
    'total_appointments': 31,
    'total_revenue': '37,000.00',
    'system_status': 'مستقرة وآمنة',
    'audit_logs': [
      {
        'action': 'login_success',
        'actor': 'المدير العام',
        'desc': 'User logged in successfully.',
        'ip': '154.255.70.255',
        'time': '2026-09-01 01:34:46',
      },
      {
        'action': 'logout',
        'actor': 'Moi Hi (مريض)',
        'desc': 'User logged out.',
        'ip': '154.255.70.255',
        'time': '2026-09-01 01:34:05',
      },
      {
        'action': 'login_failed_password',
        'actor': 'المساعد الطبي',
        'desc': 'Failed login with invalid password.',
        'ip': '154.255.70.255',
        'time': '2026-09-01 01:15:56',
      },
      {
        'action': 'login_success',
        'actor': 'د. محمد بن عيسى',
        'desc': 'Doctor started consultation shift.',
        'ip': '154.255.70.255',
        'time': '2026-09-01 00:58:12',
      },
    ],
    'recent_users': [
      {'name': 'Nanova Center', 'email': 'nanovacenter@gmail.com', 'role': 'المريض', 'date': '2026-08-31', 'is_doctor': false},
      {'name': 'jtjrjjrrj dndnc cm', 'email': 'fghdf@gdc.dff', 'role': 'المريض', 'date': '2026-08-16', 'is_doctor': false},
      {'name': 'Youcef Nechadi', 'email': 'nechadiyoucef25@gmail.com', 'role': 'المريض', 'date': '2026-08-15', 'is_doctor': false},
      {'name': 'د. محمد بن عيسى', 'email': 'dr.benaissa@tabibi.dz', 'role': 'الطبيب المعالج', 'date': '2026-08-15', 'is_doctor': true},
      {'name': 'فلسطيني صحي', 'email': 'filstini29@gmail.com', 'role': 'المريض', 'date': '2026-08-15', 'is_doctor': false},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| بوابة الإدارة المركزية', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              // 1. بانر الإدارة الكحلي الفاخر
              _buildAdminBanner(),
              const SizedBox(height: 18),

              // 2. شبكة إحصائيات النظام الأربعة
              _buildAdminStatsGrid(),
              const SizedBox(height: 22),

              // 3. أدوات التحكم والإدارة والنسخ الاحتياطي
              _buildSectionTitle('⚙️ أدوات التحكم والإدارة والنسخ الاحتياطي'),
              const SizedBox(height: 10),
              _buildManagementTiles(context),
              const SizedBox(height: 24),

              // 4. سجل التدقيق والعمليات الأمنية (Audit Logs)
              _buildSectionTitle('🛡️ سجل التدقيق والعمليات الأمنية (Audit Logs)'),
              const SizedBox(height: 10),
              _buildAuditLogsList(),
              const SizedBox(height: 24),

              // 5. آخر الحسابات المنشأة حديثاً
              _buildSectionTitle('👥 آخر الحسابات المنشأة حديثاً في النظام'),
              const SizedBox(height: 10),
              _buildRecentAccountsList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'بوابة الإدارة المركزية | طبيبي',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text('حالة النظام: مستقرة وآمنة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'مرحباً بك مجدداً في لوحة التحكم الفنية الشاملة لعام [2026]. راقب السجلات ودرجات أمان النظام والعمليات السريرية.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildKpiCard('إجمالي الأطباء', '${_adminData['total_doctors']}', '⚕️', AppTheme.primary, const Color(0xFFE8F5E9))),
            const SizedBox(width: 10),
            Expanded(child: _buildKpiCard('إجمالي المرضى', '${_adminData['total_patients']}', '👥', AppTheme.secondary, const Color(0xFFE0F2FE))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildKpiCard('إجمالي المواعيد', '${_adminData['total_appointments']}', '📅', const Color(0xFF8B5CF6), const Color(0xFFF3E8FF))),
            const SizedBox(width: 10),
            Expanded(child: _buildKpiCard('الإيرادات المستلمة', '${_adminData['total_revenue']} د.ج', '🪙', const Color(0xFFF59E0B), const Color(0xFFFEF3C7))),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, String emoji, Color fg, Color bg) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enableGlow: true,
      glowColor: fg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w900, color: fg)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTiles(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _buildTileItem('إدارة الأطباء', '⚕️', AppTheme.primary, () => _showNotice(context, 'إدارة الأطباء: إضافة، تعديل الرخص والعيادات')),
        _buildTileItem('إدارة المرضى', '👥', AppTheme.secondary, () => _showNotice(context, 'إدارة المرضى: تدقيق وتعديل الملفات الموحدة')),
        _buildTileItem('إعدادات النظام', '⚙️', Colors.blueGrey, () => _showNotice(context, 'إعدادات النظام: هوية العيادة، أرقام الطوارئ، وحسابات CCP و BaridiMob')),
        _buildTileItem('النسخ الاحتياطي', '💾', Colors.teal, () => _showNotice(context, 'النسخ الاحتياطي: توليد ملفات SQL Dump المشفرة للبيانات')),
      ],
    );
  }

  Widget _buildTileItem(String title, String emoji, Color color, VoidCallback onTap) {
    return GlassBentoCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMain),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAuditLogsList() {
    final logs = _adminData['audit_logs'] as List<Map<String, dynamic>>;

    return Column(
      children: logs.map((log) {
        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'العملية: ${log['action']}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                    ),
                  ),
                  Text(
                    log['time'].toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                log['desc'].toString(),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الفاعل: ${log['actor']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  Text('IP: ${log['ip']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.blueGrey)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentAccountsList() {
    final users = _adminData['recent_users'] as List<Map<String, dynamic>>;

    return Column(
      children: users.map((u) {
        final isDoctor = u['is_doctor'] == true;

        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDoctor ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.secondary.withValues(alpha: 0.1),
                child: Text(isDoctor ? '👨‍⚕️' : '👤', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u['name'].toString(), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textMain)),
                    Text(u['email'].toString(), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDoctor ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      u['role'].toString(),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDoctor ? AppTheme.primary : AppTheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(u['date'].toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل تريد تسجيل الخروج من حساب الإدارة؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
