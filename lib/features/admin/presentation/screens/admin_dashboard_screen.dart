import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../../auth/logic/auth_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final Map<String, dynamic> _adminData = {
    'total_doctors': 3,
    'total_patients': 22,
    'total_appointments': 31,
    'total_revenue': '37,000.00',
    'system_status': 'مستقرة وآمنة',
    'audit_logs': [
      {'action': 'login_success', 'actor': 'المدير العام', 'desc': 'User logged in successfully.', 'ip': '154.255.70.255', 'time': '2026-09-01 01:34:46'},
      {'action': 'logout', 'actor': 'Moi Hi (مريض)', 'desc': 'User logged out.', 'ip': '154.255.70.255', 'time': '2026-09-01 01:34:05'},
    ],
    'recent_users': [
      {'name': 'Nanova Center', 'email': 'nanovacenter@gmail.com', 'role': 'المريض', 'date': '2026-08-31', 'is_doctor': false},
      {'name': 'فلسطيني صحي', 'email': 'falastini29@gmail.com', 'role': 'الطبيب المعالج', 'date': '2026-08-15', 'is_doctor': true},
    ],
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
            Text('| بوابة الإدارة المركزية', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar_rounded, color: AppTheme.primary),
            tooltip: 'المكتبة 3D وتشريح الإنسان',
            onPressed: () => context.push('/anatomy-3d'),
          ),
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
              _buildAdminBanner(),
              const SizedBox(height: 16),
              _buildAdminStatsGrid(),
              const SizedBox(height: 20),

              // زر مميز للأدمن للوصول المباشر للمكتبتين ثلاثية الأبعاد
              GlassBentoCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                onTap: () => context.push('/anatomy-3d'),
                enableGlow: true,
                glowColor: const Color(0xFF6366F1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: const Text('🩻', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المستودع التشريحي 3D وأطلس الإنسان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textMain)),
                          Text('استعراض مجسمات الأعضاء وأطلس تشريح الجسم الكامل', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('⚙️ أدوات التحكم والإدارة والنسخ الاحتياطي'),
              const SizedBox(height: 10),
              _buildManagementTiles(context),
              const SizedBox(height: 24),
              _buildSectionTitle('🛡️ سجل التدقيق والعمليات الأمنية (Audit Logs)'),
              const SizedBox(height: 10),
              _buildAuditLogsList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('بوابة الإدارة المركزية | طبيبي - حالة النظام: مستقرة وآمنة 🛡️', style: TextStyle(fontFamily: 'Cairo', fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }

  Widget _buildAdminStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('الأطباء', '${_adminData['total_doctors']}', '⚕️', AppTheme.primary)),
        const SizedBox(width: 8),
        Expanded(child: _buildKpiCard('المرضى', '${_adminData['total_patients']}', '👤', AppTheme.secondary)),
        const SizedBox(width: 8),
        Expanded(child: _buildKpiCard('الإيرادات', '${_adminData['total_revenue']} د.ج', '🪙', const Color(0xFFF59E0B))),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, String emoji, Color fg) {
    return GlassBentoCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w900, color: fg)),
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
      childAspectRatio: 2.1,
      children: [
        _buildTileItem('إدارة الأطباء', '⚕️', () => context.push('/admin-doctors')),
        _buildTileItem('إدارة المرضى', '👥', () => context.push('/admin-patients')),
        _buildTileItem('إعدادات النظام', '⚙️', () => context.push('/admin-settings')),
        _buildTileItem('النسخ الاحتياطي', '💾', () => context.push('/admin-backups')),
      ],
    );
  }

  Widget _buildTileItem(String title, String emoji, VoidCallback onTap) {
    return GlassBentoCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, fontWeight: FontWeight.w900))),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAuditLogsList() {
    final logs = _adminData['audit_logs'] as List<Map<String, dynamic>>;
    return Column(
      children: logs.map((log) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassBentoCard(
            borderRadius: 14,
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('العملية: ${log['action']} (${log['actor']})', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                Text(log['time'].toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: Colors.grey)),
              ],
            ),
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
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    context.read<AuthCubit>().logout();
    context.go('/landing');
  }
}
