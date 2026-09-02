import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Modern Smart Appointment Booking & Patient Medical Archives Screen
/// Matched 100% with official Booking & Archives screenshots (Images 6, 7 & 8)
class PatientBookAndRecordsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialDoctor;

  const PatientBookAndRecordsScreen({super.key, this.initialDoctor});

  @override
  State<PatientBookAndRecordsScreen> createState() => _PatientBookAndRecordsScreenState();
}

class _PatientBookAndRecordsScreenState extends State<PatientBookAndRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedDoctor = 'د. محمد جعفري (طب وجراحة العيون)';
  String _selectedService = 'استشارة عيادية عامة';
  DateTime? _selectedAppointmentDate = DateTime(2026, 9, 10);
  String _selectedSlot = '10:00';

  final List<String> _doctors = [
    'د. محمد جعفري (طب وجراحة العيون)',
    'د. محمد بلعربي (أمراض القلب والشرايين)',
    'د. فلسطيني صحي (طب عام)',
  ];

  final List<String> _services = [
    'استشارة عيادية عامة',
    'فحص تخطيط القلب الكهربائي (ECG)',
    'فحص متخصص متقدم ومتابعة',
    'استشارة مستعجلة',
  ];

  final List<String> _availableSlots = [
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '14:00',
    '14:30',
    '15:00',
  ];

  // سجل المواعيد الخاصة بالمريض
  final List<Map<String, dynamic>> _myAppointments = [
    {
      'id': 1,
      'doctor': 'د. محمد جعفري',
      'specialty': 'طب وجراحة العيون',
      'service': 'استشارة عيادية عامة',
      'date': '2026-09-10',
      'time': '10:00',
      'status': 'قيد الانتظار والقبول',
    },
  ];

  // سجل الوصفات الخاصة بالمريض
  final List<Map<String, dynamic>> _myPrescriptions = [
    {
      'rx_code': 'RX-2026-43116',
      'doctor': 'د. محمد جعفري',
      'date': '2026-08-10',
      'drug': 'Doliprane 1g (Tablet)',
      'dosage': '1 قرص قبل الأكل 3 مرات يومياً',
      'duration': '15 يوم',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialDoctor != null && widget.initialDoctor!['name'] != null) {
      final docName = widget.initialDoctor!['name'];
      final match = _doctors.firstWhere((d) => d.contains(docName), orElse: () => _doctors[0]);
      _selectedDoctor = match;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAppointmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedAppointmentDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      // منع الحجز في أيام الجمعة والسبت (عطلة العيادة)
      if (picked.weekday == DateTime.friday || picked.weekday == DateTime.saturday) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('عذراً، هذا اليوم عطلة رسمية للعيادة. يرجى اختيار يوم عمل من الأحد إلى الخميس.', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => _selectedAppointmentDate = picked);
    }
  }

  void _submitAppointmentBooking() {
    if (_selectedAppointmentDate == null) return;
    final dateStr = '${_selectedAppointmentDate!.year}-${_selectedAppointmentDate!.month.toString().padLeft(2, '0')}-${_selectedAppointmentDate!.day.toString().padLeft(2, '0')}';
    final docName = _selectedDoctor.split(' (')[0];

    setState(() {
      _myAppointments.insert(0, {
        'id': _myAppointments.length + 1,
        'doctor': docName,
        'specialty': _selectedDoctor.split('(')[1].replaceAll(')', ''),
        'service': _selectedService,
        'date': dateStr,
        'time': _selectedSlot,
        'status': 'قيد الانتظار والقبول',
      });
      _tabController.animateTo(1); // الانتقال لتبويب أرشيف المواعيد
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال طلب حجزك بنجاح مع $docName بتاريخ $dateStr الساعة $_selectedSlot 📅', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
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
            Text('| الحجز وسجل المواعيد والوصفات', style: TextStyle(fontFamily: 'Cairo', fontSize: 14.5, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12),
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '📅 حجز موعد جديد'),
            Tab(text: '🗓️ أرشيف المواعيد'),
            Tab(text: '✍️ سجل الوصفات RX'),
          ],
        ),
      ),
      body: AmbientLightBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookAppointmentTab(),
            _buildAppointmentsArchiveTab(),
            _buildPrescriptionsArchiveTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookAppointmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassBentoCard(
            borderRadius: 22,
            padding: const EdgeInsets.all(18),
            enableGlow: true,
            glowColor: AppTheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'حجز موعد جديد',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'احجز موعدك الطبي بذكاء؛ لتظهر لك الأيام الشاغرة وساعات العمل الفعلية للطبيب فقط.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 20),

                // اختيار الطبيب المعالج
                DropdownButtonFormField<String>(
                  value: _selectedDoctor,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'اختر الطبيب المعالج *', prefixIcon: Icon(Icons.person_search_rounded, size: 20)),
                  items: _doctors
                      .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12), overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDoctor = v ?? _selectedDoctor),
                ),
                const SizedBox(height: 12),

                // نوع الخدمة الطبية
                DropdownButtonFormField<String>(
                  value: _selectedService,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'نوع الخدمة الطبية *', prefixIcon: Icon(Icons.medical_services_outlined, size: 20)),
                  items: _services
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedService = v ?? _selectedService),
                ),
                const SizedBox(height: 12),

                // تاريخ الموعد المفضل
                InkWell(
                  onTap: _pickAppointmentDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('تاريخ الموعد المفضل *', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              _selectedAppointmentDate != null
                                  ? '${_selectedAppointmentDate!.year}-${_selectedAppointmentDate!.month.toString().padLeft(2, '0')}-${_selectedAppointmentDate!.day.toString().padLeft(2, '0')}'
                                  : 'اختر التاريخ...',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.primary),
                            ),
                          ],
                        ),
                        const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // الساعات المتاحة
                const Text('⏰ التوقيت المتاح للكشف:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMain)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSlots.map((slot) {
                    final isSel = _selectedSlot == slot;
                    return ChoiceChip(
                      label: Text(slot, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppTheme.textMain)),
                      selected: isSel,
                      selectedColor: AppTheme.primary,
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => _selectedSlot = slot),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),

                // زر تأكيد الحجز
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                    label: const Text('تأكيد وإرسال طلب الحجز 📅', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    onPressed: _submitAppointmentBooking,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAppointmentsArchiveTab() {
    if (_myAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), shape: BoxShape.circle),
                child: const Icon(Icons.event_available_rounded, color: Color(0xFF0284C7), size: 40),
              ),
              const SizedBox(height: 12),
              const Text('أرشيف وسجل المواعيد الطبية الخاصة بك', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textMain)),
              const SizedBox(height: 4),
              const Text('لا توجد أي مواعيد طبية مسجلة لملفك الطبي حتى الآن.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 11.5)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      itemCount: _myAppointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final appt = _myAppointments[index];
        return GlassBentoCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(14),
          enableGlow: true,
          glowColor: const Color(0xFF0284C7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appt['doctor'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.textMain)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
                    child: Text(appt['status'], style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(appt['specialty'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
              const Divider(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الخدمة: ${appt['service']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
                  Text('📅 ${appt['date']}  ⏰ ${appt['time']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsArchiveTab(BuildContext context) {
    if (_myPrescriptions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 40),
              ),
              const SizedBox(height: 12),
              const Text('أرشيف وسجل الوصفات الطبية المصروفة لملفك', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textMain)),
              const SizedBox(height: 4),
              const Text('لا توجد أي وصفات طبية رقمية مسجلة لملفك الطبي حتى الآن.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 11.5)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      itemCount: _myPrescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final rx = _myPrescriptions[index];
        return GlassBentoCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(14),
          enableGlow: true,
          glowColor: AppTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('كود الوصفة: ${rx['rx_code']}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primary)),
                  Text('تاريخ: ${rx['date']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 2),
              Text('الطبيب المعالج: ${rx['doctor']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
              const SizedBox(height: 6),
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
                    onPressed: () => context.push('/doctor-prescription-view', extra: {
                      'rx_code': rx['rx_code'],
                      'patient_name': 'Moi Hi',
                      'mrn': 'MR-2026-00010',
                      'dob': '2026-08-08',
                      'blood_group': 'B-',
                      'doctor_name': rx['doctor'],
                      'specialty': 'طب وجراحة العيون',
                      'license': '68674683',
                      'clinic': 'عيادة طبيبي الخاصة الموحدة',
                      'clinic_address': 'الجزائر العاصمة، الجزائر',
                      'clinic_phone': '021000000',
                      'date': '2026-08-10 09:24',
                      'drug_name': rx['drug'],
                      'generic': 'Paracétamol 1g',
                      'dosage': rx['dosage'],
                      'duration': rx['duration'],
                      'quantity': '2 علبة',
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
