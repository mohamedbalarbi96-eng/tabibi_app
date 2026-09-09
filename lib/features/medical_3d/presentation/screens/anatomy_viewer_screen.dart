import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Dual 3D Anatomy & Human Atlas Interactive Hub
class AnatomyViewerScreen extends StatelessWidget {
  const AnatomyViewerScreen({super.key});

  static const String anatomyUrl = 'https://anatomy-main-drab.vercel.app/en';
  static const String humanAtlasUrl = 'https://human-atlas-seven.vercel.app/?hl=fr-FR';

  Future<void> _openWebUrl(BuildContext context, String url, String title) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح الرابط: $url', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جاري فتح $title على المتصفح...', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    }
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
            Text('| المستودع والمكتبة التشريحية 3D', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: AmbientLightBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بانر ترحيبي
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.view_in_ar_rounded, color: Colors.cyanAccent, size: 28),
                        SizedBox(width: 10),
                        Text('المكتبات الطبية ثلاثية الأبعاد المعتمدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'استكشف المجسمات التشريحية الحية لجسم الإنسان، الأعضاء الداخلية، والعظام بدقة تفاعلية عالية للأطباء والمرضى.',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. بطاقة المكتبة الأولى: Anatomy 3D
              GlassBentoCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(20),
                enableGlow: true,
                glowColor: AppTheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                          child: const Text('🧬', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('المكتبة الطبية ثلاثية الأبعاد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textMain)),
                              Text('Anatomy 3D Interactive Viewer', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'استكشاف تفاعلي للأعضاء الحيوية (القلب، الدماغ، الرئتان، الكبد، الجهاز الدوري) مع إمكانية التدوير والفحص السريري.',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: Colors.grey.shade700, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white, size: 18),
                        label: const Text('فتح واستكشاف المكتبة 3D 🧬', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => _openWebUrl(context, anatomyUrl, 'المكتبة الطبية 3D'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. بطاقة المكتبة الثانية: أطلس تشريح الإنسان (Human Atlas)
              GlassBentoCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(20),
                enableGlow: true,
                glowColor: const Color(0xFF6366F1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.12), shape: BoxShape.circle),
                          child: const Text('🩻', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('تشريح الإنسان (أطلس كامل)', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textMain)),
                              Text('Human Atlas 3D Body System', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'أطلس تشريحي كامل لجسم الإنسان وطبقات العضلات والهيكل العظمي والمفاصل والأعصاب ثلاثية الأبعاد.',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: Colors.grey.shade700, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 18),
                        label: const Text('فتح أطلس تشريح الإنسان 🩻', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => _openWebUrl(context, humanAtlasUrl, 'أطلس تشريح الإنسان'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
