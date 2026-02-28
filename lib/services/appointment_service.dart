import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/appointment.dart';

/// Patient appointment management — list, book, view, cancel.
class AppointmentService {
  AppointmentService._();

  /// GET /appointments/my/?status=...
  static Future<List<Appointment>> listMyAppointments({String? status}) async {
    final qs = (status != null && status.isNotEmpty) ? '?status=$status' : '';
    final r = await ApiConfig.get(
      '/appointments/my/$qs',
      headers: await ApiConfig.authHeaders(),
    );
    final data = ApiConfig.ensureList(ApiConfig.handleResponse(r));
    return data
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /appointments/my/
  static Future<Appointment> bookAppointment({
    required int doctorId,
    required String date,
    required String time,
    String appointmentType = 'first_visit',
    String mode = 'in_clinic',
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'doctor': doctorId,
      'appointment_date': date,
      'appointment_time': time,
      'appointment_type': appointmentType,
      'mode': mode,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final r = await ApiConfig.post(
      '/appointments/my/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode(body),
    );
    return Appointment.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// GET /appointments/my/[id]/
  static Future<Appointment> getAppointment(int id) async {
    final r = await ApiConfig.get(
      '/appointments/my/$id/',
      headers: await ApiConfig.authHeaders(),
    );
    return Appointment.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// PATCH /appointments/my/<id>/  — cancel only
  static Future<void> cancelAppointment(int id) async {
    final r = await ApiConfig.patch(
      '/appointments/my/$id/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode({'status': 'cancelled'}),
    );
    ApiConfig.handleResponse(r);
  }

  /// GET /appointments/my/clinics/
  /// Lists all clinics the patient has appointments at.
  static Future<List<Map<String, dynamic>>> listMyClinics() async {
    try {
      final r = await ApiConfig.get(
        '/appointments/my/clinics/',
        headers: await ApiConfig.authHeaders(),
      );
      final data = ApiConfig.ensureList(ApiConfig.handleResponse(r));
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      // Gracefully handle 404 if patient has no associated clinics yet
      debugPrint('ℹ️ Handled listMyClinics error: $e');
      return [];
    }
  }

  /// GET /appointments/my/clinics/<clinic_id>/admission-docs/
  /// Shows the required admission documents for a specific clinic.
  static Future<List<Map<String, dynamic>>> getAdmissionDocs(
    String clinicId,
  ) async {
    try {
      final r = await ApiConfig.get(
        '/appointments/my/clinics/$clinicId/admission-docs/',
        headers: await ApiConfig.authHeaders(),
      );
      final data = ApiConfig.ensureList(ApiConfig.handleResponse(r));
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('ℹ️ Handled getAdmissionDocs error: $e');
      return [];
    }
  }
}
