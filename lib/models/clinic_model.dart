/// Public clinic from GET /api/clinics/public/
class ClinicModel {
  final String id;
  final String name;
  final String? slug;
  final String? clinicType;
  final String? city;
  final String? phone;
  final String? email;
  final String? address;
  final String? state;
  final String? pincode;
  final String? registrationNumber;
  final String? description;
  final int memberCount;

  ClinicModel({
    required this.id,
    required this.name,
    this.slug,
    this.clinicType,
    this.city,
    this.phone,
    this.email,
    this.address,
    this.state,
    this.pincode,
    this.registrationNumber,
    this.description,
    this.memberCount = 0,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      clinicType: json['clinic_type']?.toString(),
      city: json['city']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      registrationNumber: json['registration_number']?.toString(),
      description: json['description']?.toString(),
      memberCount: json['member_count'] as int? ?? 0,
    );
  }
}

/// Clinic time slot from GET /api/clinics/[id]/slots/
class TimeSlotModel {
  final String id;
  final int dayOfWeek;
  final String? dayName;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final int maxAppointments;
  final bool isActive;

  TimeSlotModel({
    required this.id,
    required this.dayOfWeek,
    this.dayName,
    required this.startTime,
    required this.endTime,
    this.slotDurationMinutes = 15,
    this.maxAppointments = 20,
    this.isActive = true,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id']?.toString() ?? '',
      dayOfWeek: json['day_of_week'] as int? ?? 0,
      dayName: json['day_name']?.toString(),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      slotDurationMinutes: json['slot_duration_minutes'] as int? ?? 15,
      maxAppointments: json['max_appointments'] as int? ?? 20,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// Clinic member from GET /api/clinics/[id]/members/
class ClinicMemberModel {
  final String id;
  final Map<String, dynamic> user;
  final String memberRole; // doctor | lab_member | receptionist
  final String? status;
  final String? department;
  final String? joinedAt;
  final String? notes;

  ClinicMemberModel({
    required this.id,
    required this.user,
    required this.memberRole,
    this.status,
    this.department,
    this.joinedAt,
    this.notes,
  });

  String get userName => user['name']?.toString() ?? '';

  factory ClinicMemberModel.fromJson(Map<String, dynamic> json) {
    return ClinicMemberModel(
      id: json['id']?.toString() ?? '',
      user: json['user'] is Map ? json['user'] as Map<String, dynamic> : {},
      memberRole: json['member_role']?.toString() ?? 'doctor',
      status: json['status']?.toString(),
      department: json['department']?.toString(),
      joinedAt: json['joined_at']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
