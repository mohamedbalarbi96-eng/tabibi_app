import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/logic/auth_bloc.dart';

/// TABIBI (طبيبي) - Dynamic User Profile & Dashboard Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الطبي والحساب'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من التطبيق؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AuthCubit>().logout();
                      },
                      child: const Text('تأكيد الخروج'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is Authenticated) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // بطاقة الترحيب والاسم
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.isDoctor ? '👨‍⚕️' : (user.gender == 'female' ? '👩' : '👨'),
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.isDoctor ? 'د. ${user.fullName}' : user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.roleDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (user.recordNumber != null && user.recordNumber!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '📂 ملف طبي: ${user.recordNumber}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // البيانات الشخصية والطبية
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'البيانات الأساسية',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoTile('البريد الإلكتروني', user.email, Icons.email_outlined),
                          _buildInfoTile('رقم الهاتف', user.phone.isNotEmpty ? user.phone : 'غير مدرج', Icons.phone_outlined),
                          _buildInfoTile('تاريخ الميلاد', user.dateOfBirth.isNotEmpty ? user.dateOfBirth : 'غير محدد', Icons.cake_outlined),
                          _buildInfoTile('الجنس', user.gender == 'male' ? 'ذكر' : 'أنثى', Icons.person_outline),

                          // بيانات المريض
                          if (user.isPatient) ...[
                            _buildInfoTile('فصيلة الدم', user.bloodGroup?.isNotEmpty == true ? user.bloodGroup! : 'غير محددة', Icons.bloodtype_outlined, isHighlighted: true),
                            if (user.allergies?.isNotEmpty == true)
                              _buildInfoTile('الحساسيات', user.allergies!, Icons.warning_amber_rounded),
                            if (user.chronicDiseases?.isNotEmpty == true)
                              _buildInfoTile('الأمراض المزمنة', user.chronicDiseases!, Icons.medical_services_outlined),
                          ],

                          // بيانات الطبيب
                          if (user.isDoctor) ...[
                            if (user.specializationName != null)
                              _buildInfoTile('التخصص الطبي', user.specializationName!, Icons.local_hospital_outlined, isHighlighted: true),
                            if (user.licenseNumber != null)
                              _buildInfoTile('رقم الرخصة المهنية', user.licenseNumber!, Icons.verified_user_outlined),
                            if (user.clinicName != null)
                              _buildInfoTile('العيادة', user.clinicName!, Icons.location_city_outlined),
                            if (user.consultationFee != null)
                              _buildInfoTile('سعر الكشف', '${user.consultationFee} د.ج', Icons.monetization_on_outlined),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('يرجى تسجيل الدخول.'));
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? const Color(0xFF059669) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}