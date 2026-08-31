import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../data/patient_repository.dart';

/// TABIBI (طبيبي) - Ultra-Modern Glassmorphic Bento Search & Smart Booking Screen
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('دليل الأطباء', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| حجز المواعيد', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: AmbientLightBackground(
        child: Column(
          children: [
            // 1. شريط البحث والفلترة الزجاجي
            _buildSearchFilterBento(),

            // 2. قائمة بطاقات الأطباء التفاعلية
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3))
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 50),
                                const SizedBox(height: 12),
                                Text(_errorMessage!, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                ElevatedButton(onPressed: _fetchDoctors, child: const Text('إعادة المحاولة')),
                              ],
                            ),
                          ),
                        )
                      : _doctors.isEmpty
                          ? Center(
                              child: GlassBentoCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(24),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('🔍', style: TextStyle(fontSize: 36)),
                                    SizedBox(height: 10),
                                    Text(
                                      'لا يوجد أطباء مطابقين لمعايير البحث الحالية.',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              itemCount: _doctors.length,
                              itemBuilder: (context, index) {
                                return _buildDoctorBentoCard(_doctors[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterBento() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
      child: GlassBentoCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(16),
        enableGlow: true,
        glowColor: AppTheme.secondary,
        child: Column(
          children: [
            // حقل البحث بالاسم
            TextField(
              controller: _searchController,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'ابحث باسم الطبيب أو اللقب...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _fetchDoctors();
                  },
                ),
              ),
              onSubmitted: (_) => _fetchDoctors(),
            ),
            const SizedBox(height: 10),

            // فلاتر التخصص والولاية
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<int>(
                    value: _selectedSpecializationId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'التخصص الطبي',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('كل التخصصات', style: TextStyle(fontFamily: 'Cairo', fontSize: 12))),
                      ..._specializations.map((spec) {
                        return DropdownMenuItem(
                          value: spec['id'] as int,
                          child: Text(spec['name_ar'].toString(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
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
                  flex: 4,
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'المدينة / الولاية',
                      prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.secondary, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onSubmitted: (_) => _fetchDoctors(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_rounded, color: Colors.white, size: 20),
                    onPressed: _fetchDoctors,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorBentoCard(Map<String, dynamic> doc) {
    final docId = doc['doctor_id'] as int;
    final name = doc['full_name'] ?? 'طبيب معتمد';
    final spec = doc['specialization_name'] ?? '';
    final clinic = doc['clinic_name'] ?? 'عيادة طبيبي';
    final fee = doc['consultation_fee']?.toString() ?? '2000';
    final rating = doc['avg_rating']?.toString() ?? '0.0';
    final totalRatings = doc['total_ratings']?.toString() ?? '0';
    final exp = doc['experience_years']?.toString() ?? '0';

    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      enableGlow: true,
      glowColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text('👨‍⚕️', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textMain),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(rating, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87)),
                      ],
                    ),
                    Text('($totalRatings)', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.apartment_rounded, size: 16, color: AppTheme.secondary),
                  const SizedBox(width: 6),
                  Text(clinic, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text('$exp سنوات خبرة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                'تسعيرة الكشف: $fee د.ج',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // أزرار الإجراءات التفاعلية
          Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showDoctorDetailsModal(docId),
                  child: const Text('الملف والمراجعات', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month_rounded, size: 18, color: Colors.white),
                    label: const Text('حجز موعد 🗓️', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openSmartBookingModal(docId, name, spec),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDoctorDetailsModal(int doctorId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _repository.getDoctorDetails(doctorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              );
            }
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Text('حدث خطأ: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
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
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(22),
                    children: [
                      Center(
                        child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                      ),
                      const SizedBox(height: 18),
                      Text(details['full_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                      Text(details['specialization_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      const Text('🏥 أيام وأوقات العمل الأسبوعية للعيادة:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 8),
                      ...schedules.map((sch) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primary, size: 16),
                                const SizedBox(width: 6),
                                Text('${sch['day_name']}: من ${sch['start_time']} إلى ${sch['end_time']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 22),
                      Text('⭐ تقييمات وآراء المرضى (${reviews.length}):', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 10),
                      if (reviews.isEmpty)
                        const Text('لا توجد مراجعات مكتوبة بعد.', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey))
                      else
                        ...reviews.map((rev) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(rev['patient_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('⭐ ${rev['rating']}', style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  if (rev['review_text'] != null && rev['review_text'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(rev['review_text'], style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade700)),
                                    ),
                                ],
                              ),
                            )),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _openSmartBookingModal(int doctorId, String docName, String spec) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SmartBookingDialog(
        doctorId: doctorId,
        doctorName: docName,
        specialization: spec,
        repository: _repository,
      ),
    );
  }
}

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
        const SnackBar(content: Text('يرجى اختيار التاريخ وتحديد الوقت المتاح.', style: TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating),
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
            content: Text('✅ تم حجز وتأكيد موعدك الطبي بنجاح! ستتلقى إشعاراً بالتفاصيل.', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            Text('حجز موعد عيادي مع ${widget.doctorName}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
            Text(widget.specialization, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),

            // زر اختيار التاريخ
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 20),
              label: Text(
                _selectedDate == null
                    ? 'اضغط لاختيار تاريخ الموعد 📅'
                    : 'التاريخ المختار: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 14),

            // عرض الفترات الشاغرة
            if (_loadingSlots)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.primary)))
            else if (_slotError != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                child: Text(_slotError!, style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              )
            else if (_availableSlots.isNotEmpty) ...[
              const Text('اختر التوقيت المتاح الشاغر:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textMain)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textMain)),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (selected) {
                      setState(() => _selectedTimeSlot = selected ? slot : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'سبب الزيارة أو الأعراض (اختياري)',
                  hintText: 'اكتب نبذة لمساعدة الطبيب...',
                ),
              ),
            ],

            const SizedBox(height: 22),
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton(
                onPressed: (_submitting || _selectedTimeSlot == null) ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('تأكيد حجز الموعد الطبي 🚀', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
