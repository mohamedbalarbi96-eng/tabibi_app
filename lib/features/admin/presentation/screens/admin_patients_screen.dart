import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Admin Unified Medical Records & Patient Repository Screen
/// Matched 100% with the official Patient Repository screenshots (Images 5 & 8)
class AdminPatientsScreen extends StatefulWidget {
  const AdminPatientsScreen({super.key});

  @override
  State<AdminPatientsScreen> createState() => _AdminPatientsScreenState();
}

class _AdminPatientsScreenState extends State<AdminPatientsScreen> {
  String _searchQuery = '';

  // قائمة المرضى الحقيقية المطابقة للصورة رقم 5
  final List<Map<String, dynamic>> _patients = [
    {
      'id': 1,
      'name': 'Nanova Center',
      'first_name': 'Nanova',
      'last_name': 'Center',
      'mrn': 'MR-2026-00022',
      'phone': '0777736584',
      'email': 'nanovacenter@gmail.com',
      'dob': '1997-08-31',
      'gender': 'ذكر',
      'blood_group': 'غير معروفة',
      'is_active': true,
      'nin': '199712345678901234',
      'emergency_contact': 'الأخ الأكبر',
      'emergency_phone': '0550112233',
      'allergies': 'حساسية البنسلين والمضادات الحيوية',
      'chronic': 'دون أمراض مزمنة',
    },
    {
      'id': 2,
      'name': 'Youcef Nechadi',
      'first_name': 'Youcef',
      'last_name': 'Nechadi',
      'mrn': 'MR-2026-00020',
      'phone': '0770123456',
      'email': 'nechadiyoucef25@gmail.com',
      'dob': '1998-05-15',
      'gender': 'ذكر',
      'blood_group': 'A+',
      'is_active': true,
      'nin': '199888776655443322',
      'emergency_contact': 'الوالد',
      'emergency_phone': '0661223344',
      'allergies': 'لا توجد',
      'chronic': 'ارتفاع ضغط الدم الخفيف',
    },
    {
      'id': 3,
      'name': 'فلسطيني صحي',
      'first_name': 'فلسطيني',
      'last_name': 'صحي',
      'mrn': 'MR-2026-00019',
      'phone': '0545564476',
      'email': 'filstini29@gmail.com',
      'dob': '2000-04-06',
      'gender': 'ذكر',
      'blood_group': 'AB+',
      'is_active': true,
      'nin': '200011223344556677',
      'emergency_contact': 'الزوجة',
      'emergency_phone': '0540001122',
      'allergies': 'حساسية الغلوتين',
      'chronic': 'داء السكري من النوع الثاني',
    },
    {
      'id': 4,
      'name': 'امال حامل',
      'first_name': 'امال',
      'last_name': 'حامل',
      'mrn': 'MR-2026-00018',
      'phone': '0559132030',
      'email': 'amalh4417@gmail.com',
      'dob': '2006-03-31',
      'gender': 'أنثى',
      'blood_group': 'O+',
      'is_active': true,
      'nin': '',
      'emergency_contact': 'الوالدة',
      'emergency_phone': '0559000000',
      'allergies': 'لا توجد',
      'chronic': 'متابعة الحمل والولادة',
    },
    {
      'id': 5,
      'name': 'Sidahmed Chafi',
      'first_name': 'Sidahmed',
      'last_name': 'Chafi',
      'mrn': 'MR-2026-00016',
      'phone': '0772045055',
      'email': 'chafisidahmed3@gmail.com',
      'dob': '1983-05-03',
      'gender': 'ذكر',
      'blood_group': 'A+',
      'is_active': true,
      'nin': '198355443322110099',
      'emergency_contact': 'الزوجة',
      'emergency_phone': '0770000000',
      'allergies': 'حساسية الأسبرين',
      'chronic': 'دون أمراض مزمنة',
    },
    {
      'id': 6,
      'name': 'محمد بلعربي',
      'first_name': 'محمد',
      'last_name': 'بلعربي',
      'mrn': 'MR-2026-00014',
      'phone': '0673906359',
      'email': 'tabibi.dz@0673906359',
      'dob': '1990-08-10',
      'gender': 'ذكر',
      'blood_group': 'غير معروفة',
      'is_active': true,
      'nin': '',
      'emergency_contact': 'الأخ',
      'emergency_phone': '0673000000',
      'allergies': 'لا توجد',
      'chronic': 'دون أمراض مزمنة',
    },
  ];

  void _togglePatientStatus(int index) {
    setState(() {
      _patients[index]['is_active'] = !(_patients[index]['is_active'] == true);
    });
    final p = _patients[index];
    final bool active = p['is_active'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          active ? 'تم تفعيل حساب ${p['name']} واستعادة صلاحياته' : 'تم تجميد وتعطيل حساب ${p['name']}',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: active ? AppTheme.primary : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openEditPatientModal(Map<String, dynamic> p, int index) {
    final firstNameCtrl = TextEditingController(text: p['first_name']);
    final lastNameCtrl = TextEditingController(text: p['last_name']);
    final phoneCtrl = TextEditingController(text: p['phone']);
    final ninCtrl = TextEditingController(text: p['nin'] ?? '');
    final emergencyNameCtrl = TextEditingController(text: p['emergency_contact'] ?? '');
    final emergencyPhoneCtrl = TextEditingController(text: p['emergency_phone'] ?? '');
    final allergiesCtrl = TextEditingController(text: p['allergies'] ?? '');
    final chronicCtrl = TextEditingController(text: p['chronic'] ?? '');

    String gender = p['gender'] ?? 'ذكر';
    String bloodGroup = p['blood_group'] ?? 'غير معروفة';

    final List<String> bloodOptions = [
      'غير معروفة',
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
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
                    Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, color: AppTheme.secondary, size: 26),
                        const SizedBox(width: 8),
                        Text(
                          'تعديل وتدقيق الملف الطبي: ${p['mrn']}',
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(height: 18),

                // أولاً: البيانات الديمغرافية والحساب (الصورة 8)
                _buildModalSectionHeader('👤 أولاً: البيانات الديمغرافية والحساب'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('رقم السجل الطبي (غير قابل للتعديل)', style: TextStyle(fontFamily: 'Cairo', fontSize: 9.5, color: Colors.grey)),
                            Text(p['mrn'], style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.secondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('البريد الإلكتروني (غير قابل للتعديل)', style: TextStyle(fontFamily: 'Cairo', fontSize: 9.5, color: Colors.grey)),
                            Text(p['email'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.secondary), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameCtrl,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'الاسم الأول *'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lastNameCtrl,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'اللقب (العائلة) *'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        decoration: const InputDecoration(labelText: 'رقم الهاتف للاتصال'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender,
                        decoration: const InputDecoration(labelText: 'الجنس *'),
                        items: const [
                          DropdownMenuItem(value: 'ذكر', child: Text('ذكر', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                          DropdownMenuItem(value: 'أنثى', child: Text('أنثى', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                        ],
                        onChanged: (v) => setModalState(() => gender = v ?? 'ذكر'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ثانياً: القياسات والمؤشرات والملف السريري (الصورة 8)
                _buildModalSectionHeader('🩺 ثانياً: القياسات والمؤشرات والملف السريري'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ninCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        decoration: const InputDecoration(labelText: 'رقم التعريف الوطني (NIN)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: bloodGroup,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'فصيلة الدم'),
                        items: bloodOptions
                            .map((bg) => DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setModalState(() => bloodGroup = v ?? 'غير معروفة'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emergencyNameCtrl,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                        decoration: const InputDecoration(labelText: 'جهة اتصال الطوارئ (القرابة)', hintText: 'اسم ولي الأمر أو الزوج'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: emergencyPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                        decoration: const InputDecoration(labelText: 'هاتف اتصال الطوارئ'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: allergiesCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'الحساسيات المكتشفة وتفاعل الأدوية',
                    hintText: 'دون الحساسيات (مثل: البنسلين، أطعمة محددة...)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: chronicCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'الأمراض المزمنة الحالية والجرعات الطويلة',
                    hintText: 'دون الأمراض المزمنة (مثل: الضغط الدموي، داء السكري...)',
                  ),
                ),
                const SizedBox(height: 20),

                // زر تحديث بيانات وحفظ ملف المريض
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: const Text('تحديث بيانات وحفظ ملف المريض بصفة رسمية 💾', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    onPressed: () {
                      setState(() {
                        _patients[index]['first_name'] = firstNameCtrl.text.trim();
                        _patients[index]['last_name'] = lastNameCtrl.text.trim();
                        _patients[index]['name'] = '${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}';
                        _patients[index]['phone'] = phoneCtrl.text.trim();
                        _patients[index]['gender'] = gender;
                        _patients[index]['blood_group'] = bloodGroup;
                        _patients[index]['nin'] = ninCtrl.text.trim();
                        _patients[index]['emergency_contact'] = emergencyNameCtrl.text.trim();
                        _patients[index]['emergency_phone'] = emergencyPhoneCtrl.text.trim();
                        _patients[index]['allergies'] = allergiesCtrl.text.trim();
                        _patients[index]['chronic'] = chronicCtrl.text.trim();
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم تدقيق وتحديث الملف الطبي للمريض ${p['mrn']} بنجاح!', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
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
    final filtered = _patients.where((p) {
      final q = _searchQuery.toLowerCase();
      final name = p['name'].toString().toLowerCase();
      final mrn = p['mrn'].toString().toLowerCase();
      final phone = p['phone'].toString().toLowerCase();
      return name.contains(q) || mrn.contains(q) || phone.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| المستودع العام للمرضى', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              // هيدر تعريفي
              _buildHeaderCard(),
              const SizedBox(height: 14),

              // شريط البحث
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم، برقم السجل الطبي MRN، أو برقم الهاتف...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.secondary),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // قائمة بطاقات المرضى المطابقة للصورة 5
              ...List.generate(filtered.length, (i) => _buildPatientRowCard(filtered[i], _patients.indexOf(filtered[i]))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0284C7).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الملفات الموحدة والمستودع العام للمرضى 👥 (${_patients.length})',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white),
                ),
                const Text(
                  'استعراض وتدقيق السجلات الطبية الوطنية، فصائل الدم، وتجميد/تفعيل الحسابات.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientRowCard(Map<String, dynamic> p, int index) {
    final bool isActive = p['is_active'] == true;
    final String blood = p['blood_group'] ?? 'غير معروفة';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GlassBentoCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(14),
        enableGlow: isActive,
        glowColor: AppTheme.secondary,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.secondary.withValues(alpha: 0.12),
                  child: const Text('👤', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.textMain)),
                      Text('📁 ${p['mrn']}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF047857))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: blood == 'غير معروفة' ? Colors.red.shade50 : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    blood,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: blood == 'غير معروفة' ? Colors.red.shade700 : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📞 ${p['phone']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                Text('🎂 ${p['dob']} (${p['gender']})', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // زر تعديل السجل
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open_rounded, size: 14, color: Colors.white),
                    label: const Text('تعديل السجل 📁', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => _openEditPatientModal(p, index),
                  ),
                ),
                const SizedBox(width: 8),
                // زر التعطيل / التفعيل
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _togglePatientStatus(index),
                    child: Text(isActive ? 'تعطيل 🔴' : 'تفعيل 🟢', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.secondary)),
    );
  }
}
