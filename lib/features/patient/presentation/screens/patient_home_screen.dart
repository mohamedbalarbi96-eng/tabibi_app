import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/logic/auth_bloc.dart';
import '../../data/patient_repository.dart';

/// TABIBI (طبيبي) - Patient Home & Medical Record Dashboard Screen
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final PatientRepository _repository = PatientRepository();
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    setState(() {
      _dashboardFuture = _repository.getDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طبيبي | ملفي الطبي الموحد'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            tooltip: 'المحادثات الطبية',
            onPressed: () => context.push('/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboard(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 54),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadDashboard,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data ?? {};
            final profile = data['profile'] as Map<String, dynamic>? ?? {};
            final appointments = (data['appointments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            final prescriptions = (data['prescriptions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. بطاقة الهوية ورقم الملف الطبي (MRN)
                  _buildIdentityBanner(theme, profile),
                  const SizedBox(height: 20),

                  // 2. المؤشرات الصحية السريعة (فصيلة الدم، الحساسيات)
                  _buildHealthIndicators(theme, profile),
                  const SizedBox(height: 24),

                  // 3. شبكة روابط الوصول السريع
                  _buildQuickAccessGrid(context, theme),
                  const SizedBox(height: 24),

                  // 4. قسم المواعيد القادمة
                  _buildSectionHeader('📅 المواعيد الطبية الأخيرة', () => context.push('/patient-records')),
                  const SizedBox(height: 10),
                  _buildAppointmentsList(theme, appointments),
                  const SizedBox(height: 24),

                  // 5. قسم الوصفات الطبية الأخيرة
                  _buildSectionHeader('✍️ الوصفات الرقمية الأخيرة', () => context.push('/patient-records')),
                  const SizedBox(height: 10),
                  _buildPrescriptionsList(theme, prescriptions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIdentityBanner(ThemeData theme, Map<String, dynamic> profile) {
    final fullName = profile['full_name'] ?? 'المريض';
    final mrn = profile['record_number'] ?? 'غير متوفر';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF047857)],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مرحباً بك، $fullName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('مريض', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder_shared_outlined, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'الملف الموحد: $mrn',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicators(ThemeData theme, Map<String, dynamic> profile) {
    final blood = profile['blood_group'] ?? 'غير محددة';
    final allergies = (profile['allergies'] != null && profile['allergies'].toString().isNotEmpty)
        ? profile['allergies'].toString()
        : 'لا توجد حساسيات مسجلة';
    final chronic = (profile['chronic_diseases'] != null && profile['chronic_diseases'].toString().isNotEmpty)
        ? profile['chronic_diseases'].toString()
        : 'لا توجد أمراض مزمنة';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.bloodtype_rounded, color: Colors.redAccent, size: 24),
                const SizedBox(width: 8),
                const Text('فصيلة الدم:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(blood, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            ),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('الحساسيات: $allergies', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_services_outlined, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('الأمراض المزمنة: $chronic', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚡ الخدمات الطبية السريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
          children: [
            _buildTile(context, 'حجز موعد', '🗓️', '/patient-search-book', theme),
            _buildTile(context, 'الأطباء', '👨‍⚕️', '/patient-search-book', theme),
            _buildTile(context, 'الوصفات', '✍️', '/patient-records', theme),
            _buildTile(context, 'المواعيد', '📅', '/patient-records', theme),
            _buildTile(context, 'مشاركة ملفي', '🤝', '/patient-records', theme),
            _buildTile(context, 'مكتبة 3D', '🧬', '/anatomy-3d', theme),
          ],
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, String title, String emoji, String route, ThemeData theme) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: const Text('عرض الكل', style: TextStyle(fontSize: 12))),
      ],
    );
  }

  Widget _buildAppointmentsList(ThemeData theme, List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('لا توجد مواعيد طبية مسجلة حالياً.', style: TextStyle(fontSize: 13, color: Colors.grey))),
      );
    }

    return Column(
      children: list.take(3).map((appt) {
        final docName = 'د. ${appt['doc_first'] ?? ''} ${appt['doc_last'] ?? ''}'.trim();
        final date = appt['appointment_date'] ?? '';
        final time = appt['appointment_time'] ?? '';
        final status = appt['status_name'] ?? 'مؤكد';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.event_available_rounded, color: theme.colorScheme.primary),
            ),
            title: Text(docName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('$date | $time', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(status, style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrescriptionsList(ThemeData theme, List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('لا توجد وصفات طبية صادرة حتى الآن.', style: TextStyle(fontSize: 13, color: Colors.grey))),
      );
    }

    return Column(
      children: list.take(3).map((rx) {
        final code = rx['prescription_code'] ?? 'RX';
        final doc = 'د. ${rx['doc_first'] ?? ''} ${rx['doc_last'] ?? ''}'.trim();
        final date = rx['created_at'] != null ? rx['created_at'].toString().split(' ').first : '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE0F2FE),
              child: Icon(Icons.receipt_long_rounded, color: Color(0xFF0284C7)),
            ),
            title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace')),
            subtitle: Text('$doc • $date', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: () => context.push('/patient-records'),
          ),
        );
      }).toList(),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}