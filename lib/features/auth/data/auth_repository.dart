import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage.dart';
import 'user_model.dart';

/// TABIBI (طبيبي) - Authentication Repository
class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _secureStorage = SecureStorage();
  static const String _userCacheKey = 'tabibi_cached_user';

  /// 1. تسجيل الدخول
  Future<UserModel> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email.trim(),
        'password': password,
        'device_name': deviceName ?? 'Android / iOS Device',
      },
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      final token = data['data']['token'] as String;
      final userJson = data['data']['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      // حفظ التوكن وبيانات المستخدم محلياً
      await _secureStorage.saveToken(token);
      await _saveUserLocally(user);

      return user;
    } else {
      throw data['message'] ?? 'فشل تسجيل الدخول، يرجى المحاولة لاحقاً.';
    }
  }

  /// 2. تسجيل مريض جديد
  Future<UserModel> registerPatient({
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
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'national_id': nationalId?.trim(),
        'blood_group': bloodGroup,
        'security_question': securityQuestion,
        'security_answer': securityAnswer.trim(),
      },
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      final token = data['data']['token'] as String;
      final userJson = data['data']['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      await _secureStorage.saveToken(token);
      await _saveUserLocally(user);

      return user;
    } else {
      throw data['message'] ?? 'فشل إنشاء الحساب، يرجى التحقق من البيانات.';
    }
  }

  /// 3. استعادة كلمة المرور - الخطوة 1: جلب سؤال الأمان
  Future<Map<String, String>> getSecurityQuestion(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {
        'action': 'get_question',
        'email': email.trim(),
      },
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return {
        'question_key': data['data']['question_key'] ?? '',
        'question_text': data['data']['question_text'] ?? '',
      };
    } else {
      throw data['message'] ?? 'لم يتم العثور على سؤال أمان لهذا البريد.';
    }
  }

  /// 4. استعادة كلمة المرور - الخطوة 2: تأكيد كلمة المرور الجديدة
  Future<String> resetPasswordWithAnswer({
    required String email,
    required String securityAnswer,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {
        'action': 'reset_password',
        'email': email.trim(),
        'security_answer': securityAnswer.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final data = response.data;
    if (data['success'] == true) {
      return data['message'] ?? 'تم تحديث كلمة المرور بنجاح.';
    } else {
      throw data['message'] ?? 'فشل تحديث كلمة المرور، يرجى التحقق من الإجابة.';
    }
  }

  /// 5. التحقق من المستخدم المسجل حالياً في الذاكرة
  Future<UserModel?> getSavedUser() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userCacheKey);
    if (userString != null && userString.isNotEmpty) {
      try {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// 6. تسجيل الخروج
  Future<void> logout() async {
    await _secureStorage.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
  }

  /// حفظ بيانات المستخدم في SharedPreferences
  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCacheKey, jsonEncode(user.toJson()));
  }
}