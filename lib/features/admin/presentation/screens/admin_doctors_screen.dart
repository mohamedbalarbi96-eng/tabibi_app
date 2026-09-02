import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Admin Doctor Management, Subscriptions, Revenues & Maps Screen
/// Matched 100% with the official live Doctor Management screenshots (Images 6 & 8)
class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  // بيانات الأطباء المطابقة للصورة رقم 6
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 1,
      'name': 'د. فلسطيني صحي',
      'email': 'falastini29@gmail.com',
      'specialty': 'طب عام',
      'license': '46254787945',
      'fee': '2,000.00',
      'has_map': true,
      'status': 'حساب نشط (مشترك)',
      'is_active': true,
      'patients_treated': 0,
      'visits_count': 0,
      'revenue': '0.00',
    },
    {
      'id': 2,
      'name': 'د. محمد بلعربي',
      'email': 'mohai55@gmail.com',
      'specialty': 'أمراض القلب والشرايين',
      'license': 'kigfufuf7',
      'fee': '2,000.00',
      'has_map': true,
      'status': 'حساب نشط (مشترك)',
      'is_active': true,
      'patients_treated': 1,
      'visits_count': 1,
      'revenue': '0.00',
    },
    {
      'id': 3,
      'name': 'د. محمد جعفري',
      'email': 'moha0@gmail.com',
      'specialty': 'طب وجراحة العيون',
      'license': '68674683',
      'fee': '2,000.00',
      'has_map': false,
      'status': 'حساب نشط (مشترك)',
      'is_active': true,
      'patients_treated': 2,
      'visits_count': 2,
      'revenue': '33,000.00',
    },
  ];

  void _toggleDoctorStatus(int index) {
    setState(() {
      _doctors[index]['is_active'] = !(_doctors[index]['is_active'] == true);
    });
    final doc = _doctors[index];
    final bool active = doc['is_active'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          active ? 'تم تفعيل حساب ${doc['name']} بنجاح' : 'تم تعطيل حساب ${doc['name']}',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: active ? AppTheme.primary : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openAddDoctorDialog() {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: '2000');
    final experienceCtrl = TextEditingController(text: '10');
    final mapUrlCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: '35.697');
    final lngCtrl = TextEditingController(text: '-0.633');

    String specialty = 'طب عام';
    String clinic = 'عيادة طبيبي الخاصة الموحدة';
    String gender = 'male';
    String immediateStatus = 'متاح فوراً للاستقبال وحجز المواعيد';
    bool showPhonePublicly = true;

    final List<String> specialtyOptions = [
      'طب عام',
      'أمراض القلب والشرايين',
      'طب وجراحة العيون',
      'طب الأطفال وحديثي الولادة',
      'جراحة العظام والمفاصل',
      'أمراض النساء والتوليد',
      'طب وجراحة الأسنان',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // هيدر النافذة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'إضافة طبيب جديد وإنشاء ملفه المهني',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(height: 18),

                // أولاً: بيانات الحساب والولوج
                _buildFormSectionBadge('👤 أولاً: بيانات الحساب والولوج'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameCtrl,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'الاسم الأول *', hintText: 'محمد'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lastNameCtrl,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'اللقب (العائلة) *', hintText: 'بن عيسى'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'البريد الإلكتروني المهني *', hintText: 'dr.benaissa@tabibi.dz'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'رقم الهاتف الطبي', hintText: '0550123456'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passwordCtrl,
                        obscureText: true,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'كلمة مرور الحساب *', hintText: 'حد أدنى 8 خانات'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender,
                        decoration: const InputDecoration(labelText: 'الجنس *'),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('ذكر', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                          DropdownMenuItem(value: 'female', child: Text('أنثى', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                        ],
                        onChanged: (v) => setModalState(() => gender = v ?? 'male'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ثانياً: بيانات الاعتماد والترخيص الطبي
                _buildFormSectionBadge('⚕️ ثانياً: بيانات الاعتماد والترخيص الطبي'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: specialty,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'التخصص الطبي المعياري *'),
                  items: specialtyOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12))))
                      .toList(),
                  onChanged: (v) => setModalState(() => specialty = v ?? specialtyOptions[0]),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: licenseCtrl,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'رقم الترخيص المهني *', hintText: 'MS-16-00045'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: feeCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'تسعيرة الكشف (د.ج) *', hintText: '2000'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: experienceCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'سنوات الخبرة', hintText: '10'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: immediateStatus,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'حالة استقبال المرضى'),
                        items: const [
                          DropdownMenuItem(value: 'متاح فوراً للاستقبال وحجز المواعيد', child: Text('متاح فوراً', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                          DropdownMenuItem(value: 'غير متاح حالياً', child: Text('غير متاح حالياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                        ],
                        onChanged: (v) => setModalState(() => immediateStatus = v ?? immediateStatus),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ثالثاً: الموقع الجغرافي والخرائط
                _buildFormSectionBadge('🗺️ ثالثاً: الموقع الجغرافي للعيادة والخصوصية (اختياري)'),
                const SizedBox(height: 10),
                TextField(
                  controller: mapUrlCtrl,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  decoration: const InputDecoration(labelText: 'رابط خرائط جوجل (Google Maps Link)', hintText: 'https://maps.google.com/...'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        decoration: const InputDecoration(labelText: 'خط العرض (Latitude)', hintText: '35.697'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lngCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        decoration: const InputDecoration(labelText: 'خط الطول (Longitude)', hintText: '-0.633'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // زر الحفظ النهائي
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: const Text('تأكيد وحفظ ملف الطبيب بصفة رسمية 💾', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    onPressed: () {
                      if (firstNameCtrl.text.trim().isEmpty || lastNameCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _doctors.insert(0, {
                          'id': _doctors.length + 1,
                          'name': 'د. ${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}',
                          'email': emailCtrl.text.trim().isEmpty ? 'doctor@tabibi.dz' : emailCtrl.text.trim(),
                          'specialty': specialty,
                          'license': licenseCtrl.text.trim().isEmpty ? 'MS-NEW' : licenseCtrl.text.trim(),
                          'fee': feeCtrl.text.trim().isEmpty ? '2,000.00' : feeCtrl.text.trim(),
                          'has_map': true,
                          'status': 'حساب نشط (مشترك)',
                          'is_active': true,
                          'patients_treated': 0,
                          'visits_count': 0,
                          'revenue': '0.00',
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم اعتماد وإضافة ملف الطبيب بنجاح في المنظومة!', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            Text('| الطاقم الطبي والاشتراكات', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة طبيب جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white)),
        onPressed: _openAddDoctorDialog,
      ),
      body: AmbientLightBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // هيدر إحصائي
              _buildHeaderSection(),
              const SizedBox(height: 16),

              // بطاقات الأطباء الثلاثة المطابقة للصورة 6
              ...List.generate(_doctors.length, (i) => _buildDoctorDetailedCard(_doctors[i], i)),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF047857)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFF065F46).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطاقم الطبي وضبط الاشتراكات والإيرادات والخرائط ⚕️',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white),
                ),
                Text(
                  'مراقبة عيادات الأطباء الخواص، المداخيل المحصلة، وحالة التفعيل.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDetailedCard(Map<String, dynamic> doc, int index) {
    final bool isActive = doc['is_active'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassBentoCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        enableGlow: isActive,
        glowColor: AppTheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السطر 1: الطبيب والبريد والشارة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                      child: const Text('👨‍⚕️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textMain)),
                        Text(doc['email'], style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(doc['status'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                ),
              ],
            ),
            const Divider(height: 18),

            // السطر 2: التخصص والترخيص وسعر الكشف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc['specialty'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary)),
                    Text('رقم الترخيص: ${doc['license']}', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Colors.grey.shade700)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${doc['fee']} د.ج', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF059669))),
                    if (doc['has_map'] == true)
                      const Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                          Text('الخريطة مبرمجة 📍', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // السطر 3: إحصائيات العلاج والمدخول المالي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('👤 ${doc['patients_treated']} مريض معالج  •  🩺 ${doc['visits_count']} فحص', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                  Text('🪙 المدخول: ${doc['revenue']} د.ج', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // زر التعطيل / التفعيل
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _toggleDoctorStatus(index),
                  child: Text(isActive ? 'تعطيل الحساب 🔴' : 'تفعيل الحساب 🟢', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSectionBadge(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.primary)),
    );
  }
}
