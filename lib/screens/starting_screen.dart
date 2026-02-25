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
    final isLast = _page == _total - 1;
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kPrimary, _kPrimaryDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'QuickCare',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _kNavy,
                    ),
                  ),
                  const Text(
                    ' AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _kPrimary,
                    ),
                  ),
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
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 16, color: _kGrey),
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
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
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
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 15,
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 17),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kPrimary.withValues(alpha: 0.25)),
            ),
            child: const Text(
              '🤖 AI-Powered Healthcare Platform',
              style: TextStyle(
                color: _kPrimaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Headline
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.bold,
                color: _kNavy,
                height: 1.2,
              ),
              children: [
                TextSpan(text: 'Healthcare made '),
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
          const SizedBox(height: 14),
          const Text(
            'Seamlessly connect patients, doctors, labs, and hospitals. '
            'AI-powered insights, real-time scheduling, and complete medical record management.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _kGrey, height: 1.55),
          ),
          const SizedBox(height: 24),
          // Stats row card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat('👥', 'Patients', '10K+'),
                Container(width: 1, height: 36, color: _kBorder),
                _MiniStat('🏥', 'Hospitals', '50+'),
                Container(width: 1, height: 36, color: _kBorder),
                _MiniStat('⭐', 'Rating', '4.9'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String emoji, label, value;
  const _MiniStat(this.emoji, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: _kPrimary,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: _kGrey)),
      ],
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
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.3,
            children: _stats
                .map((s) => _StatCard(value: s.$1, label: s.$2))
                .toList(),
          ),
          const SizedBox(height: 28),
          const Text(
            'Everything you need\nin one platform',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _kNavy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'A comprehensive solution for modern healthcare management',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: _kGrey, height: 1.5),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Everything you need\nin one platform',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _kNavy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A comprehensive solution for modern healthcare management',
            style: TextStyle(fontSize: 13.5, color: _kGrey, height: 1.4),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
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
            child: const Icon(
              Icons.health_and_safety_outlined,
              size: 46,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Trusted by\nHealthcare Providers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _kNavy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your data is protected with enterprise-grade security standards used by leading healthcare organisations.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _kGrey, height: 1.55),
          ),
          const SizedBox(height: 24),
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
                      style: const TextStyle(
                        fontSize: 14.5,
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
