import 'package:flutter/material.dart';
import '../../data/patient_repository.dart';

/// TABIBI (طبيبي) - Search Doctors & Smart Appointment Booking Screen
class SearchAndBookScreen extends StatefulWidget {
  const SearchAndBookScreen({super.key});

  @override
  State<SearchAndBookScreen> createState() => _SearchAndBookScreenState();
}

class _SearchAndBookScreenState extends State<SearchAndBookScreen> {
  final PatientRepository _repository = PatientRepository();
  final _searchController = TextEditingController();
  final _cityController = TextEditingController();

  int? _selectedSpecializationId;
  List<Map<String, dynamic>> _specializations = [];
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getDoctors(
        name: _searchController.text.trim(),
        specializationId: _selectedSpecializationId,
        city: _cityController.text.trim(),
      );

      final rawSpecs = (result['specializations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final rawDocs = (result['doctors'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      setState(() {
        _specializations = rawSpecs;
        _doctors = rawDocs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الأطباء وحجز المواعيد'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. قسم الفلاتر والبحث
          _buildSearchFilterSection(theme),

          // 2. قائمة الأطباء الناتجة
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 12),
                            Text(_errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _fetchDoctors, child: const Text('إعادة المحاولة')),
                          ],
                        ),
                      )
                    : _doctors.isEmpty
                        ? const Center(
                            child: Text(
                              'لا يوجد أطباء مطابقين لمعايير البحث الحالية.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _doctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(theme, _doctors[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط البحث بالاسم
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث باسم الطبيب...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _fetchDoctors();
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onSubmitted: (_) => _fetchDoctors(),
          ),
          const SizedBox(height: 10),

          // فلاتر التخصص والولاية
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedSpecializationId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'التخصص',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('كل التخصصات')),
                    ..._specializations.map((spec) {
                      return DropdownMenuItem(
                        value: spec['id'] as int,
                        child: Text(spec['name_ar'].toString(), overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedSpecializationId = val);
                    _fetchDoctors();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'المدينة / الولاية',
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onSubmitted: (_) => _fetchDoctors(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _fetchDoctors,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.filter_list_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(ThemeData theme, Map<String, dynamic> doc) {
    final docId = doc['doctor_id'] as int;
    final name = doc['full_name'] ?? 'طبيب معتمد';
    final spec = doc['specialization_name'] ?? '';
    final clinic = doc['clinic_name'] ?? 'عيادة طبيبي';
    final fee = doc['consultation_fee']?.toString() ?? '2000';
    final rating = doc['avg_rating']?.toString() ?? '0.0';
    final totalRatings = doc['total_ratings']?.toString() ?? '0';
    final exp = doc['experience_years']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: const Text('👨‍⚕️', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(spec, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Text('($totalRatings تقييم)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(clinic, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.work_history_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$exp سنوات خبرة', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('سعر الكشفية: $fee د.ج', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(height: 14),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    label: const Text('الملف والمراجعات'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showDoctorDetailsModal(docId),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: const Text('حجز موعد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _openSmartBookingModal(docId, name, spec),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// نافذة تفاصيل بروفايل الطبيب والمراجعات
  void _showDoctorDetailsModal(int doctorId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _repository.getDoctorDetails(doctorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('حدث خطأ: ${snapshot.error}', textAlign: TextAlign.center),
              );
            }

            final details = snapshot.data ?? {};
            final reviews = (details['reviews'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            final schedules = (details['work_schedules'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(details['full_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(details['specialization_name'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 16),
                    const Text('🏥 أيام وأوقات العمل الأسبوعية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...schedules.map((sch) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• ${sch['day_name']}: من ${sch['start_time']} إلى ${sch['end_time']}', style: const TextStyle(fontSize: 12)),
                        )),
                    const SizedBox(height: 20),
                    Text('⭐ آراء المرضى (${reviews.length}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    if (reviews.isEmpty)
                      const Text('لا توجد مراجعات مكتوبة بعد.', style: TextStyle(fontSize: 12, color: Colors.grey))
                    else
                      ...reviews.map((rev) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(rev['patient_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text('⭐ ${rev['rating']}', style: const TextStyle(fontSize: 12, color: Colors.amber)),
                                  ],
                                ),
                                if (rev['review_text'] != null && rev['review_text'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(rev['review_text'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                  ),
                              ],
                            ),
                          )),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// نافذة حجز الموعد الذكي التفاعلية
  void _openSmartBookingModal(int doctorId, String docName, String spec) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _SmartBookingDialog(
        doctorId: doctorId,
        doctorName: docName,
        specialization: spec,
        repository: _repository,
      ),
    );
  }
}

/// ودجت حجز الموعد وتوليد الفترات
class _SmartBookingDialog extends StatefulWidget {
  final int doctorId;
  final String doctorName;
  final String specialization;
  final PatientRepository repository;

  const _SmartBookingDialog({
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.repository,
  });

  @override
  State<_SmartBookingDialog> createState() => _SmartBookingDialogState();
}

class _SmartBookingDialogState extends State<_SmartBookingDialog> {
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  bool _submitting = false;
  String? _slotError;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
        _availableSlots = [];
        _slotError = null;
        _loadingSlots = true;
      });

      final dateStr = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      try {
        final slots = await widget.repository.getAvailableSlots(
          doctorId: widget.doctorId,
          date: dateStr,
        );
        setState(() {
          _availableSlots = slots;
          _loadingSlots = false;
        });
      } catch (e) {
        setState(() {
          _slotError = e.toString();
          _loadingSlots = false;
        });
      }
    }
  }

  void _submitBooking() async {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد التاريخ واختيار وقت الموعد.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    try {
      await widget.repository.bookAppointment(
        doctorId: widget.doctorId,
        appointmentDate: dateStr,
        appointmentTime: "$_selectedTimeSlot:00",
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تسجيل وتأكيد طلب حجز موعدك بنجاح!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('حجز موعد مع ${widget.doctorName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.specialization, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
            const SizedBox(height: 16),

            // زر اختيار التاريخ
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text(_selectedDate == null
                  ? 'اختر تاريخ الموعد 📅'
                  : 'التاريخ: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 12),

            // عرض الفترات المتاحة
            if (_loadingSlots)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            else if (_slotError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(_slotError!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              )
            else if (_availableSlots.isNotEmpty) ...[
              const Text('اختر الوقت المتاح:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    onSelected: (selected) {
                      setState(() => _selectedTimeSlot = selected ? slot : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'سبب الزيارة أو الأعراض (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_submitting || _selectedTimeSlot == null) ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('تأكيد حجز الموعد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}