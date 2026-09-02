import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Luxury Animated Landing Screen
/// Matched 100% with the official live web landing page (Algeria)
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'طبيبي',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Color(0xFF0284C7), size: 10),
                SizedBox(width: 4),
                Text('العربية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => context.push('/login'),
              child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: AmbientLightBackground(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // 1. العنوان الرئيسي الفاخر
                  const Text(
                    'رعاية طبية تليق بك،',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textMain,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'ملفك الطبي الموحد في جيبك.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 2. النص التوضيحي للمنصة
                  Text(
                    'منصة "طبيبي" المتكاملة توفر للأطباء والمرضى في الجزائر فضاءً رقمياً آمناً ومبسطاً لمتابعة الفحوصات، استقبال الوصفات الإلكترونية، وحجز المواعيد الطبية بشكل ذكي.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),

                  // 3. أزرار الإجراءات الرئيسية (إنشاء حساب جديد + تسجيل الدخول)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => context.push('/register'),
                            child: const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.white.withValues(alpha: 0.8),
                            ),
                            onPressed: () => context.push('/login'),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 4. بطاقة TABIBI SYSTEM المركزية الزجاجية
                  _buildSystemCentralCard(),
                  const SizedBox(height: 32),

                  // 5. عنوان قسم مميزات المنصة وحلول الرقمنة
                  _buildFeaturesSectionTitle(),
                  const SizedBox(height: 18),

                  // 6. شبكة بطاقات Bento الأربعة للمميزات
                  _buildFeaturesGrid(),
                  const SizedBox(height: 32),

                  // 7. قسم تواصل معنا وأرقام الطوارئ الجزائرية
                  _buildFooterEmergencySection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemCentralCard() {
    return GlassBentoCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      enableGlow: true,
      glowColor: AppTheme.primary,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.medical_services_rounded, color: AppTheme.primary, size: 40),
          ),
          const SizedBox(height: 14),
          const Text(
            'TABIBI SYSTEM',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.2,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'الجيل الجديد لحلول رقمنة القطاع الصحي وعيادات الأطباء الخواص.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPillBadge('✓ ملف طبي آمن'),
              const SizedBox(width: 10),
              _buildPillBadge('✓ طابور انتظار ذكي'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondary,
        ),
      ),
    );
  }

  Widget _buildFeaturesSectionTitle() {
    return Column(
      children: [
        const Text(
          'مميزات المنصة وحلول الرقمنة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'تم هندسة منصة "طبيبي" لتغطي الاحتياجات الشاملة للعيادات والمستشفيات',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureBentoCard(
                title: 'الملف الطبي الموحد',
                desc: 'ملف رقمي موحد لكل مريض يضم الأرشيف المرضي التاريخي، الوصفات، والتحاليل.',
                emoji: '📁',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureBentoCard(
                title: 'حجز المواعيد وتأكيدها',
                desc: 'يمكن للمرضى حجز المواعيد بسهولة مع نظام إدارة المواعيد للأطباء والموظفين.',
                emoji: '📅',
                color: const Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureBentoCard(
                title: 'قائمة الانتظار الحية',
                desc: 'تسيير متطور وحي لقائمة الانتظار في العيادة ومعرفة الترتيب والوقت الفعلي.',
                emoji: '🚶',
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureBentoCard(
                title: 'الوصفات الطبية الرقمية',
                desc: 'تحرير وصياغة سريعة للوصفات الطبية مع إمكانية طباعتها فورياً بصيغة PDF.',
                emoji: '✍️',
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureBentoCard({
    required String title,
    required String desc,
    required String emoji,
    required Color color,
  }) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      enableGlow: true,
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12.5, color: AppTheme.textMain),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey.shade700, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterEmergencySection() {
    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تواصل معنا وأرقام الطوارئ',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textMain),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'هل أنت طبيب وتريد تهيئة نظام "طبيبي" لعيادتك الخاصة؟ أرسل لنا وسيرد عليك ممثلو الدعم الفني.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey.shade600, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEmergencyBadge('🚒 الحماية المدنية', '14', Colors.redAccent),
              _buildEmergencyBadge('🚑 المساعدة الطبية (SAMU)', '115', const Color(0xFF0284C7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBadge(String label, String number, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Text(number, style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
