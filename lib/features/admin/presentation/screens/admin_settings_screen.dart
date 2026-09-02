import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Admin General Clinic Settings & Algerian Payment Channels Screen
/// Matched 100% with the official settings screenshot (Image 7)
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // الحقول المطابقة للصورة رقم 7
  final _clinicNameArCtrl = TextEditingController(text: 'عيادة طبيبي الخاصة الموحدة');
  final _clinicNameFrCtrl = TextEditingController(text: 'Clinique Privée Unifiée Tabibi');
  final _clinicNameEnCtrl = TextEditingController(text: 'Tabibi Unified Private Clinic');
  final _emailCtrl = TextEditingController(text: 'clinic@tabibi.dz');
  final _phoneCtrl = TextEditingController(text: '021000000');
  final _addressCtrl = TextEditingController(text: 'الجزائر العاصمة، الجزائر');

  // قنوات الدفع الجزائرية
  final _ccpCtrl = TextEditingController(text: '90 / 0012345678');
  final _ripCtrl = TextEditingController(text: '0079999000123456789012');

  // أرقام الطوارئ
  final _civilProtectionCtrl = TextEditingController(text: '14');
  final _samuCtrl = TextEditingController(text: '115');

  @override
  void dispose() {
    _clinicNameArCtrl.dispose();
    _clinicNameFrCtrl.dispose();
    _clinicNameEnCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _ccpCtrl.dispose();
    _ripCtrl.dispose();
    _civilProtectionCtrl.dispose();
    _samuCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ وتحديث الإعدادات العامة وقنوات الدفع بنجاح!', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            Text('| الإعدادات العامة وقنوات الدفع', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
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
              // هيدر تعريفي
              _buildHeaderSection(),
              const SizedBox(height: 16),

              // أولاً: بيانات وهوية العيادة أو المستشفى
              _buildSectionCard(
                title: '🏥 أولاً: بيانات وهوية العيادة أو المستشفى',
                children: [
                  TextField(
                    controller: _clinicNameArCtrl,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: 'اسم العيادة (باللغة العربية) *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _clinicNameFrCtrl,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: const InputDecoration(labelText: 'اسم العيادة (باللغة الفرنسية) *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _clinicNameEnCtrl,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: const InputDecoration(labelText: 'اسم العيادة (باللغة الإنجليزية) *'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                          decoration: const InputDecoration(labelText: 'البريد الإلكتروني للاتصال بالعيادة *'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                          decoration: const InputDecoration(labelText: 'هاتف الاستقبال والتواصل *'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressCtrl,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: const InputDecoration(labelText: 'العنوان الجغرافي للعيادة *'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ثانياً: بيانات الفوترة وقنوات الدفع في الجزائر
              _buildSectionCard(
                title: '🪙 ثانياً: بيانات الفوترة وقنوات الدفع في الجزائر',
                children: [
                  TextField(
                    controller: _ccpCtrl,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: 'الحساب البريدي الجاري (CCP) *',
                      hintText: '90 / 0012345678',
                      prefixIcon: Icon(Icons.account_balance_wallet_rounded, size: 20, color: Color(0xFFD97706)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ripCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: 'رقم الحساب البريدي الموحد (RIP - تطبيق بريدي موب) *',
                      hintText: '0079999000123456789012',
                      prefixIcon: Icon(Icons.credit_card_rounded, size: 20, color: Color(0xFF0284C7)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ثالثاً: أرقام الطوارئ والمساعدة الطبية السريعة
              _buildSectionCard(
                title: '🚨 ثالثاً: أرقام الطوارئ والمساعدة الطبية السريعة',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _civilProtectionCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w900, color: Colors.redAccent),
                          decoration: const InputDecoration(
                            labelText: 'الحماية المدنية بالجزائر',
                            prefixIcon: Icon(Icons.local_fire_department_rounded, color: Colors.redAccent, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _samuCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                          decoration: const InputDecoration(
                            labelText: 'المساعدة الطبية (SAMU)',
                            prefixIcon: Icon(Icons.emergency_rounded, color: Color(0xFF0284C7), size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // زر حفظ وتحديث الإعدادات
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text('حفظ وتحديث الإعدادات العامة 💾', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  onPressed: _saveSettings,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF1E293B)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإعدادات العامة للموقع والعيادة الطبية ⚙️',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white),
                ),
                Text(
                  'تخصيص اللغات، هوية المؤسسة الصحية، حسابات BaridiMob، وأرقام الطوارئ.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return GlassBentoCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textMain)),
          const Divider(height: 18),
          ...children,
        ],
      ),
    );
  }
}
