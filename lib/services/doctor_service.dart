import '../config/api_config.dart';
import '../models/doctor_model.dart';

/// Public doctor listing, detail, availability, and available slots.
class DoctorService {
  DoctorService._();

  /// GET /doctors/?clinic=...&specialty=...&search=...&min_fee=...&max_fee=...&video=...
  static Future<List<DoctorModel>> listDoctors({
    String? clinic,
    String? specialty,
    String? search,
    double? minFee,
    double? maxFee,
    bool? video,
  }) async {
    final params = <String, String>{};
    if (clinic != null && clinic.isNotEmpty) params['clinic'] = clinic;
    if (specialty != null && specialty.isNotEmpty) {
      params['specialty'] = specialty;
    }
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (minFee != null) params['min_fee'] = minFee.toStringAsFixed(0);
    if (maxFee != null) params['max_fee'] = maxFee.toStringAsFixed(0);
    if (video != null) params['video'] = video.toString();
    final qs = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : '';
    final r = await ApiConfig.get(
      '/doctors/$qs',
      headers: ApiConfig.jsonHeaders,
    );
    final data = ApiConfig.handleResponse(r);
    if (data is List) {
      return data
          .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /doctors/<id>/
  static Future<DoctorModel> getDoctorDetail(int doctorId) async {
    final r = await ApiConfig.get(
      '/doctors/$doctorId/',
      headers: ApiConfig.jsonHeaders,
    );
    return DoctorModel.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// GET /doctors/<id>/availability/
  static Future<List<DoctorAvailability>> getDoctorAvailability(
    int doctorId,
  ) async {
    final r = await ApiConfig.get(
      '/doctors/$doctorId/availability/',
      headers: ApiConfig.jsonHeaders,
    );
    final data = ApiConfig.handleResponse(r);
    if (data is List) {
      return data
          .map((e) => DoctorAvailability.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /doctors/<id>/availability/slots/?date=...&clinic_id=...
  static Future<List<String>> getAvailableSlots({
    required int doctorId,
    required String date,
    String? clinicId,
  }) async {
    var path = '/doctors/$doctorId/availability/slots/?date=$date';
    if (clinicId != null && clinicId.isNotEmpty) {
      path += '&clinic_id=$clinicId';
    }
    final r = await ApiConfig.get(path, headers: ApiConfig.jsonHeaders);
    final data = ApiConfig.handleResponse(r) as Map<String, dynamic>;
    final slots = data['available_slots'];
    if (slots is List) {
      return slots.map((s) => s.toString()).toList();
    }
    return [];
  }
}
