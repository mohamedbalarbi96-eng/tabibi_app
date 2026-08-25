import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// TABIBI (طبيبي) - Patient Data Repository
class PatientRepository {
  final ApiClient _apiClient = ApiClient();

  /// 1. جلب بيانات لوحة المريض والملف الصحي الشامل
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _apiClient.get(ApiEndpoints.patientProfile.replaceAll('profile.php', 'dashboard.php'));
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw data['message'] ?? 'فشل استرجاع بيانات الملف الطبي.';
    }
  }

  /// 2. البحث عن الأطباء وتصفيتهم
  Future<Map<String, dynamic>> getDoctors({
    String? name,
    int? specializationId,
    String? city,
  }) async {
    final queryParams = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) queryParams['name'] = name.trim();
    if (specializationId != null && specializationId > 0) queryParams['specialization_id'] = specializationId;
    if (city != null && city.trim().isNotEmpty) queryParams['city'] = city.trim();

    final response = await _apiClient.get(
      ApiEndpoints.doctorsList,
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw data['message'] ?? 'فشل البحث عن الأطباء.';
    }
  }

  /// 3. جلب تفاصيل بروفايل الطبيب والمراجعات وأوقات العمل
  Future<Map<String, dynamic>> getDoctorDetails(int doctorId) async {
    final response = await _apiClient.get(
      ApiEndpoints.doctorDetails,
      queryParameters: {'id': doctorId},
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw data['message'] ?? 'فشل استرجاع ملف الطبيب.';
    }
  }

  /// 4. حساب الفترات الشاغرة لليوم المختار
  Future<List<String>> getAvailableSlots({
    required int doctorId,
    required String date,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.bookAppointment,
      queryParameters: {
        'doctor_id': doctorId,
        'date': date,
      },
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      final slots = data['data']['available_slots'] as List? ?? [];
      return slots.map((s) => s.toString()).toList();
    } else {
      throw data['message'] ?? 'لا تتوفر فترات حجز لهذا اليوم.';
    }
  }

  /// 5. تأكيد وحجز الموعد الطبي
  Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    int? serviceId,
    required String appointmentDate,
    required String appointmentTime,
    String? reason,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookAppointment,
      data: {
        'doctor_id': doctorId,
        'service_id': serviceId,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'reason': reason?.trim(),
      },
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw data['message'] ?? 'فشل تسجيل الموعد الطبي.';
    }
  }

  /// 6. جلب أرشيف مواعيد المريض
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final response = await _apiClient.get(ApiEndpoints.patientAppointments);
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      final list = data['data']['appointments'] as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw data['message'] ?? 'فشل استرجاع سجل المواعيد.';
    }
  }

  /// 7. إلغاء موعد طبي
  Future<String> cancelAppointment(int appointmentId) async {
    final response = await _apiClient.post(
      ApiEndpoints.patientAppointments,
      data: {'appointment_id': appointmentId},
    );

    final data = response.data;
    if (data['success'] == true) {
      return data['message'] ?? 'تم إلغاء الموعد بنجاح.';
    } else {
      throw data['message'] ?? 'فشل إلغاء الموعد.';
    }
  }

  /// 8. جلب سجل الوصفات الطبية الرقمية
  Future<List<Map<String, dynamic>>> getPrescriptions() async {
    final response = await _apiClient.get(ApiEndpoints.patientPrescriptions);
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      final list = data['data']['prescriptions'] as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw data['message'] ?? 'فشل استرجاع الوصفات الطبية.';
    }
  }

  /// 9. جلب تفاصيل أدوية وصفة محددة والـ QR Code
  Future<Map<String, dynamic>> getPrescriptionDetails(int prescriptionId) async {
    final response = await _apiClient.get(
      ApiEndpoints.patientPrescriptions,
      queryParameters: {'id': prescriptionId},
    );

    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw data['message'] ?? 'فشل استرجاع تفاصيل الوصفة.';
    }
  }

  /// 10. جلب سجل مشاركات الملف الطبي
  Future<List<Map<String, dynamic>>> getShares() async {
    final response = await _apiClient.get(ApiEndpoints.patientShares);
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      final list = data['data']['shares'] as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw data['message'] ?? 'فشل استرجاع سجل المشاركات.';
    }
  }

  /// 11. إنشاء مشاركة جديدة للملف الطبي مع طبيب
  Future<String> addShare({
    required int doctorId,
    required String shareType,
    String? duration,
    String? customDate,
    List<String>? perms,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.patientShares,
      data: {
        'action': 'add_share',
        'doctor_id': doctorId,
        'share_type': shareType,
        'duration': duration,
        'custom_date': customDate,
        'perms': perms ?? ['read_visits', 'read_prescriptions', 'read_vitals', 'read_attachments'],
      },
    );

    final data = response.data;
    if (data['success'] == true) {
      return data['message'] ?? 'تمت مشاركة الملف بنجاح.';
    } else {
      throw data['message'] ?? 'فشل مشاركة الملف الطبي.';
    }
  }

  /// 12. إلغاء مشاركة الملف الطبي فوراً
  Future<String> revokeShare(int shareId) async {
    final response = await _apiClient.post(
      ApiEndpoints.patientShares,
      data: {
        'action': 'revoke_share',
        'share_id': shareId,
      },
    );

    final data = response.data;
    if (data['success'] == true) {
      return data['message'] ?? 'تم إلغاء المشاركة بنجاح.';
    } else {
      throw data['message'] ?? 'فشل إلغاء المشاركة.';
    }
  }

  /// 13. تقييم الطبيب بعد اكتمال الموعد
  Future<String> rateDoctor({
    required int appointmentId,
    required int rating,
    String? reviewText,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.rateDoctor,
      data: {
        'appointment_id': appointmentId,
        'rating': rating,
        'review_text': reviewText?.trim(),
      },
    );

    final data = response.data;
    if (data['success'] == true) {
      return data['message'] ?? 'تم إرسال التقييم بنجاح.';
    } else {
      throw data['message'] ?? 'فشل تسجيل التقييم.';
    }
  }
}