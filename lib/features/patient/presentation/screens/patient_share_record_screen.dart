import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Modern Patient Medical Record Sharing & Granular Permissions Screen
/// Matched 100% with the official Share Record screenshot (Image 4)
class PatientShareRecordScreen extends StatefulWidget {
  const PatientShareRecordScreen({super.key});

  @override
  State<PatientShareRecordScreen> createState() => _PatientShareRecordScreenState();
}

class _PatientShareRecordScreenState extends State<PatientShareRecordScreen> {
  String _selectedDoctor = 'د. محمد جعفري (طب وجراحة العيون)';
  String _shareDurationType = 'مشاركة مؤقتة (تنتهي تلقائياً)';
  String _temporaryPeriod = 'يوم واحد فقط';

  // تخصيص الصلاحيات الأربعة المطابقة للصورة رقم 4
  bool _permVisits = true;
  bool _permPrescriptions = true;
  bool _permVitals = true;
  bool _permAttachments = true;

  final List<String> _doctors = [
    'د. محمد جعفري (طب وجراحة العيون)',
    'د. محمد بلعربي (أمراض القلب والشرايين)',
    'د. فلسطيني صحي (طب عام)',
  ];

  final List<String> _durationTypes = [
    'مشاركة مؤقتة (تنتهي تلقائياً)',
    'مشاركة دائمة ومفتوحة',
  ];

  final List<String> _tempPeriods = [
    'يوم واحد فقط',
    '3 أيام',
    'أسبوع كامل (7 أيام)',
    'شهر واحد (30 يوماً)',
  ];

  // سجل العمليات المسجلة
  final List<Map<String, dynamic>> _activeShares = [];

  void _submitShare() {
    final docName = _selectedDoctor.split(' (')[0];
    final isTemp = _shareDurationType.contains('مؤقتة');

    setState(() {
      _activeShares.insert(0, {
        'id': _activeShares.length + 1,
        'doctor': docName,
        'type': isTemp ? 'مؤقتة ($_temporaryPeriod)' : 'مشاركة دائمة',
        'permissions': [
          if (_permVisits) 'الزيارات',
          if (_permPrescriptions) 'الوصفات',
          if (_permVitals) 'العلامات الحيوية',
          if (_permAttachments) 'الأشعة والتحاليل',
        ].join('، '),
        'created_at': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت مشاركة وتشفير أذونات ملفك الطبي مع $docName بنجاح! 🤝', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _revokeShare(int index) {
    final item = _activeShares[index];
    setState(() {
      _activeShares.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إلغاء وسحب صلاحية مشاركة الملف الطبي مع ${item['doctor']} فوراً.', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTemp = _shareDurationType.contains('مؤقتة');

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| مشاركة الملف الطبي', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              // 1. بطاقة نموذج مشاركة الملف الطبي مع طبيب جديد
              _buildShareFormCard(isTemp),
              const SizedBox(height: 24),

              // 2. سجل مشاركات الملف الطبي الفعالة والسابقة
              _buildSectionTitle('📋 سجل مشاركات الملف الطبي الفعالة والسابقة (${_activeShares.length})'),
              const SizedBox(height: 10),
              _buildActiveSharesList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareFormCard(bool isTemp) {
    return GlassBentoCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      enableGlow: true,
      glowColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🤝', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'مشاركة الملف الطبي مع طبيب جديد',
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF065F46)),
              ),
            ],
          ),
          const Divider(height: 18),

          // اختيار الطبيب المصرح له
          DropdownButtonFormField<String>(
            value: _selectedDoctor,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'اختر الطبيب المصرح له *', prefixIcon: Icon(Icons.person_search_rounded, size: 20)),
            items: _doctors
                .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12), overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _selectedDoctor = v ?? _selectedDoctor),
          ),
          const SizedBox(height: 12),

          // مدة صلاحية المشاركة
          DropdownButtonFormField<String>(
            value: _shareDurationType,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'مدة صلاحية المشاركة *', prefixIcon: Icon(Icons.timer_outlined, size: 20)),
            items: _durationTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12))))
                .toList(),
            onChanged: (v) => setState(() => _shareDurationType = v ?? _shareDurationType),
          ),
          const SizedBox(height: 12),

          // فترة الصلاحية المؤقتة (تظهر فقط عند اختيار مشاركة مؤقتة)
          if (isTemp) ...[
            DropdownButtonFormField<String>(
              value: _temporaryPeriod,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'فترة الصلاحية المؤقتة', prefixIcon: Icon(Icons.hourglass_bottom_rounded, size: 20)),
              items: _tempPeriods
                  .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12))))
                  .toList(),
              onChanged: (v) => setState(() => _temporaryPeriod = v ?? _temporaryPeriod),
            ),
            const SizedBox(height: 16),
          ],

          // تخصيص صلاحيات الملف المشارك (المطابقة للصورة رقم 4)
          const Text('تخصيص صلاحيات الملف المشارك:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMain)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('سجل الزيارات والفحوصات', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                  value: _permVisits,
                  activeColor: const Color(0xFF059669),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _permVisits = v ?? false),
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('الوصفات الرقمية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                  value: _permPrescriptions,
                  activeColor: const Color(0xFF059669),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _permPrescriptions = v ?? false),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('العلامات الحيوية التاريخية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                  value: _permVitals,
                  activeColor: const Color(0xFF059669),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _permVitals = v ?? false),
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('الأشعة والتحاليل الطبية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                  value: _permAttachments,
                  activeColor: const Color(0xFF059669),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _permAttachments = v ?? false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // زر مشاركة الملف الطبي الموحد
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF047857)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: const Color(0xFF059669).withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
              label: const Text('مشاركة الملف الطبي الموحد 🤝', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              onPressed: _submitShare,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSharesList() {
    if (_activeShares.isEmpty) {
      return GlassBentoCard(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: const Center(
          child: Text('لا توجد أي عمليات مشاركة مسجلة لملفك الطبي حالياً.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 11.5, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      children: List.generate(_activeShares.length, (index) {
        final share = _activeShares[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: GlassBentoCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), shape: BoxShape.circle),
                  child: const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(share['doctor'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textMain)),
                      Text('${share['type']} • ${share['created_at']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('الصلاحيات: ${share['permissions']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                  tooltip: 'إلغاء وسحب الصلاحية',
                  onPressed: () => _revokeShare(index),
                ),
              ],
            ),
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
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
      ],
    );
  }
}
