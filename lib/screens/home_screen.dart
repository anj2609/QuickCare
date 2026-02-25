import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../models/document_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/appointment_service.dart';
import '../services/document_service.dart';
import 'book_tab.dart';
import 'health_tab.dart';
import 'starting_screen.dart';
import '../widgets/ai_chat_overlay.dart';

const _kBg = Color(0xFFF0F4F8);
const _kPrimary = Color(0xFF2CB8C7);
const _kPrimaryDark = Color(0xFF1A92A0);
const _kNavy = Color(0xFF0F172A);
const _kGrey = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kCardBg = Colors.white;

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — loads user from SharedPreferences, hosts bottom nav
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  String _userName = '';
  String _userContact = '';
  String _userEmail = '';
  String _userGender = '';
  int? _userAge;
  String _userBloodGroup = '';
  List<Appointment> _appointments = [];
  List<DocumentModel> _documents = [];
  List<ConsentRequest> _consents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Load user profile from API
      final user = await UserService.getMe();
      _userName = user.name;
      _userContact = user.contact.toString();
      _userEmail = user.email ?? '';
      _userGender = user.gender ?? '';
      _userAge = user.age;
      _userBloodGroup = user.bloodGroup ?? '';
    } catch (e) {
      debugPrint('⚠️ Failed to load profile: $e');
      // Fallback to saved name/contact
      _userName = await AuthService.getSavedName();
      _userContact = await AuthService.getSavedContact();
    }
    try {
      _appointments = await AppointmentService.listMyAppointments();
    } catch (e) {
      debugPrint('⚠️ Failed to load appointments: $e');
    }
    try {
      _documents = await DocumentService.listDocuments();
    } catch (e) {
      debugPrint('⚠️ Failed to load documents: $e');
    }
    try {
      _consents = await DocumentService.listConsentRequests();
    } catch (e) {
      debugPrint('⚠️ Failed to load consents: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  String get _initials {
    final parts = _userName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kPrimary)),
      );
    }

    final tabs = [
      _HomeTab(
        userName: _userName,
        appointments: _appointments,
        documents: _documents,
        consents: _consents,
        onConsentAction: _handleConsentAction,
        onNavigateToHealth: () => setState(() => _idx = 1),
      ),
      HealthTab(appointments: _appointments, documents: _documents),
      BookTab(onBooked: _handleBooking),
      _ProfileTab(
        userName: _userName,
        userContact: _userContact,
        userEmail: _userEmail,
        userGender: _userGender,
        userAge: _userAge,
        userBloodGroup: _userBloodGroup,
        initials: _initials,
        onSignOut: _signOut,
      ),
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          tabs[_idx],
          if (_idx == 0) AiChatOverlay(userName: _userName),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: _kPrimary.withValues(alpha: 0.12),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: _kPrimary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart_rounded, color: _kPrimary),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: _kPrimary),
            label: 'Book',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: _kPrimary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking(Appointment a) async {
    // The BookTab now calls AppointmentService.bookAppointment() internally.
    // We just reload the list.
    await _loadData();
  }

  Future<void> _handleConsentAction(String consentId, String action) async {
    try {
      await DocumentService.actionConsent(consentId, action);
      _consents = await DocumentService.listConsentRequests();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('⚠️ Consent action failed: $e');
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold, color: _kNavy),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: _kGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: _kGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final nav = Navigator.of(context);
      await AuthService.clearAll();
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StartingScreen()),
        (route) => false,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home Tab
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final String userName;
  final List<Appointment> appointments;
  final List<DocumentModel> documents;
  final List<ConsentRequest> consents;
  final Future<void> Function(String consentId, String action) onConsentAction;
  final VoidCallback onNavigateToHealth;

  const _HomeTab({
    this.userName = '',
    required this.appointments,
    required this.documents,
    required this.consents,
    required this.onConsentAction,
    required this.onNavigateToHealth,
  });

  String get _firstName {
    final name = userName.trim();
    if (name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final titleFs = (sw * 0.06).clamp(20.0, 28.0);
    final subtitleFs = (sw * 0.035).clamp(12.0, 16.0);
    final hPad = (sw * 0.04).clamp(12.0, 20.0);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $_firstName 👋',
              style: TextStyle(
                fontSize: titleFs,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Here's your health overview",
              style: TextStyle(fontSize: subtitleFs, color: _kGrey),
            ),
            const SizedBox(height: 20),

            Builder(
              builder: (context) {
                // Derive a fixed card height from screen width so all three
                // cards are identical — avoids IntrinsicHeight inside a
                // LayoutBuilder descendant (which crashes Flutter's renderer).
                final sw = MediaQuery.of(context).size.width;
                final cardH = (sw * 0.36).clamp(110.0, 145.0);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: cardH,
                        child: _StatCard(
                          label: 'Upcoming\nAppointments',
                          count: '${appointments.length}',
                          icon: Icons.calendar_today_outlined,
                          onTap: onNavigateToHealth,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: cardH,
                        child: _StatCard(
                          label: 'Reports\nAvailable',
                          count: '${documents.length}',
                          icon: Icons.description_outlined,
                          onTap: onNavigateToHealth,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: cardH,
                        child: _StatCard(
                          label: 'Consent\nRequests',
                          count:
                              '${consents.where((c) => c.status == "pending").length}',
                          icon: Icons.assignment_outlined,
                          onTap: onNavigateToHealth,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // ─── Consent Management ──────────────────────────────
            const _DecorativeHeader(title: 'Consent Management'),
            const SizedBox(height: 8),
            _ConsentManagementCard(
              consents: consents,
              onAction: onConsentAction,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, count;
  final IconData icon;
  final VoidCallback? onTap;
  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final iconSize = (w * 0.2).clamp(24.0, 34.0);
        final countFontSize = (w * 0.22).clamp(18.0, 28.0);
        final labelFontSize = (w * 0.09).clamp(9.0, 12.0);
        final pad = (w * 0.08).clamp(8.0, 14.0);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(12),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: iconSize * 0.55, color: _kPrimary),
                ),
                SizedBox(height: pad * 0.5),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: countFontSize,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
                Text(
                  label.replaceAll('\n', ' '),
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: _kGrey,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Recent Reports card ────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Profile Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final String userName;
  final String userContact;
  final String userEmail;
  final String userGender;
  final int? userAge;
  final String userBloodGroup;
  final String initials;
  final VoidCallback onSignOut;

  const _ProfileTab({
    required this.userName,
    required this.userContact,
    this.userEmail = '',
    this.userGender = '',
    this.userAge,
    this.userBloodGroup = '',
    required this.initials,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hPad = (sw * 0.04).clamp(12.0, 20.0);
    final titleFs = (sw * 0.055).clamp(18.0, 26.0);
    final bodyFs = (sw * 0.034).clamp(12.0, 16.0);
    final displayName = userName.trim().isEmpty ? 'User' : userName.trim();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Sign Out
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: titleFs,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 13, color: Colors.redAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kCardBg,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: (sw * 0.18).clamp(56.0, 80.0),
                        height: (sw * 0.18).clamp(56.0, 80.0),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kPrimary, _kPrimaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (sw * 0.065).clamp(20.0, 30.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: hPad),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: (sw * 0.05).clamp(16.0, 22.0),
                              fontWeight: FontWeight.bold,
                              color: _kNavy,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Patient',
                            style: TextStyle(fontSize: bodyFs, color: _kGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: userContact.isEmpty ? '—' : userContact,
                  ),
                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: userEmail,
                    ),
                  ],
                  if (userGender.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Gender',
                      value:
                          userGender[0].toUpperCase() + userGender.substring(1),
                    ),
                  ],
                  if (userAge != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: '$userAge years',
                    ),
                  ],
                  if (userBloodGroup.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.bloodtype_outlined,
                      label: 'Blood Group',
                      value: userBloodGroup,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: _kGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: _kNavy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative header for cards
// ─────────────────────────────────────────────────────────────────────────────
class _DecorativeHeader extends StatelessWidget {
  final String title;
  const _DecorativeHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: ClipRect(
              child: Text(
                '════════════════════════════',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: _kBorder,
                  fontSize: 8,
                  letterSpacing: -1,
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
// Consent Management card
// ─────────────────────────────────────────────────────────────────────────────
class _ConsentManagementCard extends StatelessWidget {
  final List<ConsentRequest> consents;
  final Future<void> Function(String consentId, String action) onAction;

  const _ConsentManagementCard({
    required this.consents,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final pending = consents.where((c) => c.status == 'pending').toList();
    final granted = consents.where((c) => c.status == 'granted').toList();
    final rejected = consents
        .where((c) => c.status == 'rejected' || c.status == 'revoked')
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pending Requests ────────────────────────────────────
          if (pending.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pending Requests (${pending.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kNavy,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            ...pending.map(
              (c) => Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Doctor #${c.doctor ?? "?"}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _kNavy,
                                ),
                              ),
                              if (c.purpose != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  c.purpose!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kGrey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _StatusBadge('Pending', const Color(0xFFF59E0B)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ConsentButton(
                          label: '✓  Approve',
                          color: const Color(0xFF10B981),
                          onTap: () => onAction(c.id, 'grant'),
                        ),
                        const SizedBox(width: 10),
                        _ConsentButton(
                          label: '✕  Deny',
                          color: const Color(0xFFEF4444),
                          onTap: () => onAction(c.id, 'reject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Active Consents ─────────────────────────────────────
          if (granted.isNotEmpty) ...[
            if (pending.isNotEmpty) const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Text(
                'Active Consents (${granted.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            ...granted.map(
              (c) => _ConsentRow(
                name: 'Doctor #${c.doctor ?? "?"}',
                detail: c.purpose ?? '',
                trailingWidget: OutlinedButton(
                  onPressed: () => onAction(c.id, 'revoke'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Revoke',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],

          // ── Rejected / Revoked ──────────────────────────────────
          if (rejected.isNotEmpty) ...[
            const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Text(
                'Denied (${rejected.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            ...rejected.map(
              (c) => _ConsentRow(
                name: 'Doctor #${c.doctor ?? "?"}',
                detail: c.purpose ?? '',
                trailingWidget: _StatusBadge(
                  c.status == 'revoked' ? 'Revoked' : 'Denied',
                  const Color(0xFFEF4444),
                ),
              ),
            ),
          ],

          if (consents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No consent records',
                  style: TextStyle(fontSize: 13, color: _kGrey),
                ),
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final String name, detail;
  final Widget trailingWidget;
  const _ConsentRow({
    required this.name,
    required this.detail,
    required this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 11, color: _kGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailingWidget,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConsentButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ConsentButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
