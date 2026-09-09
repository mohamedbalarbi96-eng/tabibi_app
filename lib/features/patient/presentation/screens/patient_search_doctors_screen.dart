import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Modern Doctor Search, Direct Google Maps & Ratings Screen
class PatientSearchDoctorsScreen extends StatefulWidget {
  const PatientSearchDoctorsScreen({super.key});

  @override
  State<PatientSearchDoctorsScreen> createState() => _PatientSearchDoctorsScreenState();
}

class _PatientSearchDoctorsScreenState extends State<PatientSearchDoctorsScreen> {
  final TextEditingController _nameFilterCtrl = TextEditingController();
  final TextEditingController _cityFilterCtrl = TextEditingController();

  String _selectedSpecialty = 'كل التخصصات...';

  final List<String> _specialties = [
    'كل التخصصات...',
    'طب عام',
    'أمراض القلب والشرايين',
    'طب وجراحة العيون',
    'طب الأطفال وحديثي الولادة',
    'جراحة العظام والمفاصل',
    'أمراض النساء والتوليد',
    'طب وجراحة الأسنان',
    'أمراض الجلد والحساسية',
    'أمراض الأنف والأذن والحنجرة (ORL)',
    'أمراض الكلى والمسالك البولية',
    'الغدد الصماء والسكري',
    'جراحة المخ والأعصاب',
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 1,
      'name': 'د. محمد جعفري',
      'specialty': 'طب وجراحة العيون',
      'rating': 0.0,
      'reviews_count': 0,
      'experience': '10 سنوات',
      'clinic': 'عيادة طبيبي الخاصة الموحدة',
      'address': 'الجزائر العاصمة، الجزائر',
      'fee': '2,000.00',
      'phone': '568988',
      'has_map': true,
      'map_url': 'https://maps.google.com/?q=36.7538,3.0588',
    },
    {
      'id': 2,
      'name': 'د. محمد بلعربي',
      'specialty': 'أمراض القلب والشرايين',
      'rating': 0.0,
      'reviews_count': 0,
      'experience': '10 سنوات',
      'clinic': 'عيادة طبيبي التخصصية',
      'address': 'الجزائر',
      'fee': '2,000.00',
      'phone': '0556612',
      'has_map': true,
      'map_url': 'https://maps.app.goo.gl/UpY2NWv9NcdoRHfC8',
    },
    {
      'id': 3,
      'name': 'د. فلسطيني صحي',
      'specialty': 'طب عام',
      'rating': 0.0,
      'reviews_count': 0,
      'experience': '10 سنوات',
      'clinic': 'عيادة طبيبي التخصصية',
      'address': 'الجزائر',
      'fee': '2,000.00',
      'phone': '066587696',
      'has_map': true,
      'map_url': 'https://maps.google.com/?q=35.6970,-0.6330',
    },
  ];

  @override
  void dispose() {
    _nameFilterCtrl.dispose();
    _cityFilterCtrl.dispose();
    super.dispose();
  }

  // فتح موقع الطبيب على خرائط Google Maps مباشرة
  Future<void> _openGoogleMapsDirectly(Map<String, dynamic> doc) async {
    final String url = doc['map_url'] ?? 'https://maps.google.com/?q=${doc['address']}';
    final Uri uri = Uri.parse(url);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جاري فتح موقع العيادة لـ ${doc['name']} على خرائط Google Maps...', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDoctorProfileAndRate(Map<String, dynamic> doc) {
    double tempRating = doc['rating'] == 0.0 ? 5.0 : doc['rating'];
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(doc['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                Text('${doc['specialty']}  •  ${doc['clinic']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                Text('العنوان: ${doc['address']}  •  هاتف: ${doc['phone']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
                const Divider(height: 20),
                const Text('⭐ تقييم الطبيب ومراجعة السلوك والأداء الطبي:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIdx) {
                    return IconButton(
                      icon: Icon(
                        starIdx < tempRating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 32,
                      ),
                      onPressed: () => setModalState(() => tempRating = (starIdx + 1).toDouble()),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'اكتب تعليقك أو رأيك في الطبيب (ليراه الجميع)',
                    hintText: 'طبيب ممتاز وخلوق واستماع دقيق للأعراض...',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                  label: const Text('إرسال التقييم ونشره للعامة ⭐', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('شكراً لك! تم تسجيل تقييمك ($tempRating نجوم) للطبيب ${doc['name']} بنجاح.', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _doctors.where((d) {
      final name = d['name'].toString().toLowerCase();
      final spec = d['specialty'].toString().toLowerCase();
      final addr = d['address'].toString().toLowerCase();

      final nameQ = _nameFilterCtrl.text.trim().toLowerCase();
      final cityQ = _cityFilterCtrl.text.trim().toLowerCase();

      final matchName = nameQ.isEmpty || name.contains(nameQ);
      final matchCity = cityQ.isEmpty || addr.contains(cityQ);
      final matchSpec = _selectedSpecialty == 'كل التخصصات...' || spec == _selectedSpecialty.toLowerCase();

      return matchName && matchCity && matchSpec;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| دليل وبحث الأطباء', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              _buildSearchFilterCard(),
              const SizedBox(height: 18),
              ...List.generate(filtered.length, (i) => _buildDoctorDirectoryCard(filtered[i])),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilterCard() {
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
                  controller: _nameFilterCtrl,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                  decoration: const InputDecoration(labelText: 'اسم الطبيب', hintText: 'مثال: محمد، سارة...'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'التخصص الطبي'),
                  items: _specialties
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11), overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSpecialty = v ?? 'كل التخصصات...'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityFilterCtrl,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                  decoration: const InputDecoration(labelText: 'المدينة أو الولاية', hintText: 'مثال: الجزائر، وهران، سطيف...'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search_rounded, size: 16, color: Colors.white),
                  label: const Text('البحث 🔍', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDirectoryCard(Map<String, dynamic> doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: GlassBentoCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(16),
        enableGlow: true,
        glowColor: AppTheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFE0F2FE),
                  child: Text('👨‍⚕️', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14.5, color: AppTheme.textMain)),
                      Text(doc['specialty'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text('⭐ ${doc['rating']} (${doc['reviews_count']} تقييم)', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Text('💼 خبرة: ${doc['experience']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
            Text('📍 العيادة: ${doc['clinic']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
            Text('🏢 العنوان: ${doc['address']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🪙 كشفية: ${doc['fee']} د.ج', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                Text('📞 هاتف: ${doc['phone']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.secondary),
                      label: const Text('عرض الملف الشخصي 👤', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.secondary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _showDoctorProfileAndRate(doc),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.white),
                      label: const Text('حجز موعد 📅', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => context.push('/patient-book-appointment', extra: doc),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.white),
                      label: const Text('إرسال رسالة 💬', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => context.push('/doctor-chat'),
                    ),
                  ),
                ),
              ],
            ),
            if (doc['has_map'] == true) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
                  label: const Text('فتح موقع العيادة على خرائط Google Maps 🗺️', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 1,
                  ),
                  onPressed: () => _openGoogleMapsDirectly(doc),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
