import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../data/patient_repository.dart';

/// TABIBI (طبيبي) - Ultra-Modern Glassmorphic Bento Patient Home Screen
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
    return Scaffold(
      body: AmbientLightBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async => _loadDashboard(),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 50),
                          const SizedBox(height: 12),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. شريط الترحيب وجرس الإشعارات
                      _buildHeaderGreeting(profile),
                      const SizedBox(height: 16),

                      // 2. شريط البحث الطبي الذكي
                      _buildSearchBar(context),
                      const SizedBox(height: 18),

                      // 3. البانر الدعائي "صحتك تهمنا"
                      _buildPromoBanner(context),
                      const SizedBox(height: 20),

                      // 4. شريط التخصصات الطبية الحية
                      _buildSpecialtiesSection(context),
                      const SizedBox(height: 20),

                      // 5. بطاقة السجل الصحي الموحد المتدرجة (Gradient Health Card)
                      _buildUnifiedHealthCard(profile),
                      const SizedBox(height: 22),

                      // 6. المواعيد الطبية القادمة
                      _buildSectionHeader('المواعيد القادمة', () => context.push('/patient-records')),
                      const SizedBox(height: 10),
                      _buildAppointmentsPreview(appointments),
                      const SizedBox(height: 22),

                      // 7. الوصفات الطبية الأخيرة
                      _buildSectionHeader('الوصفات الأخيرة', () => context.push('/patient-records')),
                      const SizedBox(height: 10),
                      _buildPrescriptionsPreview(prescriptions),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderGreeting(Map<String, dynamic> profile) {
    final name = profile['first_name'] ?? 'أحمد';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('👨', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'مرحباً $name',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textMain),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const Text(
                  'كيف تشعر اليوم؟ صحتك أولويتنا',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),

        // جرس التنبيهات مع النقطة الحمراء
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textMain, size: 22),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/patient-search-book'),
      child: GlassBentoCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'ابحث عن طبيب أو تخصص عيادي...',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.promoBannerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'صحتك تهمنا دائماً',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'احجز موعدك الآن مع نخبة من أفضل الأطباء المعتمدين في الجزائر.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600, height: 1.5),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/patient-search-book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('احجز الآن', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('👨‍⚕️', style: TextStyle(fontSize: 40))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesSection(BuildContext context) {
    final specialties = [
      {'name': 'قلب', 'emoji': '🫀', 'id': 1},
      {'name': 'أسنان', 'emoji': '🦷', 'id': 2},
      {'name': 'جلدية', 'emoji': '🧴', 'id': 3},
      {'name': 'أطفال', 'emoji': '👶', 'id': 4},
      {'name': 'عظام', 'emoji': '🦴', 'id': 5},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('اختر التخصص', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: specialties.map((spec) {
            return GestureDetector(
              onTap: () => context.push('/patient-search-book'),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(child: Text(spec['emoji'].toString(), style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    spec['name'].toString(),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUnifiedHealthCard(Map<String, dynamic> profile) {
    final mrn = profile['record_number'] ?? 'غير متوفر';
    final blood = profile['blood_group'] ?? 'O+';
    final allergies = (profile['allergies'] != null && profile['allergies'].toString().isNotEmpty)
        ? profile['allergies'].toString()
        : 'لا توجد حساسيات مسجلة';
    final chronic = (profile['chronic_diseases'] != null && profile['chronic_diseases'].toString().isNotEmpty)
        ? profile['chronic_diseases'].toString()
        : 'لا توجد أمراض مزمنة';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.healthCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
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
              const Row(
                children: [
                  Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'الملف الصحي الموحد',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              Text(
                mrn,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHealthMetric('فصيلة الدم', blood, '🩸'),
              _buildHealthMetric('الوزن التقريبي', '70 كلغ', '⚖️'),
              _buildHealthMetric('الطول', '175 سم', '📏'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الحساسيات: $allergies • المزمنة: $chronic',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('عرض الكل ➔', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary)),
        ),
      ],
    );
  }

  Widget _buildAppointmentsPreview(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return GlassBentoCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('لا توجد مواعيد قادمة مسجلة.', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: list.take(2).map((appt) {
        final docName = 'د. ${appt['doc_first'] ?? ''} ${appt['doc_last'] ?? ''}'.trim();
        final spec = appt['specialization_name'] ?? 'استشارة عامة';
        final date = appt['appointment_date'] ?? '';
        final time = appt['appointment_time'] ?? '';

        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('👨‍⚕️', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(docName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14)),
                    Text(spec, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$date | $time', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.secondary)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrescriptionsPreview(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return GlassBentoCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('لا توجد وصفات طبية صادرة مؤخراً.', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: list.take(2).map((rx) {
        final code = rx['prescription_code'] ?? 'RX';
        final doc = 'د. ${rx['doc_first'] ?? ''} ${rx['doc_last'] ?? ''}'.trim();
        final date = rx['created_at'] != null ? rx['created_at'].toString().split(' ').first : '';

        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          onTap: () => context.push('/patient-records'),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('💊', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(code, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primary)),
                    Text('بواسطة: $doc • $date', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        );
      }).toList(),
    );
  }
}
