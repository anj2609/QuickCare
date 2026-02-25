/// Doctor profile from GET /api/doctors/
class DoctorModel {
  final int id;
  final Map<String, dynamic> user;
  final String? specialty;
  final String? qualification;
  final String? registrationNumber;
  final int? experienceYears;
  final String? biography;
  final String? languages;
  final double? firstVisitFee;
  final double? followUpFee;
  final bool offersVideoConsultation;
  final List<DoctorClinicInfo> clinics;

  DoctorModel({
    required this.id,
    required this.user,
    this.specialty,
    this.qualification,
    this.registrationNumber,
    this.experienceYears,
    this.biography,
    this.languages,
    this.firstVisitFee,
    this.followUpFee,
    this.offersVideoConsultation = false,
    this.clinics = const [],
  });

  String get name => user['name']?.toString() ?? 'Doctor';
  int? get contact => user['contact'] as int?;

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int? ?? 0,
      user: json['user'] is Map ? json['user'] as Map<String, dynamic> : {},
      specialty: json['specialty']?.toString(),
      qualification: json['qualification']?.toString(),
      registrationNumber: json['registration_number']?.toString(),
      experienceYears: json['experience_years'] as int?,
      biography: json['biography']?.toString(),
      languages: json['languages']?.toString(),
      firstVisitFee: _toDouble(json['first_visit_fee']),
      followUpFee: _toDouble(json['follow_up_fee']),
      offersVideoConsultation:
          json['offers_video_consultation'] as bool? ?? false,
      clinics:
          (json['clinics'] as List<dynamic>?)
              ?.map((c) => DoctorClinicInfo.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

/// Clinic info nested inside a DoctorModel.
class DoctorClinicInfo {
  final String clinicId;
  final String clinicName;
  final String? city;
  final String? department;

  DoctorClinicInfo({
    required this.clinicId,
    required this.clinicName,
    this.city,
    this.department,
  });

  factory DoctorClinicInfo.fromJson(Map<String, dynamic> json) {
    return DoctorClinicInfo(
      clinicId: json['clinic_id']?.toString() ?? '',
      clinicName: json['clinic_name']?.toString() ?? '',
      city: json['city']?.toString(),
      department: json['department']?.toString(),
    );
  }
}

/// Doctor availability schedule.
class DoctorAvailability {
  final String? id;
  final String? clinic;
  final String day;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final int maxPatients;
  final bool isActive;

  DoctorAvailability({
    this.id,
    this.clinic,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.slotDurationMinutes = 15,
    this.maxPatients = 20,
    this.isActive = true,
  });

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      id: json['id']?.toString(),
      clinic: json['clinic']?.toString(),
      day: json['day']?.toString() ?? json['day_name']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      slotDurationMinutes: json['slot_duration_minutes'] as int? ?? 15,
      maxPatients: json['max_patients'] as int? ?? 20,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
