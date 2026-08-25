import 'package:equatable/equatable.dart';

/// TABIBI (طبيبي) - Unified User & Clinical Profile Model
class UserModel extends Equatable {
  final int id;
  final String role;
  final String roleDisplay;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final String? avatar;

  // حقول خاصة بملف المريض (Patient Specific)
  final int? patientId;
  final String? recordNumber; // رقم السجل الطبي الموحد (MRN)
  final String? bloodGroup;
  final String? allergies;
  final String? chronicDiseases;

  // حقول خاصة بملف الطبيب (Doctor Specific)
  final int? doctorId;
  final String? specializationName;
  final String? licenseNumber;
  final double? consultationFee;
  final int? experienceYears;
  final String? clinicName;

  const UserModel({
    required this.id,
    required this.role,
    required this.roleDisplay,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    this.avatar,
    this.patientId,
    this.recordNumber,
    this.bloodGroup,
    this.allergies,
    this.chronicDiseases,
    this.doctorId,
    this.specializationName,
    this.licenseNumber,
    this.consultationFee,
    this.experienceYears,
    this.clinicName,
  });

  /// الاسم الكامل
  String get fullName => '$firstName $lastName';

  /// دوال مساعدة لمعرفة نوع الحساب
  bool get isPatient => role == 'patient';
  bool get isDoctor => role == 'doctor';
  bool get isAdmin => role == 'admin';
  bool get isReceptionist => role == 'receptionist';

  /// تحويل بيانات JSON القادمة من الـ API إلى كائن Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      role: json['role'] as String? ?? 'patient',
      roleDisplay: json['role_display'] as String? ?? 'مريض',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      gender: json['gender'] as String? ?? 'male',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      avatar: json['avatar'] as String?,
      
      // Patient Data
      patientId: json['patient_id'] as int?,
      recordNumber: json['record_number'] as String?,
      bloodGroup: json['blood_group'] as String?,
      allergies: json['allergies'] as String?,
      chronicDiseases: json['chronic_diseases'] as String?,

      // Doctor Data
      doctorId: json['doctor_id'] as int?,
      specializationName: json['specialization_name'] as String?,
      licenseNumber: json['license_number'] as String?,
      consultationFee: (json['consultation_fee'] != null)
          ? double.tryParse(json['consultation_fee'].toString())
          : null,
      experienceYears: json['experience_years'] as int?,
      clinicName: json['clinic_name'] as String?,
    );
  }

  /// تحويل الكائن إلى JSON للحفظ المحلي
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'role_display': roleDisplay,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'avatar': avatar,
      'patient_id': patientId,
      'record_number': recordNumber,
      'blood_group': bloodGroup,
      'allergies': allergies,
      'chronic_diseases': chronicDiseases,
      'doctor_id': doctorId,
      'specialization_name': specializationName,
      'license_number': licenseNumber,
      'consultation_fee': consultationFee,
      'experience_years': experienceYears,
      'clinic_name': clinicName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        role,
        email,
        firstName,
        lastName,
        recordNumber,
        doctorId,
      ];
}