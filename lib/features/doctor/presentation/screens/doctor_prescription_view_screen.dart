import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Official Digital Medical Prescription View & PDF Screen
/// Matched 100% with the official live Prescription screenshot (RX-2026-43116)
class DoctorPrescriptionViewScreen extends StatelessWidget {
  final Map<String, dynamic>? prescriptionData;

  const DoctorPrescriptionViewScreen({super.key, this.prescriptionData});

  @override
  Widget build(BuildContext context) {
    final data = prescriptionData ?? {
      'rx_code': 'RX-2026-43116',
      'doctor_name': 'محمد جعفري',
      'specialty': 'طب وجراحة العيون',
      'license': '68674683',
      'clinic': 'عيادة طبيبي الخاصة الموحدة',
      'clinic_address': 'الجزائر العاصمة، الجزائر',
      'clinic_phone': '021000000',
      'patient_name': 'بلعربي الهادي',
      'mrn': 'MR-2026-00002',
      'dob': '2026-08-04',
      'blood_group': '+AB',
      'date': '2026-08-10 09:24',
      'drug_name': 'Doliprane (Tablet)',
      'generic': 'Paracétamol | تركيز: 1g',
      'dosage': '1 قرص قبل الأكل ثلاث مرات في اليوم',
      'duration': '15 يوم',
      'quantity': '2 علبة',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| معاينة الوصفة الرسمية', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // زر الطباعة وحفظ PDF العلوي المطابق للصورة
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print_rounded, size: 16, color: Colors.white),
                label: const Text('طباعة أو حفظ كـ PDF 🖨️', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('جاري إرسال الوصفة ${data['rx_code']} إلى الطابعة وتوليد ملف PDF المعتمد...', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ورقة الوصفة الطبية الرسمية (Medical Document Card)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الرمز الفريد
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Text('الرمز الفريد: ${data['rx_code']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ترويسة الطبيب والعيادة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الدكتور: ${data['doctor_name']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF065F46))),
                          Text(data['specialty'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          Text('رقم الرخصة المهنية: ${data['license']}', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Colors.grey.shade700)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(data['clinic'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                          Text(data['clinic_address'], style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey.shade600)),
                          Text('هاتف: ${data['clinic_phone']}', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // بطاقة بيانات المريض الزرقاء الفاتحة المطابقة للصورة
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الاسم الكامل للمريض: ${data['patient_name']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                            Text('الملف الطبي الموحد: ${data['mrn']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('تاريخ الميلاد: ${data['dob']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700)),
                            Text('فصيلة الدم: ${data['blood_group']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          ],
                        ),
                        const Divider(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('تاريخ تحرير الوصفة: ${data['date']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey.shade600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // رمز الوصفة ℞ وجدول الأدوية
                  const Row(
                    children: [
                      Text('℞', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // جدول الدواء المطابق للصورة
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // هيدر الجدول
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(7))),
                          child: const Row(
                            children: [
                              SizedBox(width: 24, child: Text('#', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11))),
                              Expanded(flex: 3, child: Text('العلاج والدواء', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11))),
                              Expanded(flex: 3, child: Text('الجرعة والتردد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11))),
                              Expanded(flex: 2, child: Text('المدة الزمنية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11))),
                              Expanded(flex: 2, child: Text('الكمية المطلوبة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11))),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // سطر الدواء
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 24, child: Text('1', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12))),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['drug_name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.textMain)),
                                    Text('المادة الفعالة: ${data['generic']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 9.5, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 3, child: Text(data['dosage'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600))),
                              Expanded(flex: 2, child: Text(data['duration'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(data['quantity'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // قسم الـ QR Code وتوقيع الطبيب
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('توقيع وختم الطبيب المعالج', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 28),
                          Container(width: 140, height: 1, color: Colors.grey.shade400),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('تحقق رقمياً من موثوقية هذه الوصفة', style: TextStyle(fontFamily: 'Cairo', fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const Text('TABIBI SECURE QR', style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF059669), width: 1.5)),
                            child: const Icon(Icons.qr_code_2_rounded, size: 54, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
