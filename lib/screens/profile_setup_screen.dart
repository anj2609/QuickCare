import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

const _kBg = Color(0xFFF0F4F8);
const _kPrimary = Color(0xFF2CB8C7);
const _kPrimaryDark = Color(0xFF1A92A0);
const _kNavy = Color(0xFF0F172A);
const _kGrey = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
const _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

// API values for gender chips
const _genderApiValues = {
  'Male': 'male',
  'Female': 'female',
  'Other': 'other',
  'Prefer not to say': 'prefer_not_to_say',
};

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — PUT /users/onboarding/patient/step3/   (protected route)
// ─────────────────────────────────────────────────────────────────────────────
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Required
  String? _gender;
  final _ageCtrl = TextEditingController();

  // Optional — Personal
  final _emailCtrl = TextEditingController();
  String? _bloodGroup;
  final _houseNoCtrl = TextEditingController();
  final _addressAreaCtrl = TextEditingController();
  final _townCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  // Optional — Medical
  final _allergiesCtrl = TextEditingController();
  final _chronicConditionsCtrl = TextEditingController();
  final _currentMedicationsCtrl = TextEditingController();
  final _pastSurgeriesCtrl = TextEditingController();
  final _familyHistoryCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  // Optional — Emergency contact
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyNumberCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    for (final ctrl in [
      _ageCtrl,
      _emailCtrl,
      _houseNoCtrl,
      _addressAreaCtrl,
      _townCtrl,
      _stateCtrl,
      _pincodeCtrl,
      _landmarkCtrl,
      _allergiesCtrl,
      _chronicConditionsCtrl,
      _currentMedicationsCtrl,
      _pastSurgeriesCtrl,
      _familyHistoryCtrl,
      _heightCtrl,
      _weightCtrl,
      _emergencyNameCtrl,
      _emergencyNumberCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{
      'gender': _genderApiValues[_gender] ?? _gender!.toLowerCase(),
      'age': int.parse(_ageCtrl.text.trim()),
    };

    void addIfNotEmpty(String key, String value) {
      if (value.trim().isNotEmpty) payload[key] = value.trim();
    }

    addIfNotEmpty('email', _emailCtrl.text);
    if (_bloodGroup != null) payload['blood_group'] = _bloodGroup;
    addIfNotEmpty('house_no', _houseNoCtrl.text);
    addIfNotEmpty('address_area', _addressAreaCtrl.text);
    addIfNotEmpty('town', _townCtrl.text);
    addIfNotEmpty('state', _stateCtrl.text);
    addIfNotEmpty('pincode', _pincodeCtrl.text);
    addIfNotEmpty('landmark', _landmarkCtrl.text);
    addIfNotEmpty('allergies', _allergiesCtrl.text);
    addIfNotEmpty('chronic_conditions', _chronicConditionsCtrl.text);
    addIfNotEmpty('current_medications', _currentMedicationsCtrl.text);
    addIfNotEmpty('past_surgeries', _pastSurgeriesCtrl.text);
    addIfNotEmpty('family_history', _familyHistoryCtrl.text);

    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h != null) payload['height_cm'] = h;
    if (w != null) payload['weight_kg'] = w;

    addIfNotEmpty('emergency_contact_name', _emergencyNameCtrl.text);
    addIfNotEmpty('emergency_contact_number', _emergencyNumberCtrl.text);

    return payload;
  }

  Future<void> _submit() async {
    if (_gender == null) {
      _showSnack('Please select your gender', Colors.orangeAccent);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await AuthService.step3(_buildPayload());
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, Colors.redAccent);
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString(), Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _skip() async {
    if (_gender == null) {
      _showSnack('Please select your gender to continue', Colors.orangeAccent);
      return;
    }
    final age = _ageCtrl.text.trim();
    if (age.isEmpty) {
      _showSnack('Please enter your age to continue', Colors.orangeAccent);
      return;
    }
    final n = int.tryParse(age);
    if (n == null || n < 1 || n > 120) {
      _showSnack('Please enter a valid age (1–120)', Colors.orangeAccent);
      return;
    }
    setState(() => _loading = true);
    try {
      // Send at minimum gender + age to the backend before skipping
      await AuthService.step3({
        'gender': _genderApiValues[_gender] ?? _gender!.toLowerCase(),
        'age': n,
      });
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, Colors.redAccent);
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString(), Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hPad = (sw * 0.07).clamp(20.0, 32.0);
    final titleFs = (sw * 0.065).clamp(20.0, 28.0);
    final subtitleFs = (sw * 0.035).clamp(12.0, 15.0);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ─────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kPrimary, _kPrimaryDark],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'QuickCare',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _kNavy,
                      ),
                    ),
                    const Text(
                      ' AI',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: titleFs,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Step 3 of 3 · Fill in your medical details',
                  style: TextStyle(fontSize: subtitleFs, color: _kGrey),
                ),
                const SizedBox(height: 24),

                // ═══ Personal Details ══════════════════════════════
                _SectionLabel('Personal Details'),
                const SizedBox(height: 12),

                // Gender (required)
                _FieldLabel('Gender * (required)'),
                if (_gender == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 2),
                    child: Text(
                      'Please select one',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _genderOptions.map((g) {
                    final active = _gender == g;
                    return GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active ? _kPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? _kPrimary : _kBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(
                            fontSize: 13,
                            color: active ? Colors.white : _kGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Age (required)
                _FieldLabel('Age *'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _ageCtrl,
                  hint: 'e.g. 28',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Age is required';
                    final n = int.tryParse(v);
                    if (n == null || n < 1 || n > 120) {
                      return 'Enter a valid age (1–120)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email (optional)
                _FieldLabel('Email (optional)'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _emailCtrl,
                  hint: 'rahul@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // Blood Group
                _FieldLabel('Blood Group (optional)'),
                const SizedBox(height: 6),
                _BloodGroupPicker(
                  selected: _bloodGroup,
                  onChanged: (v) => setState(() => _bloodGroup = v),
                ),
                const SizedBox(height: 20),

                // ═══ Address ══════════════════════════════════════
                _SectionLabel('Address (optional)'),
                const SizedBox(height: 12),

                _FieldLabel('House / Flat No.'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _houseNoCtrl,
                  hint: 'e.g. 12A',
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Area / Street'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _addressAreaCtrl,
                  hint: 'e.g. Near City Hospital',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Town / City'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _townCtrl,
                            hint: 'Jaipur',
                            icon: Icons.location_city_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('State'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _stateCtrl,
                            hint: 'Rajasthan',
                            icon: Icons.map_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Pincode'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _pincodeCtrl,
                            hint: '302001',
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Landmark'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _landmarkCtrl,
                            hint: 'Opp. SBI Bank',
                            icon: Icons.place_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ═══ Medical Details ══════════════════════════════
                _SectionLabel('Medical Details (optional)'),
                const SizedBox(height: 12),

                _FieldLabel('Known Allergies'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _allergiesCtrl,
                  hint: 'e.g. Penicillin, or None',
                  icon: Icons.warning_amber_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Chronic Conditions'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _chronicConditionsCtrl,
                  hint: 'e.g. Diabetes, Hypertension, or None',
                  icon: Icons.monitor_heart_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Current Medications'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _currentMedicationsCtrl,
                  hint: 'e.g. Metformin 500mg',
                  icon: Icons.medication_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Past Surgeries'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _pastSurgeriesCtrl,
                  hint: 'e.g. Appendectomy 2020',
                  icon: Icons.healing_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Family Medical History'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _familyHistoryCtrl,
                  hint: 'e.g. Diabetes (father), or None',
                  icon: Icons.people_outline,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Height (cm)'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _heightCtrl,
                            hint: '175',
                            icon: Icons.height_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Weight (kg)'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _weightCtrl,
                            hint: '70.5',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ═══ Emergency Contact ════════════════════════════
                _SectionLabel('Emergency Contact (optional)'),
                const SizedBox(height: 12),

                _FieldLabel('Contact Name'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _emergencyNameCtrl,
                  hint: 'e.g. Priya Sharma',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Contact Phone Number'),
                const SizedBox(height: 6),
                _InputField(
                  controller: _emergencyNumberCtrl,
                  hint: 'e.g. 9123456789',
                  icon: Icons.contact_phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 28),

                // ── Complete Registration ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kPrimary, _kPrimaryDark],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: _kPrimary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Complete Registration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: _loading ? null : _skip,
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: subtitleFs,
                        color: _kGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Blood Group Picker ────────────────────────────────────────────────────────
class _BloodGroupPicker extends StatelessWidget {
  final String? selected;
  final void Function(String?) onChanged;
  const _BloodGroupPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _bloodGroups.map((g) {
        final active = g == selected;
        return GestureDetector(
          onTap: () => onChanged(active ? null : g),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? _kPrimary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? _kPrimary : _kBorder,
                width: 1.5,
              ),
            ),
            child: Text(
              g,
              style: TextStyle(
                fontSize: 13,
                color: active ? Colors.white : _kGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _kNavy,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _kNavy,
    ),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: _kNavy),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _kGrey.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, size: 20, color: _kGrey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
