import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../logic/auth_bloc.dart';
import '../../logic/auth_state.dart';

/// TABIBI (طبيبي) - Ultra-Modern Patient Registration Screen
/// Matched 100% with the official registration form screenshot
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _securityAnswerCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _gender = 'male';
  DateTime? _selectedDob = DateTime(1995, 5, 15);
  String _bloodGroup = 'unknown';
  String _securityQuestion = 'ما هو اسم مدرستك الابتدائية الأولى؟';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _securityQuestionsList = [
    'ما هو اسم مدرستك الابتدائية الأولى؟',
    'ما هو اسم أول حيوان أليف قمت بتربيته؟',
    'في أي مدينة أو ولاية ولد والداك؟',
    'ما هي وجبتك أو أكلتك المفضلة؟',
    'ما هو اسم صديق طفولتك المفضل؟',
  ];

  final List<Map<String, String>> _bloodGroupsList = [
    {'value': 'unknown', 'label': 'لا أعلم... (غير معروفة)'},
    {'value': 'A+', 'label': 'A+ (موجب)'},
    {'value': 'A-', 'label': 'A- (سالب)'},
    {'value': 'B+', 'label': 'B+ (موجب)'},
    {'value': 'B-', 'label': 'B- (سالب)'},
    {'value': 'AB+', 'label': 'AB+ (موجب)'},
    {'value': 'AB-', 'label': 'AB- (سالب)'},
    {'value': 'O+', 'label': 'O+ (موجب)'},
    {'value': 'O-', 'label': 'O- (سالب)'},
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalIdCtrl.dispose();
    _securityAnswerCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1998, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  void _onRegisterSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور وتأكيدها غير متطابقين.', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final dobStr = _selectedDob != null
        ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
        : '1995-01-01';

    context.read<AuthCubit>().register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      dateOfBirth: dobStr,
      nationalId: _nationalIdCtrl.text.trim().isEmpty ? null : _nationalIdCtrl.text.trim(),
      bloodGroup: _bloodGroup,
      securityQuestion: _securityQuestion,
      securityAnswer: _securityAnswerCtrl.text.trim().toLowerCase(),
      password: _passwordCtrl.text,
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
            Text('| فتح حساب مريض', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: AmbientLightBackground(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنشاء ملفك الطبي الموحد بنجاح! مرحباً بك.', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  backgroundColor: AppTheme.primary,
                ),
              );
              context.go('/patient-home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // بطاقة الهيدر والعنوان
                    _buildFormHeader(),
                    const SizedBox(height: 16),

                    // بطاقة النموذج الزجاجية
                    GlassBentoCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. الاسم الأول واللقب
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameCtrl,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                  decoration: const InputDecoration(labelText: 'الاسم الأول *', hintText: 'أحمد'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameCtrl,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                  decoration: const InputDecoration(labelText: 'اللقب (العائلة) *', hintText: 'بن علي'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 2. البريد الإلكتروني ورقم الهاتف
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني *', hintText: 'ahmed@mail.dz'),
                                  validator: (v) => (v == null || !v.contains('@')) ? 'بريد غير صحيح' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                  decoration: const InputDecoration(labelText: 'رقم الهاتف *', hintText: '0550123456'),
                                  validator: (v) => (v == null || v.trim().length < 9) ? 'رقم غير صحيح' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 3. الجنس وتاريخ الميلاد
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: const InputDecoration(labelText: 'الجنس *'),
                                  items: const [
                                    DropdownMenuItem(value: 'male', child: Text('ذكر', style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
                                    DropdownMenuItem(value: 'female', child: Text('أنثى', style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
                                  ],
                                  onChanged: (v) => setState(() => _gender = v ?? 'male'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: _pickDateOfBirth,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'تاريخ الميلاد *',
                                      suffixIcon: Icon(Icons.calendar_month_rounded, size: 20, color: AppTheme.primary),
                                    ),
                                    child: Text(
                                      _selectedDob != null
                                          ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
                                          : 'اختر التاريخ...',
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 4. رقم التعريف الوطني وفصيلة الدم
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nationalIdCtrl,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                  decoration: const InputDecoration(
                                    labelText: 'رقم التعريف الوطني (اختياري)',
                                    hintText: 'رقم بطاقة التعريف البيومترية',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _bloodGroup,
                                  isExpanded: true,
                                  decoration: const InputDecoration(labelText: 'فصيلة الدم (اختياري)'),
                                  items: _bloodGroupsList
                                      .map((bg) => DropdownMenuItem(
                                            value: bg['value'],
                                            child: Text(bg['label']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(() => _bloodGroup = v ?? 'unknown'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 5. سؤال الأمان لاسترجاع الحساب
                          DropdownButtonFormField<String>(
                            value: _securityQuestion,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'سؤال الأمان (لاسترجاع كلمة المرور) *'),
                            items: _securityQuestionsList
                                .map((q) => DropdownMenuItem(
                                      value: q,
                                      child: Text(q, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12), overflow: TextOverflow.ellipsis),
                                    ))
                                .toList>,
                            onChanged: (v) => setState(() => _securityQuestion = v ?? _securityQuestionsList[0]),
                          ),
                          const SizedBox(height: 14),

                          // 6. إجابة سؤال الأمان
                          TextFormField(
                            controller: _securityAnswerCtrl,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'إجابة سؤال الأمان *',
                              hintText: 'اكتب إجابتك السرية هنا بوضوح...',
                              prefixIcon: Icon(Icons.key_rounded, size: 20),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى كتابة إجابة سؤال الأمان' : null,
                          ),
                          const SizedBox(height: 14),

                          // 7. كلمة المرور وتأكيدها
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور *',
                                    hintText: 'حد أدنى 8 خانات',
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.length < 6) ? '6 خانات على الأقل' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _confirmPasswordCtrl,
                                  obscureText: _obscureConfirmPassword,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'تأكيد كلمة المرور *',
                                    hintText: 'أعد كتابة الرمز',
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'يرجى التأكيد' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 8. زر تأكيد وإنشاء الملف الطبي الموحد
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: isLoading ? null : _onRegisterSubmit,
                              child: isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text(
                                      'تأكيد وإنشاء الملف الطبي الموحد',
                                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 9. رابط العودة لتسجيل الدخول
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('تمتلك حساب مريض بالفعل؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textMuted)),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text('سجل دخولك هنا', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primary)),
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
          },
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primary, size: 36),
        ),
        const SizedBox(height: 10),
        const Text(
          'إنشاء حساب جديد',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'أنشئ ملفاً طبياً موحداً خاصاً بك لحجز المواعيد واستقبال الوصفات الرقمية',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
