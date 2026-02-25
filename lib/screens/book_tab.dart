import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../models/clinic_model.dart';
import '../models/doctor_model.dart';
import '../services/clinic_service.dart';
import '../services/doctor_service.dart';
import '../services/appointment_service.dart';
import '../config/api_config.dart';

const _kBg = Color(0xFFF0F4F8);
const _kPrimary = Color(0xFF2CB8C7);
const _kNavy = Color(0xFF0F172A);
const _kGrey = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

// ─────────────────────────────────────────────────────────────────────────────
// BookTab — 4-step appointment booking flow
// ─────────────────────────────────────────────────────────────────────────────
class BookTab extends StatefulWidget {
  final void Function(Appointment) onBooked;
  const BookTab({super.key, required this.onBooked});

  @override
  State<BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<BookTab> {
  int _step = 1; // 1–4 = steps, 5 = confirmation

  // API-loaded data
  List<ClinicModel> _clinics = [];
  List<DoctorModel> _doctors = [];
  List<String> _timeSlots = [];
  bool _loadingClinics = true;
  bool _loadingDoctors = false;
  bool _loadingSlots = false;
  bool _booking = false;

  // Booking selections
  ClinicModel? _selectedClinic;
  String? _department;
  DoctorModel? _selectedDoctor;
  DateTime? _date;
  String? _timeSlot;
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    setState(() => _loadingClinics = true);
    try {
      _clinics = await ClinicService.browsePublicClinics();
    } catch (e) {
      debugPrint('⚠️ Failed to load clinics: $e');
    }
    if (mounted) setState(() => _loadingClinics = false);
  }

  Future<void> _loadDoctors() async {
    if (_selectedClinic == null) return;
    setState(() {
      _loadingDoctors = true;
      _doctors = [];
    });
    try {
      _doctors = await DoctorService.listDoctors(clinic: _selectedClinic!.id);
    } catch (e) {
      debugPrint('⚠️ Failed to load doctors: $e');
    }
    if (mounted) setState(() => _loadingDoctors = false);
  }

  Future<void> _loadSlots() async {
    if (_selectedDoctor == null || _date == null) return;
    setState(() {
      _loadingSlots = true;
      _timeSlots = [];
    });
    try {
      final dateStr =
          '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';
      final slots = await DoctorService.getAvailableSlots(
        doctorId: _selectedDoctor!.id,
        date: dateStr,
        clinicId: _selectedClinic?.id,
      );
      _timeSlots = slots;
      if (_timeSlots.isEmpty) {
        // Fallback: show common time slots
        _timeSlots = [
          '09:00',
          '09:30',
          '10:00',
          '10:30',
          '11:00',
          '11:30',
          '14:00',
          '14:30',
          '15:00',
          '15:30',
          '16:00',
        ];
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load slots: $e, using defaults');
      _timeSlots = [
        '09:00',
        '09:30',
        '10:00',
        '10:30',
        '11:00',
        '11:30',
        '14:00',
        '14:30',
        '15:00',
        '15:30',
        '16:00',
      ];
    }
    if (mounted) setState(() => _loadingSlots = false);
  }

  bool get _canContinue {
    switch (_step) {
      case 1:
        return _selectedClinic != null;
      case 2:
        return _selectedDoctor != null;
      case 3:
        return _date != null && _timeSlot != null;
      default:
        return true;
    }
  }

  Future<void> _onContinue() async {
    if (!_canContinue) return;
    if (_step == 4) {
      // Book via API
      setState(() => _booking = true);
      try {
        final dateStr =
            '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';
        await AppointmentService.bookAppointment(
          doctorId: _selectedDoctor!.id,
          date: dateStr,
          time: _timeSlot!,
          appointmentType: 'first_visit',
          mode: 'in_clinic',
          notes: _reasonCtrl.text.trim().isNotEmpty
              ? _reasonCtrl.text.trim()
              : null,
        );
        // Create local appointment for the callback
        final apt = Appointment.local(
          hospital: _selectedClinic?.name ?? '',
          doctorName: _selectedDoctor?.name ?? 'Doctor',
          specialty: _selectedDoctor?.specialty ?? '',
          dateTime: DateTime(
            _date!.year,
            _date!.month,
            _date!.day,
            int.parse(_timeSlot!.split(':')[0]),
            int.parse(_timeSlot!.split(':')[1]),
          ),
          reason: _reasonCtrl.text.trim(),
        );
        widget.onBooked(apt);
        if (mounted)
          setState(() {
            _step = 5;
            _booking = false;
          });
      } on ApiException catch (e) {
        if (mounted) {
          setState(() => _booking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _booking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking failed: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      setState(() => _step++);
      if (_step == 2) _loadDoctors();
    }
  }

  void _onBack() => setState(() => _step--);

  void _reset() {
    setState(() {
      _step = 1;
      _selectedClinic = null;
      _department = null;
      _selectedDoctor = null;
      _date = null;
      _timeSlot = null;
      _reasonCtrl.clear();
      _doctors = [];
      _timeSlots = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 5) return _ConfirmationView(onBookAnother: _reset);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _booking
                ? const Center(
                    child: CircularProgressIndicator(color: _kPrimary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildStepContent(),
                    ),
                  ),
          ),
          _buildNavButtons(),
        ],
      ),
    );
  }

  // ── Header + progress bar ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _kNavy,
            ),
          ),
          Text(
            'Step $_step of 4',
            style: const TextStyle(fontSize: 13, color: _kGrey),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (i) {
              final filled = i < _step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: filled
                        ? const LinearGradient(
                            colors: [Color(0xFF1A6EE8), _kPrimary],
                          )
                        : null,
                    color: filled ? null : _kBorder,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Step content router ───────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _loadingClinics
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: _kPrimary),
                ),
              )
            : _HospitalStep(
                clinics: _clinics,
                selected: _selectedClinic,
                selectedDept: _department,
                onSelect: (c) => setState(() {
                  _selectedClinic = c;
                  _department = null;
                  _selectedDoctor = null;
                }),
                onSelectDept: (d) => setState(() => _department = d),
              );
      case 2:
        return _loadingDoctors
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: _kPrimary),
                ),
              )
            : _DoctorStep(
                doctors: _doctors,
                selected: _selectedDoctor,
                onSelect: (doc) => setState(() => _selectedDoctor = doc),
              );
      case 3:
        return _DateTimeStep(
          date: _date,
          timeSlot: _timeSlot,
          timeSlots: _timeSlots,
          loadingSlots: _loadingSlots,
          onDateChanged: (d) {
            setState(() {
              _date = d;
              _timeSlot = null;
            });
            _loadSlots();
          },
          onSlotChanged: (s) => setState(() => _timeSlot = s),
        );
      case 4:
        return _ReasonStep(controller: _reasonCtrl);
      default:
        return const SizedBox();
    }
  }

  // ── Navigation buttons ─────────────────────────────────────────────────────
  Widget _buildNavButtons() {
    final isFirst = _step == 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      color: _kBg,
      child: Row(
        children: [
          if (!isFirst) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: _kBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 15,
                    color: _kNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: isFirst ? 1 : 2,
            child: GestureDetector(
              onTap: _canContinue ? _onContinue : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _canContinue
                        ? [const Color(0xFF1A6EE8), _kPrimary]
                        : [const Color(0xFFB0BEC5), const Color(0xFFB2DFDB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _step == 4 ? 'Confirm Booking' : 'Continue',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Select Hospital (with search + department)
// ─────────────────────────────────────────────────────────────────────────────
class _HospitalStep extends StatefulWidget {
  final List<ClinicModel> clinics;
  final ClinicModel? selected;
  final String? selectedDept;
  final void Function(ClinicModel) onSelect;
  final void Function(String) onSelectDept;
  const _HospitalStep({
    required this.clinics,
    required this.selected,
    required this.selectedDept,
    required this.onSelect,
    required this.onSelectDept,
  });

  @override
  State<_HospitalStep> createState() => _HospitalStepState();
}

class _HospitalStepState extends State<_HospitalStep> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.clinics
        .where((c) => (c.name).toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(Icons.local_hospital_outlined, 'Select Clinic'),
        const SizedBox(height: 16),
        // ── Search bar ────────────────────────────────────────────
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search clinic...',
            hintStyle: const TextStyle(fontSize: 14, color: _kGrey),
            prefixIcon: const Icon(Icons.search, size: 20, color: _kGrey),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: _kGrey),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: _kBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // ── Clinic list ──────────────────────────────────────────
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                _query.isEmpty
                    ? 'No clinics available'
                    : 'No clinics found for "$_query"',
                style: const TextStyle(fontSize: 13, color: _kGrey),
              ),
            ),
          )
        else
          ...filtered.map(
            (c) => _SelectCard(
              title: c.name,
              subtitle: c.clinicType ?? 'Clinic',
              icon: Icons.local_hospital_outlined,
              selected: widget.selected?.id == c.id,
              onTap: () => widget.onSelect(c),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Select Doctor
// ─────────────────────────────────────────────────────────────────────────────
class _DoctorStep extends StatelessWidget {
  final List<DoctorModel> doctors;
  final DoctorModel? selected;
  final void Function(DoctorModel) onSelect;
  const _DoctorStep({
    required this.doctors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(Icons.person_2_outlined, 'Select Doctor'),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'No doctors available for this clinic',
              style: TextStyle(fontSize: 13, color: _kGrey),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(Icons.person_2_outlined, 'Select Doctor'),
        const SizedBox(height: 16),
        ...doctors.map(
          (d) => _SelectCard(
            title: d.name,
            subtitle: d.specialty ?? 'Specialist',
            icon: Icons.medical_services_outlined,
            selected: selected?.id == d.id,
            onTap: () => onSelect(d),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Select Date & Time
// ─────────────────────────────────────────────────────────────────────────────
class _DateTimeStep extends StatelessWidget {
  final DateTime? date;
  final String? timeSlot;
  final List<String> timeSlots;
  final bool loadingSlots;
  final void Function(DateTime) onDateChanged;
  final void Function(String) onSlotChanged;

  const _DateTimeStep({
    required this.date,
    required this.timeSlot,
    required this.timeSlots,
    required this.loadingSlots,
    required this.onDateChanged,
    required this.onSlotChanged,
  });

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(Icons.calendar_month_outlined, 'Select Date & Time'),
        const SizedBox(height: 16),
        // Date picker field
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 14,
            color: _kNavy,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now.add(const Duration(days: 1)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 90)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _kPrimary,
                    onSurface: _kNavy,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) onDateChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                Text(
                  date == null
                      ? 'mm/dd/yyyy'
                      : '${_pad(date!.month)}/${_pad(date!.day)}/${date!.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: date == null ? _kGrey : _kNavy,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _kGrey,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Time slots
        const Text(
          'Available Time Slots',
          style: TextStyle(
            fontSize: 14,
            color: _kNavy,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        if (date == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Pick a date first',
                style: TextStyle(fontSize: 13, color: _kGrey),
              ),
            ),
          )
        else if (loadingSlots)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: _kPrimary),
            ),
          )
        else if (timeSlots.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No slots available',
                style: TextStyle(fontSize: 13, color: _kGrey),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.6,
            ),
            itemCount: timeSlots.length,
            itemBuilder: (ctx, i) {
              final slot = timeSlots[i];
              final sel = timeSlot == slot;
              return GestureDetector(
                onTap: () => onSlotChanged(slot),
                child: Container(
                  decoration: BoxDecoration(
                    color: sel
                        ? _kPrimary.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? _kPrimary : _kBorder,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: sel ? _kPrimary : _kNavy,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        slot,
                        style: TextStyle(
                          fontSize: 12,
                          color: sel ? _kPrimary : _kNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Reason for Visit
// ─────────────────────────────────────────────────────────────────────────────
class _ReasonStep extends StatelessWidget {
  final TextEditingController controller;
  const _ReasonStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason for Visit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe your reason for visiting...',
            hintStyle: const TextStyle(color: _kGrey, fontSize: 14),
            filled: true,
            fillColor: _kBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation screen
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmationView extends StatelessWidget {
  final VoidCallback onBookAnother;
  const _ConfirmationView({required this.onBookAnother});

  @override
  Widget build(BuildContext context) {
    // We show a generic success screen; details are already saved via onBooked
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 44,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Appointment Booked!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your appointment is pending confirmation.',
                style: TextStyle(fontSize: 14, color: _kGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Book another button
              GestureDetector(
                onTap: onBookAnother,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 40,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A6EE8), _kPrimary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Book Another',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────
class _StepTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _StepTitle(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kPrimary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _kNavy,
          ),
        ),
      ],
    );
  }
}

class _SelectCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _kPrimary.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kPrimary : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? _kPrimary.withValues(alpha: 0.1)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: selected ? _kPrimary : _kGrey),
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
                      fontWeight: FontWeight.w600,
                      color: _kNavy,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _kGrey),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? _kPrimary : _kGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
