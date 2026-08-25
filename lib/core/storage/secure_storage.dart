import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // حفظ التوكنز في التخزين الآمن
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // استرجاع الـ Access Token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // استرجاع الـ Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // حذف التوكنز عند تسجيل الخروج
  static Future<void> deleteTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}