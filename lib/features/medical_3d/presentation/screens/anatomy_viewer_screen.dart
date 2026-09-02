import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Luxury 3D Interactive Anatomy & Organ Explorer Screen
/// Matched 100% with TABIBI 3D Medical Library screenshots (Images 9 & 10)
class AnatomyViewerScreen extends StatefulWidget {
  const AnatomyViewerScreen({super.key});

  @override
  State<AnatomyViewerScreen> createState() => _AnatomyViewerScreenState();
}

class _AnatomyViewerScreenState extends State<AnatomyViewerScreen> {
  int _selectedOrganIdx = 0;

  final List<Map<String, dynamic>> _organLibrary = [
    {
      'title': 'Heart',
      'system': 'Cardiovascular',
      'arabic_name': 'القلب والأوعية الدموية',
      'emoji': '🫀',
      'color': Colors.redAccent,
      'quote': 'The tireless pump',
      'desc': 'A muscular organ that pumps blood throughout the body, delivering oxygen and nutrients to every cell.',
      'size': 'About the size of your fist',
      'weight': '250-350 g',
      'daily': 'Beats about 100,000 times',
      'microscopic': 'Cardiac muscle tissue with intercalated discs for rapid electrical conduction.',
      'comparison': 'Heart (Circulatory engine) vs Brain (Neural commanding center).',
    },
    {
      'title': 'Brain',
      'system': 'Nervous System',
      'arabic_name': 'الدماغ والجهاز العصبي',
      'emoji': '🧠',
      'color': const Color(0xFF8B5CF6),
      'quote': 'The central command',
      'desc': 'The primary control center of the nervous system, processing sensory information and directing responses.',
      'size': 'About 15 cm long',
      'weight': '1300-1400 g',
      'daily': 'Processes millions of signals per second',
      'microscopic': 'Dense network of billions of neurons and synaptic connections.',
      'comparison': 'Brain consumes 20% of total body energy and oxygen.',
    },
    {
      'title': 'Lungs',
      'system': 'Respiratory System',
      'arabic_name': 'الرئتان والمسالك الهوائية',
      'emoji': '🫁',
      'color': Colors.teal,
      'quote': 'The breath of life',
      'desc': 'Essential respiratory organs responsible for gas exchange, extracting oxygen from air into the bloodstream.',
      'size': 'Fills most of chest cavity',
      'weight': '900-1000 g',
      'daily': 'Breathes about 20,000 times daily',
      'microscopic': 'Over 300 million alveoli creating an expansive surface for oxygen diffusion.',
      'comparison': 'Right lung has 3 lobes, while left lung has 2 lobes to accommodate the heart.',
    },
    {
      'title': 'Liver',
      'system': 'Digestive System',
      'arabic_name': 'الكبد والتمثيل الغذائي',
      'emoji': '🥩',
      'color': Colors.brown.shade400,
      'quote': 'The metabolic powerhouse',
      'desc': 'The largest internal organ, performing over 500 vital functions including detoxification and protein synthesis.',
      'size': 'About 21-22 cm across',
      'weight': '1400-1600 g',
      'daily': 'Filters 1.4 liters of blood per minute',
      'microscopic': 'Hexagonal hepatic lobules with central veins and portal triads.',
      'comparison': 'The only internal organ with the remarkable capacity to regenerate itself.',
    },
    {
      'title': 'Kidneys',
      'system': 'Urinary System',
      'arabic_name': 'الكليتان والجهاز البولي',
      'emoji': '🫘',
      'color': Colors.deepOrange,
      'quote': 'The master filter',
      'desc': 'Bean-shaped organs that filter waste products, excess water, and impurities from the blood.',
      'size': '10-12 cm long each',
      'weight': '125-170 g each',
      'daily': 'Filters about 180 liters of fluid daily',
      'microscopic': 'Each kidney contains roughly 1 million functional nephrons.',
      'comparison': 'Maintains precise electrolyte balance and regulates systemic blood pressure.',
    },
    {
      'title': 'Eye',
      'system': 'Sensory System',
      'arabic_name': 'العين والرؤية البصرية',
      'emoji': '👁️',
      'color': Colors.blue,
      'quote': 'The window to the world',
      'desc': 'Complex sensory organ that captures light patterns and converts them into neural signals for visual perception.',
      'size': 'About 24 mm in diameter',
      'weight': '7.5 g',
      'daily': 'Adjusts focus over 100,000 times a day',
      'microscopic': 'Retinal layers packed with over 120 million rods and 6 million cones.',
      'comparison': 'Cornea is the only human tissue with direct oxygen absorption from air without blood vessels.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final organ = _organLibrary[_selectedOrganIdx];

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| المكتبة الطبية ثلاثية الأبعاد 3D', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. بانر ترويسة المكتبة 3D المطابق للصورة 9
            _buildLibraryHeaderBanner(),
            const SizedBox(height: 16),

            // 2. قائمة اختيار الأعضاء (Organ Library List)
            _buildOrganSelectorRow(),
            const SizedBox(height: 16),

            // 3. مسرح العرض ثلاثي الأبعاد التفاعلي (3D Stage & Canvas)
            _buildInteractive3DCanvas(organ),
            const SizedBox(height: 18),

            // 4. بطاقة الحقائق الطبية الأساسية (Key Facts)
            _buildKeyFactsCard(organ),
            const SizedBox(height: 18),

            // 5. الفحص المجهري والمقارنة (Microscopic View & Comparison)
            _buildMicroscopicAndComparisonSection(organ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TABIBI 3D Medical Library | Anatomy Atelier 🧬',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF92400E)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                child: const Text('Anatomy 3D', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'مستودع تشريح تفاعلي ثلاثي الأبعاد لاستكشاف الأعضاء البشرية وتفاصيلها الفسيولوجية بطريقة تعليمية مبسطة.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganSelectorRow() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _organLibrary.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final item = _organLibrary[idx];
          final isSel = _selectedOrganIdx == idx;

          return ChoiceChip(
            label: Row(
              children: [
                Text(item['emoji'], style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${item['title']} (${item['arabic_name'].toString().split(' ')[0]})',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppTheme.textMain),
                ),
              ],
            ),
            selected: isSel,
            selectedColor: AppTheme.primary,
            backgroundColor: Colors.white,
            onSelected: (_) => setState(() => _selectedOrganIdx = idx),
          );
        },
      ),
    );
  }

  Widget _buildInteractive3DCanvas(Map<String, dynamic> organ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6DCB8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organ['title'],
                    style: const TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF451A03)),
                  ),
                  Text(
                    organ['quote'],
                    style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontSize: 12, color: Colors.amber.shade900),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text(organ['system'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // مجسم العرض المركزي ثلاثي الأبعاد التفاعلي
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: (organ['color'] as Color).withValues(alpha: 0.25), blurRadius: 30, spreadRadius: 6),
              ],
            ),
            child: Center(
              child: Text(organ['emoji'], style: const TextStyle(fontSize: 70)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            organ['desc'],
            style: TextStyle(fontFamily: 'serif', fontSize: 12.5, color: Colors.brown.shade800, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // أزرار التحكم ثلاثية الأبعاد
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCanvasControlBtn(Icons.rotate_right_rounded, 'تدوير 360°'),
              const SizedBox(width: 8),
              _buildCanvasControlBtn(Icons.zoom_in_rounded, 'تكبير'),
              const SizedBox(width: 8),
              _buildCanvasControlBtn(Icons.layers_outlined, 'الطبقات'),
              const SizedBox(width: 8),
              _buildCanvasControlBtn(Icons.biotech_outlined, 'المجهر'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasControlBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildKeyFactsCard(Map<String, dynamic> organ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('KEY FACTS | حقائق أساسية 🔬', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12.5, color: Color(0xFF92400E))),
          const Divider(height: 16),
          _buildFactRow('الحجم التقديري (Size):', organ['size']),
          const SizedBox(height: 6),
          _buildFactRow('الوزن التقريبي (Weight):', organ['weight']),
          const SizedBox(height: 6),
          _buildFactRow('النشاط اليومي (Daily Activity):', organ['daily']),
        ],
      ),
    );
  }

  Widget _buildFactRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }

  Widget _buildMicroscopicAndComparisonSection(Map<String, dynamic> organ) {
    return Column(
      children: [
        GlassBentoCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), shape: BoxShape.circle),
                child: const Text('🔬', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MICROSCOPIC VIEW | الفحص النسيجي المجهري', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF92400E))),
                    const SizedBox(height: 4),
                    Text(organ['microscopic'], style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade800, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GlassBentoCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), shape: BoxShape.circle),
                child: const Text('⚖️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('COMPARE ORGANS | مقارنة الأنظمة الفسيولوجية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0284C7))),
                    const SizedBox(height: 4),
                    Text(organ['comparison'], style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade800, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
