import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../auth/logic/auth_bloc.dart';

/// TABIBI (طبيبي) - Ultra-Modern Glassmorphic Bento User Profile & Stats Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| حسابي والبيانات', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              context.go('/login');
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            if (state is Authenticated) {
              final user = state.user;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. بطاقة الهوية الرقمية الزجاجية
                    _buildUserProfileHeader(user),
                    const SizedBox(height: 14),

                    // 2. بطاقات Bento للمؤشرات السريعة (حسب الدور)
                    if (user.isPatient)
                      _buildPatientBentoStats(user)
                    else if (user.isDoctor)
                      _buildDoctorBentoStats(user),

                    const SizedBox(height: 14),

                    // 3. بطاقة تفاصيل الحساب الأساسية
                    _buildAccountDetailsBento(user),
                    const SizedBox(height: 20),

                    // 4. زر تسجيل الخروج التفاعلي
                    GlassBentoCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(6),
                      onTap: () => _confirmLogout(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'تسجيل الخروج من التطبيق',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return const Center(child: Text('يرجى تسجيل الدخول.'));
          },
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader(user) {
    return GlassBentoCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(22),
      gradient: AppTheme.primaryGradient,
      enableGlow: true,
      glowColor: AppTheme.primary,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
              ),
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Text(
                  user.isDoctor ? '👨‍⚕️' : (user.gender == 'female' ? '👩' : '👨'),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.isDoctor ? 'د. ${user.fullName}' : user.fullName,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.roleDisplay,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (user.recordNumber != null && user.recordNumber!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '📂 الملف الموحد: ${user.recordNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientBentoStats(user) {
    return Row(
      children: [
        Expanded(
          child: _buildBentoStatPill('فصيلة الدم', user.bloodGroup?.isNotEmpty == true ? user.bloodGroup! : 'غير محددة', '🩸', Colors.redAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoStatPill('الحساسيات', user.allergies?.isNotEmpty == true ? 'مسجلة ⚠️' : 'سليم ✓', '🛡️', Colors.amber.shade800),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoStatPill('الأمراض', user.chronicDiseases?.isNotEmpty == true ? 'مسجلة' : 'لا يوجد', '🩺', AppTheme.secondary),
        ),
      ],
    );
  }

  Widget _buildDoctorBentoStats(user) {
    return Row(
      children: [
        Expanded(
          child: _buildBentoStatPill('التخصص', user.specializationName ?? 'طب عام', '⚕️', AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoStatPill('الخبرة', '${user.experienceYears ?? 0} سنوات', '💼', AppTheme.secondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoStatPill('الكشفية', '${user.consultationFee ?? 2000} د.ج', '🪙', Colors.amber.shade800),
        ),
      ],
    );
  }

  Widget _buildBentoStatPill(String title, String value, String emoji, Color color) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      enableGlow: true,
      glowColor: color,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w900, color: color),
          ),
          Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsBento(user) {
    return GlassBentoCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_rounded, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'البيانات الشخصية المسجلة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textMain),
              ),
            ],
          ),
          const Divider(height: 22),
          _buildInfoRow('البريد الإلكتروني', user.email, Icons.email_outlined),
          _buildInfoRow('رقم الهاتف', user.phone.isNotEmpty ? user.phone : 'غير مدرج', Icons.phone_outlined),
          _buildInfoRow('تاريخ الميلاد', user.dateOfBirth.isNotEmpty ? user.dateOfBirth : 'غير محدد', Icons.cake_outlined),
          _buildInfoRow('الجنس', user.gender == 'male' ? 'ذكر' : 'أنثى', Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMain),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            child: const Text('تأكيد الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
