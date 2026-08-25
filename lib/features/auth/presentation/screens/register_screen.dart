import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth_bloc.dart';

/// TABIBI (طبيبي) - Full Patient Registration Screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedGender = 'male';
  String? _selectedBloodGroup;
  String _selectedSecurityQuestion = 'mother_maiden';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // خريطة أسئلة الأمان المعتمدة في موقع طبيبي
  final Map<String, String> _securityQuestions = {
    'mother_maiden': 'ما هو اسم والدتك قبل الزواج؟',
    'first_pet': 'ما اسم أول حيوان أليف قمت بتربيته؟',
    'city_born': 'في أي مدينة ولدت؟',
    'favorite_teacher': 'ما هو اسم معلمك المفضل في المدرسة الابتدائية؟',
    'childhood_food': 'ما هو طعامك المفضل في الصغر؟',
  };

  // فصائل الدم
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _nationalIdController.dispose();
    _securityAnswerController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().registerPatient(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            gender: _selectedGender,
            dateOfBirth: _dobController.text.trim(),
            nationalId: _nationalIdController.text.trim().isNotEmpty
                ? _nationalIdController.text.trim()
                : null,
            bloodGroup: _selectedBloodGroup,
            securityQuestion: _selectedSecurityQuestion,
            securityAnswer: _securityAnswerController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب مريض جديد'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is Authenticated) {
            // نجاح التسجيل والدخول الفوري -> التوجيه للملف الطبي
            context.go('/profile');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // بطاقة تعريفية
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.folder_shared_outlined,
                              color: theme.colorScheme.primary, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'سيتم تلقائياً إنشاء ملف طبي موحد (MRN) خاص بك فور إتمام التسجيل.',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // الاسم الأول واللقب في سطر واحد
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الأول *',
                              hintText: 'أحمد',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'مطلوب'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'اللقب (العائلة) *',
                              hintText: 'بن علي',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'مطلوب'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // البريد الإلكتروني
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني *',
                        hintText: 'ahmed@tabibi.dz',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'صيغة البريد الإلكتروني غير صالحة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // رقم الهاتف
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف *',
                        hintText: '0550123456',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'يرجى إدخال رقم الهاتف'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // الجنس وتاريخ الميلاد
                    Row(
                      children: [
                        // تحديد الجنس
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              labelText: 'الجنس *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('ذكر')),
                              DropdownMenuItem(value: 'female', child: Text('أنثى')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGender = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // تاريخ الميلاد
                        Expanded(
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(
                              labelText: 'تاريخ الميلاد *',
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'حدد التاريخ'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // رقم التعريف الوطني وفصيلة الدم
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _nationalIdController,
                            decoration: InputDecoration(
                              labelText: 'رقم التعريف الوطني (اختياري)',
                              hintText: 'NIN البيومتري',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedBloodGroup,
                            hint: const Text('الفصيلة'),
                            decoration: InputDecoration(
                              labelText: 'الدم',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _bloodGroups.map((group) {
                              return DropdownMenuItem(value: group, child: Text(group));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedBloodGroup = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // عنوان قسم الأمان
                    Text(
                      'سؤال الأمان (لحماية واستعادة حسابك)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // قائمة أسئلة الأمان
                    DropdownButtonFormField<String>(
                      value: _selectedSecurityQuestion,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'اختر سؤال الأمان *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _securityQuestions.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSecurityQuestion = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // إجابة سؤال الأمان
                    TextFormField(
                      controller: _securityAnswerController,
                      decoration: InputDecoration(
                        labelText: 'إجابة سؤال الأمان السرية *',
                        hintText: 'اكتب إجابتك السرية هنا',
                        prefixIcon: const Icon(Icons.security_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'يرجى كتابة الإجابة السرية'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // كلمة المرور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور (8 خانات على الأقل) *',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'يرجى إدخال كلمة المرور';
                        if (val.length < 8) return 'يجب أن لا تقل عن 8 خانات';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // تأكيد كلمة المرور
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور *',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'يرجى تأكيد كلمة المرور';
                        if (val != _passwordController.text) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // زر تأكيد التسجيل
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'تأكيد وإنشاء الملف الطبي',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // رابط تسجيل الدخول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب مريض بالفعل؟',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'سجل دخولك هنا',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}