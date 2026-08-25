import 'package:flutter/material.dart';
import '../../data/patient_repository.dart';

/// TABIBI (طبيبي) - Unified Patient Medical Records, Prescriptions & Shares Screen
class RecordsAndPrescriptionsScreen extends StatefulWidget {
  const RecordsAndPrescriptionsScreen({super.key});

  @override
  State<RecordsAndPrescriptionsScreen> createState() => _RecordsAndPrescriptionsScreenState();
}

class _RecordsAndPrescriptionsScreenState extends State<RecordsAndPrescriptionsScreen> with SingleTickerProviderStateMixin {
  final PatientRepository _repository = PatientRepository();
  late TabController _tabController;

  late Future<List<Map<String, dynamic>>> _appointmentsFuture;
  late Future<List<Map<String, dynamic>>> _prescriptionsFuture;
  late Future<Map<String, dynamic>> _dashboardFuture;
  late Future<List<Map<String, dynamic>>> _sharesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _appointmentsFuture = _repository.getAppointments();
      _prescriptionsFuture = _repository.getPrescriptions();
      _dashboardFuture = _repository.getDashboardData();
      _sharesFuture = _repository.getShares();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أرشيفي الطبي والسجلات'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.event_note_rounded, size: 20), text: 'المواعيد'),
            Tab(icon: Icon(Icons.receipt_long_rounded, size: 20), text: 'الوصفات'),
            Tab(icon: Icon(Icons.folder_shared_rounded, size: 20), text: 'الأشعة والتحاليل'),
            Tab(icon: Icon(Icons.share_rounded, size: 20), text: 'مشاركة ملفي'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsTab(theme),
          _buildPrescriptionsTab(theme),
          _buildAttachmentsTab(theme),
          _buildSharesTab(theme),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: Appointments
  // ==========================================
  Widget _buildAppointmentsTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async => _loadAllData(),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}', style: const TextStyle(fontWeight: FontWeight.bold)));
          }

          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) {
            return const Center(child: Text('لا توجد مواعيد مسجلة حتى الآن.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              final docName = appt['doctor_name'] ?? 'طبيب';
              final spec = appt['specialization_name'] ?? '';
              final date = appt['appointment_date'] ?? '';
              final time = appt['appointment_time'] ?? '';
              final status = appt['status_name'] ?? 'مؤكد';
              final statusSlug = appt['status_slug'] ?? 'pending';
              final canCancel = appt['can_cancel'] == true;
              final isRated = appt['is_rated'] == true;
              final apptId = appt['appointment_id'] as int;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(docName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          _buildStatusBadge(status, statusSlug, theme),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(spec, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                      const SizedBox(height: 8),
                      Text('📅 $date  |  ⏰ $time', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (canCancel)
                            TextButton.icon(
                              icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                              label: const Text('إلغاء الموعد', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                              onPressed: () => _cancelAppointment(apptId),
                            ),
                          if (statusSlug == 'completed') ...[
                            if (isRated)
                              const Text('⭐ تم التقييم مسبقاً', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))
                            else
                              ElevatedButton.icon(
                                icon: const Icon(Icons.star_rate_rounded, size: 16),
                                label: const Text('تقييم الطبيب', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                onPressed: () => _openRatingDialog(apptId, docName),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 2: Prescriptions
  // ==========================================
  Widget _buildPrescriptionsTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async => _loadAllData(),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _prescriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final prescriptions = snapshot.data ?? [];
          if (prescriptions.isEmpty) {
            return const Center(child: Text('لا توجد وصفات طبية صادرة حتى الآن.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final rx = prescriptions[index];
              final rxId = rx['prescription_id'] as int;
              final code = rx['prescription_code'] ?? 'RX';
              final doc = rx['doctor_name'] ?? 'طبيب';
              final date = rx['formatted_date'] ?? '';
              final count = rx['total_medicines']?.toString() ?? '0';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE0F2FE),
                    child: Icon(Icons.medical_services_rounded, color: theme.colorScheme.primary),
                  ),
                  title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'monospace')),
                  subtitle: Text('$doc\n$date • $count أدوية موصوفة', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => _openPrescriptionDetailsModal(rxId),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 3: Attachments / Radiology & Labs
  // ==========================================
  Widget _buildAttachmentsTab(ThemeData theme) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};
        final attachments = (data['attachments'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        if (attachments.isEmpty) {
          return const Center(child: Text('لا توجد تقارير أشعة أو تحاليل مرفوعة لملفك.', style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            final att = attachments[index];
            final name = att['file_name'] ?? 'تقرير طبي';
            final doc = 'د. ${att['doc_first'] ?? ''} ${att['doc_last'] ?? ''}'.trim();
            final size = att['formatted_size'] ?? '';
            final date = att['created_at'] != null ? att['created_at'].toString().split(' ').first : '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade50,
                  child: const Icon(Icons.description_rounded, color: Colors.purple),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('بواسطة: $doc\n$date  |  الحجم: $size', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                isThreeLine: true,
                trailing: const Icon(Icons.download_rounded, color: Color(0xFF0284C7)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('رابط الملف: ${att['full_url']}'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 4: Medical Record Sharing
  // ==========================================
  Widget _buildSharesTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_link_rounded),
            label: const Text('مشاركة ملفي مع طبيب جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _openAddShareModal,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _sharesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final shares = snapshot.data ?? [];
              if (shares.isEmpty) {
                return const Center(child: Text('لا توجد مشاركات نشطة لملفك الطبي حالياً.', style: TextStyle(color: Colors.grey)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: shares.length,
                itemBuilder: (context, index) {
                  final share = shares[index];
                  final doc = share['doctor_name'] ?? 'طبيب';
                  final spec = share['specialization_name'] ?? '';
                  final type = share['share_type_ar'] ?? '';
                  final expiry = share['formatted_expiry'] ?? '';
                  final isActive = share['is_active'] == true;
                  final shareId = share['share_id'] as int;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(doc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isActive ? 'نشطة ومصرحة' : 'ملغية',
                                  style: TextStyle(color: isActive ? Colors.green.shade800 : Colors.red.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Text(spec, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                          const SizedBox(height: 6),
                          Text('نوع الصلاحية: $type  |  ينتهي: $expiry', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          if (isActive) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 16),
                                label: const Text('إلغاء الصلاحية فوراً', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                onPressed: () => _revokeShare(shareId),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Helper Actions & Dialogs
  // ==========================================
  void _openPrescriptionDetailsModal(int rxId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _repository.getPrescriptionDetails(rxId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Padding(padding: const EdgeInsets.all(24), child: Text('خطأ: ${snapshot.error}'));
            }

            final details = snapshot.data ?? {};
            final meds = (details['medicines'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, controller) {
                return ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 16),
                    Text('كود الوصفة: ${details['prescription_code']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    Text('المصدر: ${details['doctor_name']} (${details['specialization_name']})', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 20),
                    const Text('💊 الأدوية الموصوفة:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...meds.map((m) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          color: Colors.grey.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${m['trade_name']} (${m['form']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('الجرعة: ${m['dosage']}  |  التردد: ${m['frequency']}  |  المدة: ${m['duration']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                              ],
                            ),
                          ),
                        )),
                    if (details['instructions'] != null && details['instructions'].toString().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('نصائح الطبيب: ${details['instructions']}', style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _openRatingDialog(int apptId, String docName) {
    int selectedStars = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('تقييم $docName', style: const TextStyle(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(starIndex <= selectedStars ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 32),
                    onPressed: () => setDialogState(() => selectedStars = starIndex),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(labelText: 'اكتب مراجعتك (اختياري)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await _repository.rateDoctor(appointmentId: apptId, rating: selectedStars, reviewText: reviewController.text.trim());
                  _loadAllData();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ شكراً لك! تم تسجيل التقييم بنجاح.'), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('إرسال التقييم'),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelAppointment(int apptId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل أنت متأكد من إلغاء هذا الموعد الطبي؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('تراجع')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repository.cancelAppointment(apptId);
        _loadAllData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الموعد بنجاح.'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _revokeShare(int shareId) async {
    try {
      await _repository.revokeShare(shareId);
      _loadAllData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء مشاركة الملف الطبي فوراً.'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    }
  }

  void _openAddShareModal() async {
    int? selectedDoctorId;
    String shareType = 'temporary';
    String duration = '1_day';
    List<Map<String, dynamic>> doctors = [];

    try {
      final docResult = await _repository.getDoctors();
      doctors = (docResult['doctors'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (_) {}

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('مشاركة الملف الطبي مع طبيب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDoctorId,
                hint: const Text('اختر الطبيب المصرح له'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: doctors.map((d) => DropdownMenuItem<int>(value: d['doctor_id'] as int, child: Text(d['full_name'] ?? ''))).toList(),
                onChanged: (val) => setModalState(() => selectedDoctorId = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: shareType,
                decoration: const InputDecoration(labelText: 'نوع المشاركة', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'temporary', child: Text('مشاركة مؤقتة')),
                  DropdownMenuItem(value: 'permanent', child: Text('مشاركة دائمة')),
                ],
                onChanged: (val) => setModalState(() => shareType = val ?? 'temporary'),
              ),
              if (shareType == 'temporary') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: duration,
                  decoration: const InputDecoration(labelText: 'المدة الزمنية', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: '1_day', child: Text('يوم واحد')),
                    DropdownMenuItem(value: '1_week', child: Text('أسبوع كامل')),
                    DropdownMenuItem(value: '1_month', child: Text('شهر كامل')),
                  ],
                  onChanged: (val) => setModalState(() => duration = val ?? '1_day'),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedDoctorId == null
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        try {
                          await _repository.addShare(doctorId: selectedDoctorId!, shareType: shareType, duration: duration);
                          _loadAllData();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تمت مشاركة الملف الطبي بنجاح!'), backgroundColor: Colors.green));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
                        }
                      },
                child: const Text('تأكيد المشاركة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, String slug, ThemeData theme) {
    Color bg = Colors.orange.shade50;
    Color fg = Colors.orange.shade800;

    if (slug == 'confirmed') {
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade800;
    } else if (slug == 'completed') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
    } else if (slug == 'cancelled') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}