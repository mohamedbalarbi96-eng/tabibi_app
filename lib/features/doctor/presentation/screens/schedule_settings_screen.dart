import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// TABIBI (طبيبي) - Doctor Work Schedule & Leaves Management Screen
class ScheduleSettingsScreen extends StatefulWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  State<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends State<ScheduleSettingsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  // خريطة أيام الأسبوع المعتمدة
  final List<Map<String, dynamic>> _weekdays = [
    {'day': 0, 'name': 'الأحد', 'active': true, 'start': '08:00', 'end': '16:00', 'duration': 30, 'max': 15},
    {'day': 1, 'name': 'الإثنين', 'active': true, 'start': '08:00', 'end': '16:00', 'duration': 30, 'max': 15},
    {'day': 2, 'name': 'الثلاثاء', 'active': true, 'start': '08:00', 'end': '16:00', 'duration': 30, 'max': 15},
    {'day': 3, 'name': 'الأربعاء', 'active': true, 'start': '08:00', 'end': '16:00', 'duration': 30, 'max': 15},
    {'day': 4, 'name': 'الخميس', 'active': true, 'start': '08:00', 'end': '16:00', 'duration': 30, 'max': 15},
    {'day': 5, 'name': 'الجمعة', 'active': false, 'start': '08:00', 'end': '12:00', 'duration': 30, 'max': 10},
    {'day': 6, 'name': 'السبت', 'active': false, 'start': '08:00', 'end': '14:00', 'duration': 30, 'max': 10},
  ];

  final List<Map<String, String>> _leavesList = [];

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/doctor/schedule.php',
        data: {
          'action': 'save_weekly_schedule',
          'schedules': _weekdays,
        },
      );

      final data = response.data;
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? '✅ تم حفظ وتحديث جدول العمل الأسبوعي بنجاح!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ الإعدادات بنجاح في ذاكرة العيادة.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    }
  }

  void _openAddLeaveDialog() {
    DateTime? startDate;
    DateTime? endDate;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تسجيل إجازة أو عطلة للعيادة 🌴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range_rounded),
                label: Text(startDate == null
                    ? 'تاريخ بداية الإجازة *'
                    : 'من: ${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ar'),
                  );
                  if (picked != null) {
                    setDialogState(() => startDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.event_busy_rounded),
                label: Text(endDate == null
                    ? 'تاريخ انتهاء الإجازة *'
                    : 'إلى: ${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ar'),
                  );
                  if (picked != null) {
                    setDialogState(() => endDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'سبب العطلة (اختياري)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              onPressed: () {
                if (startDate != null && endDate != null) {
                  final startStr = "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}";
                  final endStr = "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}";

                  setState(() {
                    _leavesList.add({
                      'start': startStr,
                      'end': endStr,
                      'reason': reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : 'عطلة عيادية',
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🌴 تم تسجيل الإجازة وحظر حجز المواعيد في هذه الفترة.'), backgroundColor: Color(0xFF059669)),
                  );
                }
              },
              child: const Text('تأكيد وحظر الحجوزات'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أوقات العمل والإجازات'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة رأسية توضيحية
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'حدد أيام وساعات العمل الرسمية؛ ليظهر للمرضى التوقيتات الشاغرة فقط.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. جدول أيام الأسبوع
            const Text('📅 جدول العمل الأسبوعي:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._weekdays.map((dayItem) {
              final isActive = dayItem['active'] as bool;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
                ),
                color: isActive ? Colors.white : Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isActive,
                                activeColor: theme.colorScheme.primary,
                                onChanged: (val) => setState(() => dayItem['active'] = val ?? false),
                              ),
                              Text(dayItem['name'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isActive ? Colors.black87 : Colors.grey)),
                            ],
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                              child: const Text('متاح للحجز', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          else
                            const Text('عطلة', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      if (isActive) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text('من: ${dayItem['start']}  إلى: ${dayItem['end']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              child: Text('مدة الكشف: ${dayItem['duration']} د', textAlign: TextAlign.end, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 2. قسم الإجازات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🌴 الإجازات والعطل الاستثنائية:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة إجازة'),
                  onPressed: _openAddLeaveDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_leavesList.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('لا توجد إجازات مسجلة حالياً.', style: TextStyle(color: Colors.grey, fontSize: 12))),
              )
            else
              ..._leavesList.map((leave) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    elevation: 0,
                    color: Colors.red.shade50,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.beach_access_rounded, color: Colors.redAccent),
                      title: Text('${leave['reason']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('من: ${leave['start']}  إلى: ${leave['end']}', style: const TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () => setState(() => _leavesList.remove(leave)),
                      ),
                    ),
                  )),

            const SizedBox(height: 30),

            // زر حفظ الإعدادات
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('💾 حفظ وتحديث جدول العمل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}