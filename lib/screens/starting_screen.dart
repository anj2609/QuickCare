import 'package:flutter/material.dart';
import 'auth_screen.dart';

const _kBg = Color(0xFFF0F4F8);
const _kPrimary = Color(0xFF2CB8C7);
const _kPrimaryDark = Color(0xFF1A92A0);
const _kNavy = Color(0xFF0F172A);
const _kGrey = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

// ── StartingScreen ────────────────────────────────────────────────────────────
class StartingScreen extends StatefulWidget {
  const StartingScreen({super.key});
  @override
  State<StartingScreen> createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  final _ctrl = PageController();
  int _page = 0;
  static const int _total = 4;

  void _next() {
    if (_page < _total - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToAuth();
    }
  }

  void _skip() => _goToAuth();

  void _goToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const AuthScreen(),
        transitionsBuilder: (ctx, anim, sec, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isLast = _page == _total - 1;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar (Simplified to only Skip button) ────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                (sw * 0.025).clamp(8, 16),
                12,
                0,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLast ? null : _skip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: (sw * 0.04).clamp(14.0, 16.0),
                          color: _kGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages fill remaining space ────────────────────────────
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [_Page1(), _Page2(), _Page3(), _Page4()],
              ),
            ),

            // ── Dots + Button (compact) ──────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                4,
                24,
                (sw * 0.05).clamp(16.0, 32.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _total,
                      (i) => _Dot(active: i == _page),
                    ),
                  ),
                  SizedBox(height: (sw * 0.035).clamp(10.0, 16.0)),
                  SizedBox(
                    width: double.infinity,
                    height: (sw * 0.12).clamp(48.0, 56.0),
                    child: isLast
                        ? DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kPrimary, _kPrimaryDark],
                              ),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: _kPrimary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _goToAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: (sw * 0.04).clamp(15.0, 18.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: _next,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kPrimary,
                              side: const BorderSide(
                                color: _kPrimary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: (sw * 0.04).clamp(15.0, 18.0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 17,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dot ───────────────────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 7,
      width: active ? 22 : 7,
      decoration: BoxDecoration(
        color: active ? _kPrimary : _kBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Page 1 — Hero ─────────────────────────────────────────────────────────────
class _Page1 extends StatelessWidget {
  const _Page1();
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final logoSize = (sw * 0.35).clamp(100.0, 160.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(logoSize * 0.22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(logoSize * 0.22),
              child: Image.asset(
                'assets/logo_without_text.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: (sw * 0.1).clamp(24.0, 48.0)),
          // Headline
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: (sw * 0.09).clamp(28.0, 42.0),
                fontWeight: FontWeight.bold,
                color: _kNavy,
                height: 1.2,
              ),
              children: const [
                TextSpan(text: 'Healthcare made\n'),
                TextSpan(
                  text: 'simple',
                  style: TextStyle(color: _kPrimary),
                ),
                TextSpan(text: ',\n'),
                TextSpan(
                  text: 'smart',
                  style: TextStyle(color: _kPrimary),
                ),
                TextSpan(text: ' & secure'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2 — Stats ────────────────────────────────────────────────────────────
class _Page2 extends StatelessWidget {
  const _Page2();
  static const _stats = [
    ('10K+', 'Patients Served'),
    ('500+', 'Doctors'),
    ('98%', 'Satisfaction'),
    ('50+', 'Hospitals'),
  ];
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: (sw * 0.03).clamp(8.0, 16.0),
            crossAxisSpacing: (sw * 0.03).clamp(8.0, 16.0),
            childAspectRatio: (sw > 400) ? 2.5 : 2.2,
            children: _stats
                .map((s) => _StatCard(value: s.$1, label: s.$2))
                .toList(),
          ),
          SizedBox(height: (sw * 0.08).clamp(20.0, 32.0)),
          Text(
            'Everything you need\nin one platform',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (sw * 0.07).clamp(24.0, 32.0),
              fontWeight: FontWeight.bold,
              color: _kNavy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A comprehensive solution for modern healthcare management',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (sw * 0.035).clamp(12.0, 15.0),
              color: _kGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  const _StatCard({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _kGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3 — Features ─────────────────────────────────────────────────────────
class _Page3 extends StatelessWidget {
  const _Page3();
  static const _features = [
    (
      Icons.calendar_today_outlined,
      'Smart Scheduling',
      'Book appointments with real-time availability across departments.',
    ),
    (
      Icons.description_outlined,
      'Digital Records',
      'Secure access to lab reports, prescriptions, and medical history.',
    ),
    (
      Icons.psychology_outlined,
      'AI Summaries',
      'AI-powered summaries for faster, informed decisions.',
    ),
    (
      Icons.security_outlined,
      'Consent Control',
      'Patients control who can access their data anytime.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything you need\nin one platform',
            style: TextStyle(
              fontSize: (sw * 0.065).clamp(22.0, 28.0),
              fontWeight: FontWeight.bold,
              color: _kNavy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A comprehensive solution for modern healthcare management',
            style: TextStyle(
              fontSize: (sw * 0.035).clamp(12.0, 14.0),
              color: _kGrey,
              height: 1.4,
            ),
          ),
          SizedBox(height: (sw * 0.045).clamp(12.0, 20.0)),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: (sw * 0.03).clamp(8.0, 16.0),
            crossAxisSpacing: (sw * 0.03).clamp(8.0, 16.0),
            childAspectRatio: (sw > 400) ? 1.05 : 0.9,
            children: _features
                .map((f) => _FeatureCard(icon: f.$1, title: f.$2, body: f.$3))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 19, color: _kPrimary),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              body,
              style: const TextStyle(
                fontSize: 11.5,
                color: _kGrey,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 4 — Trusted ─────────────────────────────────────────────────────────
class _Page4 extends StatelessWidget {
  const _Page4();
  static const _badges = [
    'ABHA coming soon',
    'End-to-End Encryption',
    'Secure Storage',
  ];
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final iconSize = (sw * 0.22).clamp(70.0, 100.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kPrimary.withValues(alpha: 0.15),
                  _kPrimaryDark.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _kPrimary.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.health_and_safety_outlined,
              size: iconSize * 0.5,
              color: _kPrimary,
            ),
          ),
          SizedBox(height: (sw * 0.05).clamp(16.0, 24.0)),
          Text(
            'Trusted by\nHealthcare Providers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (sw * 0.07).clamp(24.0, 32.0),
              fontWeight: FontWeight.bold,
              color: _kNavy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your data is protected with enterprise-grade security standards used by leading healthcare organisations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (sw * 0.035).clamp(12.5, 15.0),
              color: _kGrey,
              height: 1.5,
            ),
          ),
          SizedBox(height: (sw * 0.06).clamp(18.0, 28.0)),
          ..._badges.map(
            (b) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: (sw * 0.038).clamp(13.5, 16.0),
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
