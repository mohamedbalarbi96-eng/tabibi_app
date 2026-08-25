import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

// ==========================================
// 1. حالات المصادقة (Auth States)
// ==========================================
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class AuthInitial extends AuthState {}

/// حالة جاري التحميل والاتصال بالخادم
class AuthLoading extends AuthState {}

/// حالة تسجيل الدخول بنجاح مع بيانات المستخدم
class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// حالة المستخدم غير مسجل الدخول (شاشة الدخول)
class Unauthenticated extends AuthState {}

/// حالة حدوث خطأ مع رسالة الخطأ
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// حالة تم استرجاع سؤال الأمان بنجاح
class SecurityQuestionLoaded extends AuthState {
  final String email;
  final String questionKey;
  final String questionText;

  const SecurityQuestionLoaded({
    required this.email,
    required this.questionKey,
    required this.questionText,
  });

  @override
  List<Object?> get props => [email, questionKey, questionText];
}

/// حالة تم تحديث كلمة المرور بنجاح
class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ==========================================
// 2. مدير منطق المصادقة (Auth Cubit)
// ==========================================
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthCubit() : super(AuthInitial());

  /// التحقق التلقائي من حالة تسجيل الدخول عند بدء التطبيق
  Future<void> checkAuthStatus() async {
    try {
      final user = await _authRepository.getSavedUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  /// تنفيذ تسجيل الدخول
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// تنفيذ تسجيل مريض جديد
  Future<void> registerPatient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String gender,
    required String dateOfBirth,
    String? nationalId,
    String? bloodGroup,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerPatient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        gender: gender,
        dateOfBirth: dateOfBirth,
        nationalId: nationalId,
        bloodGroup: bloodGroup,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// طلب جلب سؤال الأمان لحساب معين
  Future<void> fetchSecurityQuestion(String email) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.getSecurityQuestion(email);
      emit(SecurityQuestionLoaded(
        email: email,
        questionKey: result['question_key'] ?? '',
        questionText: result['question_text'] ?? '',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// تأكيد كلمة المرور الجديدة بعد إجابة سؤال الأمان
  Future<void> resetPassword({
    required String email,
    required String securityAnswer,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(AuthLoading());
    try {
      final message = await _authRepository.resetPasswordWithAnswer(
        email: email,
        securityAnswer: securityAnswer,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      emit(PasswordResetSuccess(message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(Unauthenticated());
  }
}