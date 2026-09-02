import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Modern 3D Interactive Clinical Anatomy Viewer Screen
/// Inspired by the official GitHub repository: thebuggeddev/anatomy
class Doctor3DAnatomyScreen extends StatefulWidget {
  const Doctor3DAnatomyScreen({super.key});

  @override
  State<Doctor3DAnatomyScreen> createState() => _Doctor3DAnatomyScreenState();
}

class _Doctor3DAnatomyScreenState extends State<Doctor3DAnatomyScreen> {
  int _selectedOrganIndex = 0;

  final List<Map<String, dynamic>> _anatomyOrgans = [
    {
      'name': 'القلب والشرايين التاجية (Coronary Heart)',
      'system': 'الجهاز الدوري القلبي',
      'emoji': '🫀',
      'theme_color': Colors.redAccent,
      'layers': ['الشريان الأورطي Aorta', 'البطين الأيسر Left Ventricle', 'الصمام الميترالي Mitral Valve'],
      'facts': [
        'القلب يضخ نحو 5 لترات من الدم كل دقيقة عبر شبكة شرايين بطول 100,000 كم.',
        'الشرايين التاجية (Coronary Arteries) تغذي عضلة القلب نفسها بالأكسجين.',
      ],
      'clinical_note': 'الفحص السريري: مراقبة النبض والضغط واستبعاد الذبحة الصدرية عبر تخطيط ECG.',
    },
    {
      'name': 'الرئتان والحويصلات الهوائية (Lungs & Alveoli)',
      'system': 'الجهاز التنفسي',
      'emoji': '🫁',
      'theme_color': Colors.teal,
      'layers': ['القصبة الهوائية Trachea', 'الشعب الهوائية Bronchi', 'الحويصلات Alveoli'],
      'facts': [
        'تحتوي الرئتان على مساحة سطحية لتبادل الغازات تعادل مساحة ملعب تنس كامل.',
        'نسبة تشبع الأكسجين الطبيعية SpO2 تتراوح بين 95% و 100%.',
      ],
      'clinical_note': 'الفحص السريري: التسمع بالسماعة الطبية للكشف عن الخراخر أو أزيز الربو.',
    },
    {
      'name': 'الدماغ والمخ والجهاز العصبي (Brain & Neurons)',
      'system': 'الجهاز العصبي المركزي',
      'emoji': '🧠',
      'theme_color': const Color(0xFF8B5CF6),
      'layers': ['القشرة المخية Cerebral Cortex', 'المخيخ Cerebellum', 'جذع الدماغ Brainstem'],
      'facts': [
        'يحتوي المخ على 86 مليار خلية عصبية تنقل الإشارات بسرعة تصل إلى 400 كم/س.',
      ],
      'clinical_note': 'الفحص السريري: فحص ردود الأفعال العصبية ومستوى الوعي بمقياس غلاسكو GCS.',
    },
    {
      'name': 'تشريح العين وقاع الشبكية (Eye & Retina)',
      'system': 'الحواس والأعصاب البصرية',
      'emoji': '👁️',
      'theme_color': Colors.blue,
      'layers': ['القرنية Cornea', 'القزحية Iris', 'الشبكية Retina'],
      'facts': [
        'شبكية العين هي امتداد مباشر للمخ والأنسجة العصبية البصرية.',
      ],
      'clinical_note': 'الفحص السريري: فحص قاع العين (Fundoscopy) لمراقبة تأثير ضغط الدم والسكري.',
    },
    {
      'name': 'الجهاز الهيكلي والمفاصل (Skeletal Bones)',
      'system': 'الجهاز الحركي والعظام',
      'emoji': '🦴',
      'theme_color': Colors.amber.shade800,
      'layers': ['العمود الفقري Spine', 'مفصل الركبة Knee Joint', 'عظم الفخذ Femur'],
      'facts': [
        'يتكون الهيكل العظمي للبالغين من 206 عظمة تحمي الأعضاء وتنتج خلايا الدم.',
      ],
      'clinical_note': 'الفحص السريري: تقييم مدى الحركة والمفاصل وطلب صور الأشعة السينية X-Ray.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final organ = _anatomyOrgans[_selectedOrganIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| المستودع التشريحي 3D', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: AmbientLightBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. شريط اختيار الأعضاء الأفقي
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _anatomyOrgans.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final isSel = _selectedOrganIndex == i;
                    return ChoiceChip(
                      label: Row(
                        children: [
                          Text(_anatomyOrgans[i]['emoji'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            _anatomyOrgans[i]['name'].toString().split(' (')[0],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : AppTheme.textMain,
                            ),
                          ),
                        ],
                      ),
                      selected: isSel,
                      selectedColor: AppTheme.primary,
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => _selectedOrganIndex = i),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 2. مجسم العرض التشريحي ثلاثي الأبعاد (Interactive 3D Stage)
              GlassBentoCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(22),
                enableGlow: true,
                glowColor: organ['theme_color'] as Color,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: (organ['theme_color'] as Color).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (organ['theme_color'] as Color).withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(organ['emoji'], style: const TextStyle(fontSize: 60)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      organ['name'],
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textMain),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      organ['system'],
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: organ['theme_color'] as Color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. الطبقات التشريحية المستهدفة
              _buildSectionHeader('🧬 الطبقات والأنسجة التشريحية الرئيسية'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (organ['layers'] as List).map<Widget>((layer) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text('📍 $layer', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // 4. الحقائق العلمية والفسيولوجية
              _buildSectionHeader('🔬 الحقائق الطبية والفسيولوجية'),
              const SizedBox(height: 8),
              ...(organ['facts'] as List).map((fact) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassBentoCard(
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔹', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(fact, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, height: 1.4, color: AppTheme.textMain, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 14),

              // 5. الملاحظة السريرية الموجهة للطبيب
              _buildSectionHeader('🩺 الملاحظة السريرية واستراتيجية الفحص'),
              const SizedBox(height: 8),
              GlassBentoCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_outlined, color: AppTheme.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        organ['clinical_note'],
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppTheme.primary, fontWeight: FontWeight.w800, height: 1.45),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }
}
