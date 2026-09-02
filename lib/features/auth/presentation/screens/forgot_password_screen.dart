import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';
import '../../logic/auth_bloc.dart';
import '../../logic/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  String? _securityQuestion;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _answerCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  void _fetchQuestion() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    context.read<AuthCubit>().fetchSecurityQuestion(email);
  }

  void _resetPassword() {
    final email = _emailCtrl.text.trim();
    final answer = _answerCtrl.text.trim();
    final newPass = _newPasswordCtrl.text;
    if (email.isEmpty || answer.isEmpty || newPass.isEmpty) return;
    context.read<AuthCubit>().resetPassword(
      email: email,
      securityAnswer: answer,
      newPassword: newPass,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استرجاع كلمة المرور', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: AmbientLightBackground(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is SecurityQuestionLoaded) {
              setState(() => _securityQuestion = state.questionText);
            } else if (state is PasswordResetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppTheme.primary),
              );
              context.go('/login');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: GlassBentoCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailCtrl,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني المسجل', prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 12),
                    if (_securityQuestion == null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.white),
                        onPressed: isLoading ? null : _fetchQuestion,
                        child: const Text('التحقق وجلب سؤال الأمان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      ),
                    if (_securityQuestion != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                        child: Text('سؤال الأمان: $_securityQuestion', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _answerCtrl,
                        decoration: const InputDecoration(labelText: 'إجابة سؤال الأمان', prefixIcon: Icon(Icons.key_rounded)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPasswordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة', prefixIcon: Icon(Icons.lock_reset_rounded)),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                        onPressed: isLoading ? null : _resetPassword,
                        child: const Text('حفظ وتغيير كلمة المرور', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
