import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../../auth/logic/auth_bloc.dart';

/// TABIBI (طبيبي) - Ultra-Modern Assistant / Receptionist Clinical Check-In & Billing Screen
/// Matched 100% with the official Assistant Portal screenshots
class AssistantDashboardScreen extends StatefulWidget {
  const AssistantDashboardScreen({super.key});

  @override
  State<AssistantDashboardScreen> createState() => _AssistantDashboardScreenState();
}

class _AssistantDashboardScreenState extends State<AssistantDashboardScreen> {
  // نموذج مريض جديد بالكامل (إنشاء ملف فوري)
  final _newFirstNameCtrl = TextEditingController();
  final _newLastNameCtrl = TextEditingController();
  final _newPhoneCtrl = TextEditingController();
  String _newGender = 'ذكر';
  String _selectedDoctorForNew = 'د. محمد جعفري (طب وجراحة العيون)';

  // نموذج حقن مريض مسجل مسبقاً
  String _existingPatient = 'Nanova Center (MR-2026-00022)';
  String _selectedDoctorForExisting = 'د. محمد جعفري (طب وجراحة العيون)';

  final List<String> _registeredPatientsList = [
    'Nanova Center (MR-2026-00022)',
    'Youcef Nechadi (MR-2026-00020)',
    'فلسطيني صحي (MR-2026-00019)',
    'امال حامل (MR-2026-00018)',
    'Sidahmed Chafi (MR-2026-00016)',
    'Azer Azee (MR-2026-00015)',
  ];

  final List<String> _doctorsList = [
    'د. محمد جعفري (طب وجراحة العيون)',
    'د. محمد بلعربي (أمراض القلب والشرايين)',
    'د. فلسطيني صحي (طب عام)',
  ];

  // مواعيد اليوم المجدولة وبانتظار الحضور
  final List<Map<String, dynamic>> _todayScheduledAppointments = [
    {
      'id': 101,
      'name': 'Azer Azee',
      'mrn': 'MR-2026-00015',
      'time': '10:00',
      'doctor': 'د. محمد جعفري',
    },
    {
      'id': 102,
      'name': 'jtjrjjrrj dndnc cm',
      'mrn': 'MR-2026-00021',
      'time': '08:00',
      'doctor': 'د. محمد بلعربي',
    },
  ];

  // طابور وحالة الانتظار والتحصيل المالي لليوم (المطابق للصورة)
  final List<Map<String, dynamic>> _dailyQueue = [
    {
      'queue_no': 1,
      'name': 'بلعربي الهادي',
      'mrn': 'MR-2026-00002',
      'doctor': 'د. محمد جعفري',
      'status': 'completed', // completed | waiting | in_consultation
      'fee_amount': '2000',
      'paid_amount': '2000.00',
      'is_paid': true,
    },
    {
      'queue_no': 2,
      'name': 'محمد بلعربي',
      'mrn': 'MR-2026-00014',
      'doctor': 'د. محمد بلعربي',
      'status': 'in_consultation',
      'fee_amount': '2000',
      'paid_amount': null,
      'is_paid': false,
    },
    {
      'queue_no': 3,
      'name': 'Nanova Center',
      'mrn': 'MR-2026-00022',
      'doctor': 'د. فلسطيني صحي',
      'status': 'waiting',
      'fee_amount': '2000',
      'paid_amount': null,
      'is_paid': false,
    },
  ];

  @override
  void dispose() {
    _newFirstNameCtrl.dispose();
    _newLastNameCtrl.dispose();
    _newPhoneCtrl.dispose();
    super.dispose();
  }

  // 1. تسجيل حضور موعد مجدول
  void _checkInScheduledPatient(int index) {
    final appt = _todayScheduledAppointments[index];
    setState(() {
      _dailyQueue.add({
        'queue_no': _dailyQueue.length + 1,
        'name': appt['name'],
        'mrn': appt['mrn'],
        'doctor': appt['doctor'],
        'status': 'waiting',
        'fee_amount': '2000',
        'paid_amount': null,
        'is_paid': false,
      });
      _todayScheduledAppointments.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل حضور المريض ${appt['name']} وحقنه في طابور اليوم بنجاح!', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 2. حقن فوري لمريض مسجل مسبقاً
  void _injectExistingPatient() {
    final name = _existingPatient.split(' (')[0];
    final mrn = _existingPatient.split('(')[1].replaceAll(')', '');
    final doc = _selectedDoctorForExisting.split(' (')[0];

    setState(() {
      _dailyQueue.add({
        'queue_no': _dailyQueue.length + 1,
        'name': name,
        'mrn': mrn,
        'doctor': doc,
        'status': 'waiting',
        'fee_amount': '2000',
        'paid_amount': null,
        'is_paid': false,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حقن المريض $name في طابور الانتظار لعيادة $doc بنجاح!', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0284C7),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 3. تسجيل مريض جديد كلياً وإنشاء ملف فوري
  void _registerAndInjectNewPatient() {
    if (_newFirstNameCtrl.text.trim().isEmpty || _newLastNameCtrl.text.trim().isEmpty || _newPhoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء الاسم، اللقب، ورقم الهاتف للمريض الجديد.', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newName = '${_newFirstNameCtrl.text.trim()} ${_newLastNameCtrl.text.trim()}';
    final generatedMrn = 'MR-2026-000${_dailyQueue.length + 25}';
    final doc = _selectedDoctorForNew.split(' (')[0];

    setState(() {
      _dailyQueue.add({
        'queue_no': _dailyQueue.length + 1,
        'name': newName,
        'mrn': generatedMrn,
        'doctor': doc,
        'status': 'waiting',
        'fee_amount': '2000',
        'paid_amount': null,
        'is_paid': false,
      });
      _newFirstNameCtrl.clear();
      _newLastNameCtrl.clear();
      _newPhoneCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إنشاء الملف الطبي $generatedMrn للمريض $newName وحقنه في الطابور فوراً! 🚀', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 4. تسديد الفاتورة والتحصيل المالي الفوري
  void _collectPayment(int index, String customAmount) {
    setState(() {
      _dailyQueue[index]['is_paid'] = true;
      _dailyQueue[index]['paid_amount'] = '$customAmount.00';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم بنجاح تسجيل دفع مبلغ: $customAmount د.ج وإصدار الفاتورة رقم: INV-2026-34580 للمريض ${_dailyQueue[index]['name']}! 🪙', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
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
            Text('| بوابة الاستقبال والفوترة', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: AmbientLightBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. البانر الأزرق الفاخر المطابق للصورة
              _buildAssistantHeaderBanner(),
              const SizedBox(height: 18),

              // 2. بطاقة مواعيد اليوم المجدولة وبانتظار حضور أصحابها
              _buildSectionTitle('📅 مواعيد اليوم المجدولة وبانتظار حضور أصحابها (${_todayScheduledAppointments.length})'),
              const SizedBox(height: 8),
              _buildTodayScheduledCard(),
              const SizedBox(height: 22),

              // 3. طابور وحالة الانتظار والتحصيل المالي لليوم
              _buildSectionTitle('🚶 طابور وحالة الانتظار والتحصيل المالي لليوم (${_dailyQueue.length})'),
              const SizedBox(height: 8),
              _buildDailyQueueBillingCard(),
              const SizedBox(height: 22),

              // 4. تسجيل حضور مريض مسجل مسبقاً (بدون موعد مسبق)
              _buildSectionTitle('👥 تسجيل حضور مريض مسجل مسبقاً (بدون موعد)'),
              const SizedBox(height: 8),
              _buildExistingPatientCheckinCard(),
              const SizedBox(height: 22),

              // 5. تسجيل مريض جديد بالكامل وحقنه فوراً (إنشاء ملف فوري)
              _buildSectionTitle('📝 تسجيل مريض جديد بالكامل وحقنه فوراً (إنشاء ملف فوري)'),
              const SizedBox(height: 8),
              _buildNewPatientRegistrationCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0284C7).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'بوابة مساعد الطبيب والاستقبال والقبول المباشر والفوترة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14.5, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('⚡ نظام حي', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'سجل حضور المرضى أصحاب المواعيد المسبقة، أو احقن الحالات الاستعجالية بدون موعد، وحصّل الفواتير النقدية للعيادة فورياً.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduledCard() {
    if (_todayScheduledAppointments.isEmpty) {
      return GlassBentoCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(22),
        child: const Center(
          child: Text('لا توجد أي مواعيد طبية مؤكدة لتاريخ اليوم بانتظار تسجيل حضورها.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      children: List.generate(_todayScheduledAppointments.length, (index) {
        final appt = _todayScheduledAppointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassBentoCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.textMain)),
                      Text('📁 ${appt['mrn']}  •  ⏰ ${appt['time']}', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                      Text(appt['doctor'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                  label: const Text('تسجيل حضور 🚶', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _checkInScheduledPatient(index),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDailyQueueBillingCard() {
    return Column(
      children: List.generate(_dailyQueue.length, (index) {
        final q = _dailyQueue[index];
        final bool isPaid = q['is_paid'] == true;
        final String status = q['status'];

        final amountController = TextEditingController(text: q['fee_amount']);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: GlassBentoCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            enableGlow: status == 'in_consultation',
            glowColor: AppTheme.primary,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: status == 'in_consultation' ? AppTheme.primaryGradient : null,
                        color: status == 'completed' ? const Color(0xFF10B981) : AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('#${q['queue_no']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.textMain)),
                          Text('${q['mrn']} • ${q['doctor']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    _buildQueueStatusBadge(status),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isPaid)
                      Text('✓ تم دفع: ${q['paid_amount']} د.ج', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF059669), fontWeight: FontWeight.w900, fontSize: 12.5))
                    else
                      const Text('المستحقات المالية: بانتظار الدفع', style: TextStyle(fontFamily: 'Cairo', color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),

                    if (!isPaid)
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 34,
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 34,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.payments_rounded, size: 14, color: Colors.white),
                              label: const Text('تسديد 🪙', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _collectPayment(index, amountController.text.trim()),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExistingPatientCheckinCard() {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _existingPatient,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'اختر المريض المسجل مسبقاً *', prefixIcon: Icon(Icons.person_search_rounded, size: 20)),
            items: _registeredPatientsList
                .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12), overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _existingPatient = v ?? _existingPatient),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedDoctorForExisting,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'تحديد الطبيب المعالج المطلوب *', prefixIcon: Icon(Icons.medical_services_outlined, size: 20)),
            items: _doctorsList
                .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12), overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _selectedDoctorForExisting = v ?? _selectedDoctorForExisting),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login_rounded, color: Colors.white, size: 16),
              label: const Text('حقن فوري في طابور اليوم 🚶', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _injectExistingPatient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPatientRegistrationCard() {
    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      enableGlow: true,
      glowColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newFirstNameCtrl,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                  decoration: const InputDecoration(labelText: 'الاسم الأول للمريض الجديد *', hintText: 'أحمد'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _newLastNameCtrl,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                  decoration: const InputDecoration(labelText: 'اللقب (العائلة) *', hintText: 'بن علي'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                  decoration: const InputDecoration(labelText: 'رقم الهاتف *', hintText: '0770123456'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _newGender,
                  decoration: const InputDecoration(labelText: 'الجنس *'),
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _newGender = v ?? 'ذكر'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedDoctorForNew,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'تحديد الطبيب المعالج المطلوب *'),
            items: _doctorsList
                .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12), overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _selectedDoctorForNew = v ?? _selectedDoctorForNew),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
              label: const Text('تأكيد وإنشاء ملف طبي وحقنه بالطابور فوراً 🚀', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              onPressed: _registerAndInjectNewPatient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStatusBadge(String status) {
    Color bg = Colors.orange.shade50;
    Color fg = Colors.orange.shade800;
    String text = 'في الانتظار';

    if (status == 'in_consultation') {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF047857);
      text = 'قيد الفحص 🟢';
    } else if (status == 'completed') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      text = 'مكتمل وتم الفحص ✓';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: fg, fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل تريد تسجيل الخروج من حساب الاستقبال؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/landing');
            },
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
