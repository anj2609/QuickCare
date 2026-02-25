import '../config/api_config.dart';
import '../models/clinic_model.dart';

/// Public clinic browsing + time slots.
class ClinicService {
  ClinicService._();

  /// GET /clinics/public/?city=...&type=...&search=...
  static Future<List<ClinicModel>> browsePublicClinics({
    String? city,
    String? type,
    String? search,
  }) async {
    final params = <String, String>{};
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final qs = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : '';
    final r = await ApiConfig.get(
      '/clinics/public/$qs',
      headers: ApiConfig.jsonHeaders,
    );
    final data = ApiConfig.handleResponse(r);
    if (data is List) {
      return data
          .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /clinics/<id>/
  static Future<ClinicModel> getClinicDetail(String clinicId) async {
    final r = await ApiConfig.get(
      '/clinics/$clinicId/',
      headers: ApiConfig.jsonHeaders,
    );
    return ClinicModel.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// GET /clinics/<id>/slots/
  static Future<List<TimeSlotModel>> getClinicSlots(String clinicId) async {
    final r = await ApiConfig.get(
      '/clinics/$clinicId/slots/',
      headers: ApiConfig.jsonHeaders,
    );
    final data = ApiConfig.handleResponse(r);
    if (data is List) {
      return data
          .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
