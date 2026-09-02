import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Doctor Unified Patient Clinical History & Vitals Screen
/// Matched 100% with the official 4-tabs Clinical Record screenshots
class DoctorPatientRecordScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const DoctorPatientRecordScreen({super.key, this.patientData});

  @override
  State<DoctorPatientRecordScreen> createState() => _DoctorPatientRecordScreenState();
}

class _DoctorPatientRecordScreenState extends State<DoctorPatientRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // حقول تدوين العلامات الحيوية الفورية
  final _weightCtrl = TextEditingController(text: '70');
  final _heightCtrl = TextEditingController(text: '175');
  final _tempCtrl = TextEditingController(text: '37');
  final _bpSysCtrl = TextEditingController(text: '120');
  final _bpDiaCtrl = TextEditingController(text: '80');
  final _pulseCtrl = TextEditingController(text: '75');
  final _oxygenCtrl = TextEditingController(text: '98');

  // حقول رفع الأشعة والتقارير
  final _scanTitleCtrl = TextEditingController();

  // سجل العلامات الحيوية التاريخي المطابق للصورة
  final List<Map<String, dynamic>> _vitalsHistory = [
    {
      'date': '2026-08-04',
      'weight_height': '33.00 كلغ / 66.00 سم',
      'temp': '66.00 م°',
      'bp': '-',
      'pulse': '99 ن/د',
      'oxygen': '233.00 %',
    },
  ];

  // سجل المرفقات والأشعة
  final List<Map<String, dynamic>> _attachments = [
    {
      'title': 'أشعة صدر',
      'doctor': 'د. محمد جعفري',
      'date': '2026-08-05',
      'size': '1,483.59 KB',
    },
  ];

  // سجل الوصفات الرقمية المطابقة للصورة
  final List<Map<String, dynamic>> _prescriptions = [
    {
      'rx_code': 'RX-2026-43116',
      'doctor': 'د. محمد جعفري',
      'date': '2026-08-10',
      'drug': 'Doliprane (Tablet)',
      'dosage': '1 قرص قبل الأكل ثلاث مرات في اليوم',
      'duration': '15 يوم',
      'quantity': '2 علبة',
    },
    {
      'rx_code': 'RX-2026-41475',
      'doctor': 'د. محمد جعفري',
      'date': '2026-08-03',
      'drug': 'Amoxicillin 500mg',
      'dosage': '1 كبسولة مرتين يومياً',
      'duration': '7 أيام',
      'quantity': '1 علبة',
    },
  ];

  // سجل الزيارات المطابق للصورة
  final List<Map<String, dynamic>> _visits = [
    {
      'date': '2026-09-01',
      'doctor': 'د. محمد بلعربي (أمراض القلب والشرايين)',
      'notes': 'زيارة مراجعة سريعة وصرف علاج مباشر للمريض.',
      'recommendations': 'متابعة أخذ العلاج حسب التوجيهات الطبية.',
    },
    {
      'date': '2026-08-04',
      'doctor': 'د. محمد جعفري (طب وجراحة العيون)',
      'notes': 'زيارة مراجعة سريعة وصرف علاج مباشر للمريض.',
      'recommendations': 'متابعة أخذ العلاج حسب التوجيهات الطبية.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _tempCtrl.dispose();
    _bpSysCtrl.dispose();
    _bpDiaCtrl.dispose();
    _pulseCtrl.dispose();
    _oxygenCtrl.dispose();
    _scanTitleCtrl.dispose();
    super.dispose();
  }

  void _recordVitals() {
    setState(() {
      _vitalsHistory.insert(0, {
        'date': '2026-09-01',
        'weight_height': '${_weightCtrl.text} كلغ / ${_heightCtrl.text} سم',
        'temp': '${_tempCtrl.text} م°',
        'bp': '${_bpSysCtrl.text}/${_bpDiaCtrl.text}',
        'pulse': '${_pulseCtrl.text} ن/د',
        'oxygen': '${_oxygenCtrl.text} %',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل وحفظ القياسات الحيوية للمريض فوراً! 💉', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _uploadScan() {
    if (_scanTitleCtrl.text.trim().isEmpty) return;
    setState(() {
      _attachments.insert(0, {
        'title': _scanTitleCtrl.text.trim(),
        'doctor': 'د. الطبيب المعالج',
        'date': '2026-09-01',
        'size': '2,145.20 KB',
      });
      _scanTitleCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم رفع وإرسال صورة الأشعة إلى ملف المريض بنجاح! 🩻', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patientData ?? {
      'name': 'بلعربي الهادي',
      'mrn': 'MR-2026-00002',
      'age': '0 سنة',
      'dob': '2026-08-04',
      'gender': 'ذكر',
      'blood_group': '+AB',
      'phone': '0673906336',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| السجل السريري للمريض', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              // 1. بطاقة الهوية والبيانات الحيوية (أعلى الشاشة)
              _buildPatientHeroCard(patient, context),
              const SizedBox(height: 18),

              // 2. عنوان السجل التاريخي السريري الموحد والتبويبات
              Row(
                children: [
                  Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  const Text('📁 السجل التاريخي السريري الموحد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textMain)),
                ],
              ),
              const SizedBox(height: 10),

              // شريط التبويبات الأربعة
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 11.5),
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: '🩺 سجل الزيارات (${_visits.length})'),
                    Tab(text: '✍️ الوصفات الرقمية (${_prescriptions.length})'),
                    Tab(text: '📊 العلامات الحيوية (${_vitalsHistory.length})'),
                    Tab(text: '🩻 الأشعة والتحاليل (${_attachments.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // محتوى التبويبات
              SizedBox(
                height: 520,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVisitsTab(),
                    _buildPrescriptionsTab(context),
                    _buildVitalsTab(),
                    _buildScansTab(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeroCard(Map<String, dynamic> patient, BuildContext context) {
    return GlassBentoCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      enableGlow: true,
      glowColor: AppTheme.primary,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.badge_rounded, color: AppTheme.primary, size: 22),
                  SizedBox(width: 6),
                  Text('الهوية والبيانات الحيوية 👤', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                child: Text('🩸 فصيلة: ${patient['blood_group']}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2E7D32))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(patient['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textMain)),
          Text('📁 ${patient['mrn']}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF047857))),
          const SizedBox(height: 12),

          // زر تحرير وصفة سريعة للمريض
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 18),
              label: const Text('تحرير وصفة سريعة للمريض ✍️', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => context.push('/doctor-prescription-view', extra: {
                'rx_code': 'RX-2026-43116',
                'patient_name': patient['name'],
                'mrn': patient['mrn'],
                'blood_group': patient['blood_group'],
                'dob': patient['dob'],
              }),
            ),
          ),
          const Divider(height: 20),

          // تفاصيل السن، الهاتف، الحساسيات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('السن (العمر): ${patient['age'] ?? '0 سنة'}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
              Text('تاريخ الميلاد: ${patient['dob']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
              Text('الجنس: ${patient['gender']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الهاتف: ${patient['phone']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              const Text('الحساسيات: لا يوجد مسجلة', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    return ListView.separated(
      itemCount: _visits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final v = _visits[i];
        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(v['doctor'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.primary)),
                  Text(v['date'], style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              Text('ملاحظات ونتائج الفحص: ${v['notes']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppTheme.textMain, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('توصيات الطبيب: ${v['recommendations']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsTab(BuildContext context) {
    return ListView.separated(
      itemCount: _prescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final rx = _prescriptions[i];
        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('كود الوصفة: ${rx['rx_code']}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primary)),
                  Text(rx['date'], style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Text('بواسطة: ${rx['doctor']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Text('💊 ${rx['drug']} - ${rx['dosage']}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11.5)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.white),
                    label: const Text('استعراض وتحميل PDF 🖨️', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => context.push('/doctor-prescription-view', extra: rx),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVitalsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // نموذج تسجيل وقياس العلامات الحيوية الفورية
          GlassBentoCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('💉 تسجيل وقياس العلامات الحيوية الفورية للمريض', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _weightCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'الوزن (كلغ)'))),
                    const SizedBox(width: 6),
                    Expanded(child: TextField(controller: _heightCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'الطول (سم)'))),
                    const SizedBox(width: 6),
                    Expanded(child: TextField(controller: _tempCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'الحرارة (م°)'))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _bpSysCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'انقباضي'))),
                    const SizedBox(width: 6),
                    Expanded(child: TextField(controller: _bpDiaCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'انبساطي'))),
                    const SizedBox(width: 6),
                    Expanded(child: TextField(controller: _pulseCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'النبض'))),
                    const SizedBox(width: 6),
                    Expanded(child: TextField(controller: _oxygenCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'الأكسجين SpO2'))),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    label: const Text('تسجيل وحفظ القياسات الحيوية فوراً 💉', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: _recordVitals,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // جدول السجلات السابقة
          ...List.generate(_vitalsHistory.length, (i) {
            final item = _vitalsHistory[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassBentoCard(
                borderRadius: 14,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('📅 ${item['date']}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11)),
                        Text('🌡️ ${item['temp']}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('⚖️ ${item['weight_height']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey)),
                        Text('💓 ${item['pulse']} | 🫁 ${item['oxygen']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScansTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // نموذج رفع الأشعة والتحاليل
          GlassBentoCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('🩻 رفع وإرسال صورة أشعة راديو أو تحاليل طبية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.secondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _scanTitleCtrl,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  decoration: const InputDecoration(labelText: 'اسم الملف أو التقرير *', hintText: 'مثال: أشعة الصدر، تحاليل السكري...'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload_rounded, size: 16, color: Colors.white),
                    label: const Text('رفع وإرسال الملف للمريض فوراً 💉', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: _uploadScan,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // قائمة الأشعة المرفوعة
          ...List.generate(_attachments.length, (i) {
            final att = _attachments[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassBentoCard(
                borderRadius: 14,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(att['title'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.textMain)),
                          Text('${att['doctor']} • ${att['size']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: AppTheme.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('جاري تنزيل ${att['title']}...', style: const TextStyle(fontFamily: 'Cairo'))),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
