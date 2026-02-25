/// Represents a patient user from the backend.
class UserModel {
  final String id;
  final String name;
  final int contact;
  final String? email;
  final String? gender;
  final int? age;
  final String? bloodGroup;
  final Map<String, dynamic>? roles;
  final bool isPartialOnboarding;
  final bool isCompleteOnboarding;

  UserModel({
    required this.id,
    required this.name,
    required this.contact,
    this.email,
    this.gender,
    this.age,
    this.bloodGroup,
    this.roles,
    this.isPartialOnboarding = false,
    this.isCompleteOnboarding = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contact: (json['contact'] is int)
          ? json['contact'] as int
          : int.tryParse(json['contact'].toString()) ?? 0,
      email: json['email']?.toString(),
      gender: json['gender']?.toString(),
      age: json['age'] as int?,
      bloodGroup: json['blood_group']?.toString(),
      roles: json['roles'] is Map
          ? json['roles'] as Map<String, dynamic>
          : null,
      isPartialOnboarding: json['is_partial_onboarding'] as bool? ?? false,
      isCompleteOnboarding: json['is_complete_onboarding'] as bool? ?? false,
    );
  }
}

/// JWT tokens + user returned by login / step2.
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access']?.toString() ?? '',
      refreshToken: json['refresh']?.toString() ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Medical profile returned by GET /users/me/medical-profile/
class MedicalProfile {
  final String? allergies;
  final String? chronicConditions;
  final String? currentMedications;
  final String? pastSurgeries;
  final String? familyHistory;
  final double? heightCm;
  final double? weightKg;
  final String? emergencyContactName;
  final int? emergencyContactNumber;
  final String? updatedAt;

  MedicalProfile({
    this.allergies,
    this.chronicConditions,
    this.currentMedications,
    this.pastSurgeries,
    this.familyHistory,
    this.heightCm,
    this.weightKg,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.updatedAt,
  });

  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      allergies: json['allergies']?.toString(),
      chronicConditions: json['chronic_conditions']?.toString(),
      currentMedications: json['current_medications']?.toString(),
      pastSurgeries: json['past_surgeries']?.toString(),
      familyHistory: json['family_history']?.toString(),
      heightCm: _toDouble(json['height_cm']),
      weightKg: _toDouble(json['weight_kg']),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactNumber: json['emergency_contact_number'] is int
          ? json['emergency_contact_number'] as int
          : int.tryParse(json['emergency_contact_number']?.toString() ?? ''),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
