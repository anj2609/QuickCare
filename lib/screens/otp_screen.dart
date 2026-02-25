import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_setup_screen.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

const _kBg = Color(0xFFF0F4F8);
const _kPrimary = Color(0xFF2CB8C7);
const _kPrimaryDark = Color(0xFF1A92A0);
const _kNavy = Color(0xFF0F172A);
const _kGrey = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — POST /users/onboarding/patient/step2/
// ─────────────────────────────────────────────────────────────────────────────
class OtpVerificationScreen extends StatefulWidget {
  final int contact; // numeric, sent to API
  final String displayContact; // formatted string shown in UI
  const OtpVerificationScreen({
    super.key,
    required this.contact,
    required this.displayContact,
  });
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      _showSnack('Please enter all 6 digits', Colors.redAccent);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.step2(contact: widget.contact, otp: otp);
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: _kNavy,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Verify Phone',
                style: TextStyle(
                  fontSize: titleFs,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: subtitleFs, color: _kGrey),
                  children: [
                    const TextSpan(text: 'Step 2 of 3 · OTP sent to '),
                    TextSpan(
                      text: widget.displayContact,
                      style: const TextStyle(
                        color: _kNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpField(i, sw)),
              ),
              const SizedBox(height: 32),

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
                    onPressed: _loading ? null : _verify,
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
                            'Verify & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    Text(
                      _timerSeconds > 0
                          ? 'Resend code in ${_timerSeconds}s'
                          : "Didn't receive the OTP?",
                      style: TextStyle(fontSize: subtitleFs, color: _kGrey),
                    ),
                    if (_timerSeconds == 0)
                      TextButton(
                        onPressed: _startTimer,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index, double sw) {
    final fieldSize = ((sw - 64) / 6 - 4).clamp(38.0, 54.0);
    final fontSize = (fieldSize * 0.42).clamp(16.0, 24.0);
    return SizedBox(
      width: fieldSize,
      height: fieldSize * 1.1,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: _kNavy,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kPrimary, width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _verify();
            }
          } else {
            if (index > 0) _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
