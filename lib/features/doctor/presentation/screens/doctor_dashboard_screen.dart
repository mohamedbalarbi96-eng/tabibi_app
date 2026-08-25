import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/logic/auth_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// TABIBI (طبيبي) - Doctor Clinical Workspace & Live Queue Screen
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
            SnackBar(content: Text(data['message'] ?? successMsg), backgroundColor: const Color(0xFF059669)),
          );
        }
      } else {
        throw data['message'] ?? 'حدث خطأ أثناء تنفيذ الإجراء.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طبيبي | العيادة وقاعة الانتظار'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule_rounded),
            tooltip: 'أوقات العمل والإجازات',
            onPressed: () => context.push('/doctor-schedule'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
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
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboard(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 54),
                      const SizedBox(height: 12),
                      Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. شريط إحصائيات الطبيب والمداخيل
                  _buildStatsRow(stats),
                  const SizedBox(height: 20),

                  // 2. بطاقة المريض الحالي في غرفة الفحص
                  if (activePatient != null) ...[
                    _buildActiveExamChamber(theme, activePatient),
                    const SizedBox(height: 20),
                  ],

                  // 3. قاعة الانتظار لليوم
                  _buildSectionHeader('🚶 قاعة الانتظار لليوم (${waitingQueue.length})'),
                  const SizedBox(height: 8),
                  _buildWaitingQueueList(theme, waitingQueue),
                  const SizedBox(height: 24),

                  // 4. طلبات المواعيد الواردة المعلقة
                  _buildSectionHeader('📅 طلبات المواعيد الواردة المعلقة (${pendingAppts.length})'),
                  const SizedBox(height: 8),
                  _buildPendingAppointmentsList(theme, pendingAppts),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final waiting = stats['waiting_count']?.toString() ?? '0';
    final pending = stats['pending_appts']?.toString() ?? '0';
    final revenue = stats['total_revenue']?.toString() ?? '0.00';

    return Row(
      children: [
        _buildStatCard('في الانتظار', waiting, '🚶', Colors.blue.shade700, Colors.blue.shade50),
        const SizedBox(width: 8),
        _buildStatCard('طلبات معلقة', pending, '📅', Colors.orange.shade800, Colors.orange.shade50),
        const SizedBox(width: 8),
        _buildStatCard('المداخيل', '$revenue د.ج', '🪙', const Color(0xFF059669), const Color(0xFFE8F5E9)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fg.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fg), overflow: TextOverflow.ellipsis),
            Text(title, style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveExamChamber(ThemeData theme, Map<String, dynamic> p) {
    final name = p['full_name'] ?? 'مريض';
    final mrn = p['record_number'] ?? '';
    final blood = p['blood_group'] ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('المريض الحالي في غرفة الفحص السريري', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('ملف طبي: $mrn  |  فصيلة الدم: $blood', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            icon: const Icon(Icons.medical_information_rounded, size: 18),
            label: const Text('بدء التشخيص السريري وكتابة الوصفة 🩺'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _openClinicalExamSheet(p),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
  }

  Widget _buildWaitingQueueList(ThemeData theme, List<Map<String, dynamic>> queue) {
    if (queue.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('قاعة الانتظار فارغة حالياً.', style: TextStyle(color: Colors.grey, fontSize: 13))),
      );
    }

    return Column(
      children: queue.map((q) {
        final qId = q['queue_id'] as int;
        final qNo = q['queue_number']?.toString() ?? '0';
        final name = q['full_name'] ?? 'مريض';
        final mrn = q['record_number'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text('#$qNo', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('ملف: $mrn', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(60, 32),
                  ),
                  onPressed: () => _handlePostAction('call_patient', {'queue_id': qId}, 'تم استدعاء المريض لغرفة الفحص.'),
                  child: const Text('استدعاء 🩺', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: const Size(40, 32),
                  ),
                  onPressed: () => _handlePostAction('skip_patient', {'queue_id': qId}, 'تم تخطي المريض.'),
                  child: const Text('تخطي', style: TextStyle(fontSize: 11, color: Colors.orange)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingAppointmentsList(ThemeData theme, List<Map<String, dynamic>> appts) {
    if (appts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('لا توجد طلبات مواعيد معلقة للمراجعة.', style: TextStyle(color: Colors.grey, fontSize: 13))),
      );
    }

    return Column(
      children: appts.map((appt) {
        final aId = appt['appointment_id'] as int;
        final name = '${appt['first_name'] ?? ''} ${appt['last_name'] ?? ''}'.trim();
        final date = appt['appointment_date'] ?? '';
        final time = appt['appointment_time'] ?? '';
        final service = appt['service_name'] ?? 'فحص عام';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('📅 $date • ⏰ $time\nالخدمة: $service', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            isThreeLine: true,
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => _handlePostAction('accept_appointment', {'appointment_id': aId}, 'تم قبول وتأكيد الموعد بنجاح.'),
              child: const Text('قبول ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// نافذة جلسة الفحص السريري وتدوين الوصفة الطبية
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('جلسة الفحص السريري: ${patient['full_name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // 1. التشخيص والملاحظات
                TextField(controller: diagController, decoration: const InputDecoration(labelText: 'التشخيص الطبي الرئيسي *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'ملاحظات الفحص السريري *', border: OutlineInputBorder())),
                const SizedBox(height: 16),

                // 2. العلامات الحيوية
                const Text('🩺 العلامات الحيوية (اختياري):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الوزن (كلغ)', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: tempController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الحرارة (م°)', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: pulseController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'النبض', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: bpSysController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الضغط انقباضي', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: bpDiaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الضغط انبساطي', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. إضافة أدوية الوصفة
                const Text('💊 تحرير الوصفة الطبية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 2, child: TextField(controller: medNameController, decoration: const InputDecoration(labelText: 'اسم الدواء (مثل: Doliprane)', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
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
                      child: const Text('＋ إضافة'),
                    ),
                  ],
                ),
                if (medicinesList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...medicinesList.map((m) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('• ${m['name']} (${m['dosage']} - ${m['frequency']})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                              onPressed: () => setSheetState(() => medicinesList.remove(m)),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (diagController.text.trim().isEmpty || notesController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء التشخيص والملاحظات.')));
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
                  child: const Text('حفظ الفحص ونقل المريض لحالة مكتمل ✓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}