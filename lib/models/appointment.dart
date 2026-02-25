/// Appointment from GET /api/appointments/my/
class Appointment {
  final int id;
  final Map<String, dynamic> doctor;
  final String appointmentDate;
  final String appointmentTime;
  final String appointmentType; // first_visit | follow_up
  final String mode; // in_clinic | video
  final String status; // pending | confirmed | completed | cancelled | no_show
  final String? feeCharged;
  final String? notes;

  // Local-only fields used by mock data in the UI before full API integration
  final String? _hospital;
  final String? _reason;

  Appointment({
    required this.id,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
    this.appointmentType = 'first_visit',
    this.mode = 'in_clinic',
    this.status = 'pending',
    this.feeCharged,
    this.notes,
  }) : _hospital = null,
       _reason = null;

  /// Convenience constructor for local/mock appointments used in UI screens
  /// that are not yet connected to the backend API.
  Appointment.local({
    required String hospital,
    required String doctorName,
    required String specialty,
    required DateTime dateTime,
    String reason = '',
    String status = 'Pending',
  }) : id = 0,
       doctor = {
         'id': 0,
         'user': {'name': doctorName},
         'specialty': specialty,
       },
       appointmentDate =
           '${dateTime.year}-${_p(dateTime.month)}-${_p(dateTime.day)}',
       appointmentTime = '${_p(dateTime.hour)}:${_p(dateTime.minute)}',
       appointmentType = 'first_visit',
       mode = 'in_clinic',
       status = status,
       feeCharged = null,
       notes = reason.isNotEmpty ? reason : null,
       _hospital = hospital,
       _reason = reason;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get doctorName {
    final user = doctor['user'];
    if (user is Map) return user['name']?.toString() ?? 'Doctor';
    return 'Doctor';
  }

  String get specialty => doctor['specialty']?.toString() ?? '';

  /// For backward compat with screens that read `apt.hospital`
  String get hospital => _hospital ?? '';

  /// For backward compat with screens that read `apt.reason`
  String get reason => _reason ?? notes ?? '';

  String get formattedDateTime => '$appointmentDate at $appointmentTime';

  static String _p(int n) => n.toString().padLeft(2, '0');

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int? ?? 0,
      doctor: json['doctor'] is Map
          ? json['doctor'] as Map<String, dynamic>
          : {},
      appointmentDate: json['appointment_date']?.toString() ?? '',
      appointmentTime: json['appointment_time']?.toString() ?? '',
      appointmentType: json['appointment_type']?.toString() ?? 'first_visit',
      mode: json['mode']?.toString() ?? 'in_clinic',
      status: json['status']?.toString() ?? 'pending',
      feeCharged: json['fee_charged']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toBookingJson() => {
    'doctor': doctor['id'] ?? id,
    'appointment_date': appointmentDate,
    'appointment_time': appointmentTime,
    'appointment_type': appointmentType,
    'mode': mode,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
