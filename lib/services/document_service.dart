import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/document_model.dart';

/// Document upload, listing, consent management, and access audit log.
class DocumentService {
  DocumentService._();

  // ── Documents ──────────────────────────────────────────────────────────────

  /// GET /documents/?type=...
  static Future<List<DocumentModel>> listDocuments({String? type}) async {
    final qs = (type != null && type.isNotEmpty) ? '?type=$type' : '';
    final r = await ApiConfig.get(
      '/documents/$qs',
      headers: await ApiConfig.authHeaders(),
    );
    final data = ApiConfig.ensureList(ApiConfig.handleResponse(r));
    return data
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /documents/ (multipart/form-data)
  static Future<DocumentModel> uploadDocument({
    required String filePath,
    required String title,
    required String documentType,
    String? description,
    int? appointment,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/documents/');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await ApiConfig.multipartAuthHeaders());
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.fields['title'] = title;
    request.fields['document_type'] = documentType;
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    if (appointment != null) {
      request.fields['appointment'] = appointment.toString();
    }
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    return DocumentModel.fromJson(
      ApiConfig.handleResponse(response) as Map<String, dynamic>,
    );
  }

  /// GET /documents/<uuid>/
  static Future<DocumentModel> getDocument(String uuid) async {
    final r = await ApiConfig.get(
      '/documents/$uuid/',
      headers: await ApiConfig.authHeaders(),
    );
    return DocumentModel.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  /// DELETE /documents/<uuid>/
  static Future<void> deleteDocument(String uuid) async {
    final r = await ApiConfig.delete(
      '/documents/$uuid/',
      headers: await ApiConfig.authHeaders(),
    );
    ApiConfig.handleResponse(r);
  }

  // ── Consent ────────────────────────────────────────────────────────────────

  /// GET /documents/consent/mine/?status=...
  static Future<List<ConsentRequest>> listConsentRequests({
    String? status,
  }) async {
    final qs = (status != null && status.isNotEmpty) ? '?status=$status' : '';
    final r = await ApiConfig.get(
      '/documents/consent/mine/$qs',
      headers: await ApiConfig.authHeaders(),
    );
    final data = ApiConfig.ensureList(ApiConfig.handleResponse(r));
    return data
        .map((e) => ConsentRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /documents/consent/<id>/action/  — grant | reject | revoke
  static Future<ConsentRequest> actionConsent(
    String consentId,
    String action,
  ) async {
    final r = await ApiConfig.patch(
      '/documents/consent/$consentId/action/',
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode({'action': action}),
    );
    return ConsentRequest.fromJson(
      ApiConfig.handleResponse(r) as Map<String, dynamic>,
    );
  }

  // ── Access log ─────────────────────────────────────────────────────────────

  /// GET /documents/access-log/         — all docs
  /// GET /documents/<id>/access-log/    — specific doc
  static Future<List<AccessLogEntry>> getAccessLog({String? documentId}) async {
    final path = documentId != null
        ? '/documents/$documentId/access-log/'
        : '/documents/access-log/';
    final r = await ApiConfig.get(path, headers: await ApiConfig.authHeaders());
    final data = ApiConfig.ensureList(ApiConfig.handleResponse(r));
    return data
        .map((e) => AccessLogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
