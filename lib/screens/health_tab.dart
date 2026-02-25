import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../services/appointment_service.dart';

const _kPrimary = Color(0xFF2CB8C7);
const _kNavy = Color(0xFF0F172A);
const _kGrey = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kGreen = Color(0xFF10B981);

// ─────────────────────────────────────────────────────────────────────────────
// HealthTab — Lab Reports · Consent Management · Admission Documents
// ─────────────────────────────────────────────────────────────────────────────
class HealthTab extends StatefulWidget {
  final List<Appointment> appointments;
  final List<DocumentModel> documents;
  const HealthTab({
    super.key,
    required this.appointments,
    this.documents = const [],
  });

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  List<DocumentModel> _prescriptions = [];
  bool _loadingRx = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    try {
      _prescriptions = await DocumentService.listDocuments(
        type: 'prescription',
      );
    } catch (e) {
      debugPrint('⚠️ Failed to load prescriptions: $e');
    }
    if (mounted) setState(() => _loadingRx = false);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hPad = (sw * 0.04).clamp(12.0, 20.0);
    final titleFs = (sw * 0.055).clamp(18.0, 24.0);
    final subtitleFs = (sw * 0.033).clamp(11.0, 14.0);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Records',
              style: TextStyle(
                fontSize: titleFs,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your medical data at a glance',
              style: TextStyle(fontSize: subtitleFs, color: _kGrey),
            ),
            const SizedBox(height: 20),

            // ─── Upcoming Appointments ──────────────────────────
            _SectionHeader(
              title: 'Upcoming Appointments',
              subtitle: 'Your scheduled visits and consultations',
            ),
            const SizedBox(height: 10),
            _AppointmentsCard(appointments: widget.appointments),
            const SizedBox(height: 24),

            // ─── Documents / Lab Reports ─────────────────────────
            _SectionHeader(
              title: 'Documents',
              subtitle: 'Your uploaded documents and reports',
            ),
            const SizedBox(height: 10),
            _ReportsCard(documents: widget.documents),
            const SizedBox(height: 24),

            // ─── Active Prescriptions ────────────────────────────
            _SectionHeader(
              title: 'Active Prescriptions',
              subtitle: 'Medications currently prescribed to you',
            ),
            const SizedBox(height: 10),
            _loadingRx
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: _kPrimary),
                    ),
                  )
                : _PrescriptionsCard(prescriptions: _prescriptions),
            const SizedBox(height: 24),

            // ─── Admission Documents ─────────────────────────────
            _SectionHeader(
              title: 'Admission Documents',
              subtitle: 'Upload required documents for your admission',
            ),
            const SizedBox(height: 10),
            const _AdmissionDocumentsCard(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Section header with decorative separator
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final titleFs = (sw * 0.042).clamp(13.0, 17.0);
    final subtitleFs = (sw * 0.03).clamp(10.0, 13.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFs,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: ClipRect(
                child: Text(
                  '════════════════════════════════',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: _kBorder,
                    fontSize: 10,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: subtitleFs, color: _kGrey),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lab report row card
// ─────────────────────────────────────────────────────────────────────────────
// ── Appointments card — DYNAMIC ────────────────────────────────────────────
// ── Appointments card — DYNAMIC ────────────────────────────────────────────
class _AppointmentsCard extends StatelessWidget {
  final List<Appointment> appointments;
  const _AppointmentsCard({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No upcoming appointments',
                  style: TextStyle(fontSize: 13, color: _kGrey),
                ),
              ),
            )
          else
            ...appointments.asMap().entries.map((e) {
              final i = e.key;
              final apt = e.value;
              final color = apt.status == 'Confirmed'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B);
              return Column(
                children: [
                  if (i > 0) const Divider(height: 24, color: _kBorder),
                  _AppointmentRow(
                    name: apt.doctorName,
                    sub: '${apt.specialty} · ${apt.formattedDateTime}',
                    status: apt.status,
                    statusColor: color,
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final String name, sub, status;
  final Color statusColor;
  const _AppointmentRow({
    required this.name,
    required this.sub,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _kPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.schedule_outlined,
            size: 20,
            color: _kPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 12, color: _kGrey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Documents / Reports card ───────────────────────────────────────────────
class _ReportsCard extends StatelessWidget {
  final List<DocumentModel> documents;
  const _ReportsCard({required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: const Center(
          child: Text(
            'No documents uploaded yet',
            style: TextStyle(fontSize: 13, color: _kGrey),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < documents.length; i++) ...[
            if (i > 0) const Divider(height: 24, color: _kBorder),
            _ReportRow(
              title:
                  documents[i].title ?? documents[i].documentType ?? 'Document',
              date: documents[i].createdAt ?? '',
              status: 'Uploaded',
              statusColor: _kGreen,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String title, date, status;
  final Color statusColor;
  const _ReportRow({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description_outlined,
            size: 20,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(date, style: const TextStyle(fontSize: 12, color: _kGrey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Active Prescriptions ───────────────────────────────────────────────────
class _PrescriptionsCard extends StatelessWidget {
  final List<DocumentModel> prescriptions;
  const _PrescriptionsCard({required this.prescriptions});

  @override
  Widget build(BuildContext context) {
    if (prescriptions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: const Center(
          child: Text(
            'No active prescriptions',
            style: TextStyle(fontSize: 13, color: _kGrey),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < prescriptions.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 12),
              const Divider(color: _kBorder),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                const Icon(
                  Icons.medication_outlined,
                  color: _kPrimary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prescriptions[i].title ??
                        prescriptions[i].documentType ??
                        'Prescription',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (prescriptions[i].createdAt != null)
                  Text(
                    prescriptions[i].createdAt!,
                    style: const TextStyle(fontSize: 12, color: _kGrey),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admission Documents card
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Admission Documents card
// ─────────────────────────────────────────────────────────────────────────────
class _AdmissionDocumentsCard extends StatefulWidget {
  const _AdmissionDocumentsCard();

  @override
  State<_AdmissionDocumentsCard> createState() =>
      _AdmissionDocumentsCardState();
}

class _AdmissionDocumentsCardState extends State<_AdmissionDocumentsCard> {
  List<Map<String, dynamic>> _clinics = [];
  List<Map<String, dynamic>> _admissionDocs = [];
  bool _loadingClinics = true;
  bool _loadingDocs = false;
  String? _selectedClinicId;
  String? _selectedClinicName;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    try {
      _clinics = await AppointmentService.listMyClinics();
    } catch (e) {
      debugPrint('⚠️ Failed to load my clinics: $e');
    }
    if (mounted) setState(() => _loadingClinics = false);
  }

  Future<void> _loadAdmissionDocs(String clinicId) async {
    setState(() {
      _loadingDocs = true;
      _admissionDocs = [];
    });
    try {
      _admissionDocs = await AppointmentService.getAdmissionDocs(clinicId);
    } catch (e) {
      debugPrint('⚠️ Failed to load admission docs: $e');
    }
    if (mounted) setState(() => _loadingDocs = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingClinics) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: const Center(child: CircularProgressIndicator(color: _kPrimary)),
      );
    }

    if (_clinics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: const Center(
          child: Text(
            'No clinics with appointments yet',
            style: TextStyle(fontSize: 13, color: _kGrey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Clinic picker ─────────────────────────────────────
          const Text(
            'Select Clinic',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedClinicId,
                hint: const Text(
                  'Choose a clinic',
                  style: TextStyle(fontSize: 13, color: _kGrey),
                ),
                items: _clinics.map((c) {
                  final id = c['id']?.toString() ?? '';
                  final name = c['name']?.toString() ?? 'Clinic';
                  return DropdownMenuItem(
                    value: id,
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 13, color: _kNavy),
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final clinic = _clinics.firstWhere(
                    (c) => c['id']?.toString() == id,
                  );
                  setState(() {
                    _selectedClinicId = id;
                    _selectedClinicName = clinic['name']?.toString();
                  });
                  _loadAdmissionDocs(id);
                },
              ),
            ),
          ),

          // ── Admission docs list ───────────────────────────────
          if (_selectedClinicId != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: _kBorder),
            const SizedBox(height: 14),
            if (_loadingDocs)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: _kPrimary),
                ),
              )
            else if (_admissionDocs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No admission documents required for ${_selectedClinicName ?? "this clinic"}',
                    style: const TextStyle(fontSize: 13, color: _kGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              Text(
                'Required for ${_selectedClinicName ?? "clinic"}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 10),
              ..._admissionDocs.map((doc) {
                final name =
                    doc['name']?.toString() ??
                    doc['document_name']?.toString() ??
                    'Document';
                final isRequired =
                    doc['is_required'] as bool? ??
                    doc['required'] as bool? ??
                    true;
                final uploaded =
                    doc['is_uploaded'] as bool? ??
                    doc['uploaded'] as bool? ??
                    false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (uploaded ? _kGreen : const Color(0xFFF59E0B))
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          uploaded
                              ? Icons.check_circle_outline_rounded
                              : Icons.warning_amber_rounded,
                          size: 20,
                          color: uploaded ? _kGreen : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _kNavy,
                                    ),
                                  ),
                                ),
                                if (isRequired)
                                  const Text(
                                    'Required',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              uploaded ? 'Uploaded ✓' : 'Not uploaded',
                              style: TextStyle(
                                fontSize: 11,
                                color: uploaded ? _kGreen : _kGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom zebra striped progress bar
// ─────────────────────────────────────────────────────────────────────────────
class ZebraProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color color;
  final Color backgroundColor;

  const ZebraProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * value.clamp(0.0, 1.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: barWidth,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(height / 2),
                  child: CustomPaint(painter: _ZebraPainter(color: color)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ZebraPainter extends CustomPainter {
  final Color color;
  _ZebraPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Fill the background first
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw the stripes
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    const stripeWidth = 10.0;
    const spacing = 10.0;
    final totalWidth = size.width + size.height;

    for (double x = -size.height; x < totalWidth; x += stripeWidth + spacing) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height + stripeWidth, 0)
        ..lineTo(x + stripeWidth, size.height)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZebraPainter oldDelegate) =>
      color != oldDelegate.color;
}
