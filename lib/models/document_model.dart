/// Patient document from GET /api/documents/
class DocumentModel {
  final String id;
  final String? title;
  final String?
  documentType; // prescription | lab_report | imaging | discharge_summary | insurance | other
  final String? description;
  final String? file; // URL
  final int? appointment;
  final String? createdAt;

  DocumentModel({
    required this.id,
    this.title,
    this.documentType,
    this.description,
    this.file,
    this.appointment,
    this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      documentType: json['document_type']?.toString(),
      description: json['description']?.toString(),
      file: json['file']?.toString(),
      appointment: json['appointment'] as int?,
      createdAt: json['created_at']?.toString(),
    );
  }
}

/// Consent request — incoming consent from a doctor.
class ConsentRequest {
  final String id;
  final String document;
  final int? doctor;
  final String status; // pending | granted | rejected | revoked
  final String? purpose;
  final String? expiresAt;
  final String? actionedAt;

  ConsentRequest({
    required this.id,
    required this.document,
    this.doctor,
    this.status = 'pending',
    this.purpose,
    this.expiresAt,
    this.actionedAt,
  });

  factory ConsentRequest.fromJson(Map<String, dynamic> json) {
    return ConsentRequest(
      id: json['id']?.toString() ?? '',
      document: json['document']?.toString() ?? '',
      doctor: json['doctor'] as int?,
      status: json['status']?.toString() ?? 'pending',
      purpose: json['purpose']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      actionedAt: json['actioned_at']?.toString(),
    );
  }
}

/// Access log entry from GET /api/documents/access-log/
class AccessLogEntry {
  final String id;
  final String document;
  final Map<String, dynamic>? accessedBy;
  final String? accessedAt;
  final String? ipAddress;

  AccessLogEntry({
    required this.id,
    required this.document,
    this.accessedBy,
    this.accessedAt,
    this.ipAddress,
  });

  String get accessedByName => accessedBy?['name']?.toString() ?? 'Unknown';

  factory AccessLogEntry.fromJson(Map<String, dynamic> json) {
    return AccessLogEntry(
      id: json['id']?.toString() ?? '',
      document: json['document']?.toString() ?? '',
      accessedBy: json['accessed_by'] is Map
          ? json['accessed_by'] as Map<String, dynamic>
          : null,
      accessedAt: json['accessed_at']?.toString(),
      ipAddress: json['ip_address']?.toString(),
    );
  }
}
