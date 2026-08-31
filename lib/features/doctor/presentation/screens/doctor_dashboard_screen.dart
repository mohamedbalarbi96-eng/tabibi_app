import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../../auth/logic/auth_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// TABIBI (طبيبي) - Ultra-Modern Glassmorphic Bento Doctor Workspace & Queue Screen
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    setState(() {
      _dashboardFuture = _fetchDashboardData();
    });
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final response = await _apiClient.get('${ApiEndpoints.baseUrl}/doctor/clinical.php?action=dashboard');
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw data['message'] ?? 'فشل استرجاع بيانات العيادة.';
    }
  }

  Future<void> _handlePostAction(String action, Map<String, dynamic> payload, String successMsg) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/doctor/clinical.php',
        data: {'action': action, ...payload},
      );
      final data = response.data;
      if (data['success'] == true) {
        _loadDashboard();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? successMsg, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        throw data['message'] ?? 'حدث خطأ أثناء تنفيذ الإجراء.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
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
            Text('| لوحة الطبيب والعيادة', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule_rounded, color: AppTheme.secondary),
            tooltip: 'أوقات العمل والإجازات',
            onPressed: () => context.push('/doctor-schedule'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primary),
            tooltip: 'المحادثات الطبية',
            onPressed: () => context.push('/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'خروج',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: AmbientLightBackground(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async => _loadDashboard(),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 54),
                        const SizedBox(height: 14),
                        Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(onPressed: _loadDashboard, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data ?? {};
              final stats = data['stats'] as Map<String, dynamic>? ?? {};
              final activePatient = data['active_patient'] as Map<String, dynamic>?;
              final waitingQueue = (data['waiting_queue'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final pendingAppts = (data['pending_appointments'] as List?)?.cast<Map<String, dynamic>>() ?? [];

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. بطاقات الإحصائيات الذكية والمداخيل (Bento Stats)
                    _buildStatsBentoRow(stats),
                    const SizedBox(height: 16),

                    // 2. غرفة الفحص السريري المباشر النابضة
                    if (activePatient != null) ...[
                      _buildActiveExamChamber(activePatient),
                      const SizedBox(height: 18),
                    ],

                    // 3. قاعة الانتظار لليوم
                    _buildSectionHeader('🚶 قاعة الانتظار الحية لليوم (${waitingQueue.length})'),
                    const SizedBox(height: 8),
                    _buildWaitingQueueList(waitingQueue),
                    const SizedBox(height: 22),

                    // 4. طلبات المواعيد الواردة المعلقة
                    _buildSectionHeader('📅 طلبات المواعيد الواردة المعلقة (${pendingAppts.length})'),
                    const SizedBox(height: 8),
                    _buildPendingAppointmentsList(pendingAppts),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBentoRow(Map<String, dynamic> stats) {
    final waiting = stats['waiting_count']?.toString() ?? '0';
    final pending = stats['pending_appts']?.toString() ?? '0';
    final revenue = stats['total_revenue']?.toString() ?? '0.00';

    return Row(
      children: [
        Expanded(child: _buildBentoStatItem('في الانتظار', waiting, '🚶', AppTheme.secondary)),
        const SizedBox(width: 8),
        Expanded(child: _buildBentoStatItem('طلبات معلقة', pending, '📅', Colors.orange.shade800)),
        const SizedBox(width: 8),
        Expanded(child: _buildBentoStatItem('المداخيل', '$revenue د.ج', '🪙', AppTheme.primary)),
      ],
    );
  }

  Widget _buildBentoStatItem(String title, String value, String emoji, Color accentColor) {
    return GlassBentoCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      enableGlow: true,
      glowColor: accentColor,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: accentColor),
          ),
          Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveExamChamber(Map<String, dynamic> p) {
    final name = p['full_name'] ?? 'مريض';
    final mrn = p['record_number'] ?? '';
    final blood = p['blood_group'] ?? '';

    return GlassBentoCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      enableGlow: true,
      glowColor: const Color(0xFF10B981),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'المريض الحالي في غرفة الفحص السريري',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Text('قيد الكشف 🟢', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF047857))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
          Text('ملف طبي موحد: $mrn   |   فصيلة الدم: $blood', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.medical_services_rounded, size: 18, color: Colors.white),
              label: const Text('بدء التشخيص السريري وكتابة الوصفة 🩺', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () => _openClinicalExamSheet(p),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }

  Widget _buildWaitingQueueList(List<Map<String, dynamic>> queue) {
    if (queue.isEmpty) {
      return GlassBentoCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('قاعة الانتظار فارغة حالياً.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      children: queue.map((q) {
        final qId = q['queue_id'] as int;
        final qNo = q['queue_number']?.toString() ?? '0';
        final name = q['full_name'] ?? 'مريض';
        final mrn = q['record_number'] ?? '';

        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                child: Center(
                  child: Text('#$qNo', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('ملف: $mrn', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(60, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _handlePostAction('call_patient', {'queue_id': qId}, 'تم استدعاء المريض لغرفة الفحص.'),
                child: const Text('استدعاء 🩺', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: const Size(40, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _handlePostAction('skip_patient', {'queue_id': qId}, 'تم تخطي المريض.'),
                child: const Text('تخطي', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingAppointmentsList(List<Map<String, dynamic>> appts) {
    if (appts.isEmpty) {
      return GlassBentoCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('لا توجد طلبات مواعيد معلقة للمراجعة.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      children: appts.map((appt) {
        final aId = appt['appointment_id'] as int;
        final name = '${appt['first_name'] ?? ''} ${appt['last_name'] ?? ''}'.trim();
        final date = appt['appointment_date'] ?? '';
        final time = appt['appointment_time'] ?? '';
        final service = appt['service_name'] ?? 'فحص عام';

        return GlassBentoCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('📅 $date   |   ⏰ $time', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                    Text('الخدمة: $service', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                height: 38,
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _handlePostAction('accept_appointment', {'appointment_id': aId}, 'تم قبول وتأكيد الموعد بنجاح.'),
                  child: const Text('قبول ✓', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _openClinicalExamSheet(Map<String, dynamic> patient) {
    final notesController = TextEditingController();
    final diagController = TextEditingController();
    final weightController = TextEditingController();
    final bpSysController = TextEditingController();
    final bpDiaController = TextEditingController();
    final tempController = TextEditingController();
    final pulseController = TextEditingController();
    final medNameController = TextEditingController();
    final medDosageController = TextEditingController(text: '1 قرص');
    final medFreqController = TextEditingController(text: '3 مرات يومياً');
    final medDurController = TextEditingController(text: '7 أيام');

    List<Map<String, String>> medicinesList = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.only(left: 22, right: 22, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 16),
                Text('جلسة الفحص السريري: ${patient['full_name']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                const SizedBox(height: 16),

                TextField(controller: diagController, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13), decoration: const InputDecoration(labelText: 'التشخيص الطبي الرئيسي *', hintText: 'مثال: التهاب الشعب الهوائية')),
                const SizedBox(height: 10),
                TextField(controller: notesController, maxLines: 3, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13), decoration: const InputDecoration(labelText: 'ملاحظات الفحص السريري *', hintText: 'اكتب نتائج المعاينة والأعراض...')),
                const SizedBox(height: 18),

                const Text('🩺 العلامات والقياسات الحيوية (اختياري):', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الوزن (كلغ)'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: tempController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الحرارة (م°)'))),
                    Expanded(child: TextField(controller: pulseController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'النبض'))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: bpSysController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الضغط انقباضي'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: bpDiaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الضغط انبساطي'))),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('💊 تحرير الوصفة الطبية:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 2, child: TextField(controller: medNameController, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13), decoration: const InputDecoration(labelText: 'اسم الدواء (مثل: Doliprane 1g)'))),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (medNameController.text.trim().isNotEmpty) {
                            setSheetState(() {
                              medicinesList.add({
                                'name': medNameController.text.trim(),
                                'dosage': medDosageController.text.trim(),
                                'frequency': medFreqController.text.trim(),
                                'duration': medDurController.text.trim(),
                              });
                              medNameController.clear();
                            });
                          }
                        },
                        child: const Text('＋ إضافة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                if (medicinesList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...medicinesList.map((m) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('• ${m['name']} (${m['dosage']} - ${m['frequency']})', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                              onPressed: () => setSheetState(() => medicinesList.remove(m)),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 24),
                Container(
                  height: 52,
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () async {
                      if (diagController.text.trim().isEmpty || notesController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء التشخيص والملاحظات السريرية.', style: TextStyle(fontFamily: 'Cairo'))));
                        return;
                      }
                      Navigator.pop(ctx);
                      await _handlePostAction(
                        'save_visit',
                        {
                          'queue_id': patient['queue_id'],
                          'patient_id': patient['patient_id'],
                          'appointment_id': patient['appointment_id'],
                          'diagnosis_name': diagController.text.trim(),
                          'notes': notesController.text.trim(),
                          'weight': weightController.text.trim(),
                          'temperature': tempController.text.trim(),
                          'pulse_rate': pulseController.text.trim(),
                          'bp_systolic': bpSysController.text.trim(),
                          'bp_diastolic': bpDiaController.text.trim(),
                          'medicines': medicinesList,
                        },
                        'تم حفظ الفحص الطبي وإصدار الوصفة بنجاح!',
                      );
                    },
                    child: const Text('حفظ الفحص ونقل المريض لحالة مكتمل ✓', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل تريد تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
