import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../../auth/logic/auth_bloc.dart';

class AssistantDashboardScreen extends StatefulWidget {
  const AssistantDashboardScreen({super.key});

  @override
  State<AssistantDashboardScreen> createState() => _AssistantDashboardScreenState();
}

class _AssistantDashboardScreenState extends State<AssistantDashboardScreen> {
  final _newFirstNameCtrl = TextEditingController();
  final _newLastNameCtrl = TextEditingController();
  final _newPhoneCtrl = TextEditingController();

  final List<Map<String, dynamic>> _dailyQueue = [
    {'queue_no': 1, 'name': 'بلعربي الهادي', 'mrn': 'MR-2026-00002', 'doctor': 'د. محمد جعفري', 'status': 'completed', 'fee_amount': '2000', 'paid_amount': '2000.00', 'is_paid': true},
    {'queue_no': 2, 'name': 'محمد بلعربي', 'mrn': 'MR-2026-00014', 'doctor': 'د. محمد بلعربي', 'status': 'in_consultation', 'fee_amount': '2000', 'paid_amount': null, 'is_paid': false},
  ];

  @override
  void dispose() {
    _newFirstNameCtrl.dispose();
    _newLastNameCtrl.dispose();
    _newPhoneCtrl.dispose();
    super.dispose();
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
            Text('| بوابة الاستقبال والفوترة', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar_rounded, color: AppTheme.primary),
            tooltip: 'المكتبة 3D وتشريح الإنسان',
            onPressed: () => context.push('/anatomy-3d'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () {
              context.read<AuthCubit>().logout();
              context.go('/landing');
            },
          ),
        ],
      ),
      body: AmbientLightBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // زر الوصول السريع للمكتبة ثلاثية الأبعاد
              GlassBentoCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                onTap: () => context.push('/anatomy-3d'),
                enableGlow: true,
                glowColor: const Color(0xFF6366F1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: const Text('🩻', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المكتبة الطبية 3D وأطلس تشريح الإنسان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textMain)),
                          Text('الوصول لمجسمات الأعضاء والتشريح التفاعلي', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // طابور الانتظار
              Row(
                children: [
                  Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  const Text('🚶 طابور وحالة الانتظار والتحصيل المالي لليوم', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                ],
              ),
              const SizedBox(height: 10),
              ...List.generate(_dailyQueue.length, (index) {
                final q = _dailyQueue[index];
                final isPaid = q['is_paid'] == true;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GlassBentoCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('#${q['queue_no']} - ${q['name']}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13)),
                            Text('${q['mrn']} • ${q['doctor']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, color: Colors.grey.shade600)),
                          ],
                        ),
                        Text(isPaid ? 'تم دفع 2000 د.ج 🟢' : 'بانتظار الدفع 🟠', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.orange)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
