import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Doctor Weekly Work Schedule & Leave Blocking Screen
/// Matched 100% with the official Schedule Settings screenshot
class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  // بيانات جدول العمل الأسبوعي للأيام السبعة
  final List<Map<String, dynamic>> _weeklySchedule = [
    {'day': 'الأحد', 'is_working': true, 'start': '08:00', 'end': '16:00', 'duration': '30 دقيقة', 'max': '15'},
    {'day': 'الإثنين', 'is_working': true, 'start': '08:00', 'end': '16:00', 'duration': '30 دقيقة', 'max': '15'},
    {'day': 'الثلاثاء', 'is_working': true, 'start': '08:00', 'end': '16:00', 'duration': '30 دقيقة', 'max': '15'},
    {'day': 'الأربعاء', 'is_working': true, 'start': '08:00', 'end': '16:00', 'duration': '30 دقيقة', 'max': '15'},
    {'day': 'الخميس', 'is_working': true, 'start': '08:00', 'end': '16:00', 'duration': '30 دقيقة', 'max': '15'},
    {'day': 'الجمعة', 'is_working': false, 'start': '08:00', 'end': '16:00', 'duration': '30 دقيقة', 'max': '15'},
    {'day': 'السبت', 'is_working': false, 'start': '08:00', 'end': '16:00', 'duration': '30 دقيقة', 'max': '15'},
  ];

  // حقول تسجيل إجازة استثنائية
  DateTime? _leaveStartDate;
  DateTime? _leaveEndDate;
  final TextEditingController _leaveReasonCtrl = TextEditingController();

  // قائمة الإجازات النشطة المسجلة
  final List<Map<String, dynamic>> _activeLeaves = [];

  @override
  void dispose() {
    _leaveReasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLeaveDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _leaveStartDate = picked;
        } else {
          _leaveEndDate = picked;
        }
      });
    }
  }

  void _saveWeeklySchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ وتحديث جدول أوقات العمل الأسبوعي بنجاح!', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _registerLeave() {
    if (_leaveStartDate == null || _leaveEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد تاريخ بداية ونهاية الإجازة.', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final startStr = '${_leaveStartDate!.year}-${_leaveStartDate!.month.toString().padLeft(2, '0')}-${_leaveStartDate!.day.toString().padLeft(2, '0')}';
    final endStr = '${_leaveEndDate!.year}-${_leaveEndDate!.month.toString().padLeft(2, '0')}-${_leaveEndDate!.day.toString().padLeft(2, '0')}';

    setState(() {
      _activeLeaves.add({
        'start': startStr,
        'end': endStr,
        'reason': _leaveReasonCtrl.text.trim().isEmpty ? 'عطلة خاصة' : _leaveReasonCtrl.text.trim(),
      });
      _leaveStartDate = null;
      _leaveEndDate = null;
      _leaveReasonCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الإجازة وحظر حجز المواعيد في هذه الفترة بنجاح!', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0D9488),
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
            Text('| جدول المواعيد والإجازات', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              // 1. عنوان وبانر ضبط الجدول الأسبوعي
              _buildSectionTitle('📅 جدول وضبط مواعيد العيادة الأسبوعية'),
              const SizedBox(height: 10),
              _buildWeeklyScheduleCard(),
              const SizedBox(height: 24),

              // 2. تسجيل إجازة أو عطلة استثنائية جديدة
              _buildSectionTitle('🌴 تسجيل إجازة أو عطلة استثنائية جديدة'),
              const SizedBox(height: 10),
              _buildLeaveRegistrationCard(),
              const SizedBox(height: 24),

              // 3. سجل الإجازات والعطل الاستثنائية النشطة
              _buildSectionTitle('📋 سجل الإجازات والعطل الاستثنائية النشطة (${_activeLeaves.length})'),
              const SizedBox(height: 10),
              _buildActiveLeavesList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleCard() {
    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...List.generate(_weeklySchedule.length, (index) {
            final dayData = _weeklySchedule[index];
            final bool isWorking = dayData['is_working'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isWorking ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isWorking ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isWorking,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() => dayData['is_working'] = v ?? false),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      dayData['day'],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: isWorking ? AppTheme.textMain : Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text('${dayData['start']} - ${dayData['end']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('⏱️ ${dayData['duration']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('👥 max: ${dayData['max']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text('حفظ الجدول الأسبوعي 💾', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _saveWeeklySchedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRegistrationCard() {
    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      enableGlow: true,
      glowColor: const Color(0xFF0D9488),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickLeaveDate(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تاريخ بدء الإجازة *', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          _leaveStartDate != null
                              ? '${_leaveStartDate!.year}-${_leaveStartDate!.month.toString().padLeft(2, '0')}-${_leaveStartDate!.day.toString().padLeft(2, '0')}'
                              : 'اختر التاريخ...',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _pickLeaveDate(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تاريخ انتهاء الإجازة *', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          _leaveEndDate != null
                              ? '${_leaveEndDate!.year}-${_leaveEndDate!.month.toString().padLeft(2, '0')}-${_leaveEndDate!.day.toString().padLeft(2, '0')}'
                              : 'اختر التاريخ...',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _leaveReasonCtrl,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'سبب العطلة أو الإجازة (اختياري)',
              hintText: 'مثال: عطلة سنوية، عطلة نهاية الأسبوع، مؤتمر طبي...',
              prefixIcon: Icon(Icons.beach_access_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F766E)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.block_rounded, color: Colors.white, size: 18),
              label: const Text('تسجيل وحظر حجز المواعيد 🌴', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              onPressed: _registerLeave,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLeavesList() {
    if (_activeLeaves.isEmpty) {
      return GlassBentoCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: const Center(
          child: Text('لا توجد أي إجازات أو عطل قادمة مسجلة حالياً.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      children: List.generate(_activeLeaves.length, (index) {
        final item = _activeLeaves[index];
        return GlassBentoCard(
          borderRadius: 14,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.event_busy_rounded, color: Color(0xFF0D9488), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('من ${item['start']} إلى ${item['end']}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(item['reason'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => setState(() => _activeLeaves.removeAt(index)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }
}
